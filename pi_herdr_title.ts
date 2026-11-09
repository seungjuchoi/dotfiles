// Herdr session titles for pi.
//
// Claude Code names a session from the first prompt and writes the name to the
// terminal title, so Herdr's sidebar shows it. pi never names a session on its
// own, so its panes all read "π - <cwd>". This extension closes the gap:
//
//   1. On the first prompt of an unnamed session it asks a small model for a
//      short title and stores it with pi.setSessionName(). That also shows up
//      in /resume and pi's own terminal title ("π - <name> - <cwd>").
//   2. Whenever the session name is set (here, /name, or on resume) it reports
//      the name to Herdr as pane metadata: --title for pane/agent views and the
//      $title token for ui.sidebar.agents.rows_by_agent.pi.
//
// /retitle regenerates the title from the conversation so far.
// Installed by dotfiles 3_set_config.fish as ~/.pi/agent/extensions/herdr-title.ts.
// @ts-nocheck

import { execFile } from "node:child_process";
import { existsSync } from "node:fs";
import os from "node:os";
import path from "node:path";

const SOURCE = "plugin:pi-title";
const MAX_TITLE = 48;
// First match with working auth wins; the active model is the last resort.
const TITLE_MODELS = [
  ["kiro-acp", "claude-haiku-5.5"],
  ["anthropic", "claude-haiku-5-5"],
  ["kiro-acp", "claude-haiku-4.5"],
];

const paneId = process.env.HERDR_PANE_ID;
const inHerdr = process.env.HERDR_ENV === "1" && !!paneId;

function herdrBin(): string {
  const candidates = [
    process.env.HERDR_BIN_PATH,
    path.join(os.homedir(), ".local/bin/herdr"),
    "/opt/homebrew/bin/herdr",
  ];
  return candidates.find((p) => p && existsSync(p)) ?? "herdr";
}

let lastReported: string | undefined;

function reportToHerdr(title: string | undefined): void {
  if (!inHerdr || title === lastReported) return;
  lastReported = title;
  const args = ["pane", "report-metadata", paneId!, "--source", SOURCE, "--agent", "pi"];
  if (title) args.push("--title", title, "--token", `title=${title}`);
  else args.push("--clear-title", "--clear-token", "title");
  execFile(herdrBin(), args, { timeout: 5000 }, () => {});
}

function cleanTitle(raw: string): string {
  let t = raw.split("\n").map((l) => l.trim()).find((l) => l.length > 0) ?? "";
  t = t.replace(/^(title|제목)\s*[:：]\s*/i, "");
  t = t.replace(/^["'`“”‘’「」*#\s]+|["'`“”‘’「」*.。\s]+$/g, "");
  if ([...t].length > MAX_TITLE) t = [...t].slice(0, MAX_TITLE - 1).join("") + "…";
  return t;
}

function fallbackTitle(text: string): string {
  return cleanTitle(text.replace(/\s+/g, " "));
}

const PROMPT = `Write a short title for a coding-agent session, based on the user's request below.
Rules:
- 2 to 6 words, at most ${MAX_TITLE} characters.
- Use the same language as the request (Korean request -> Korean title).
- Name the task, not the user. No quotes, no trailing punctuation, no emoji.
- Output only the title.

<request>
{{TEXT}}
</request>`;

async function generateTitle(ctx, text: string): Promise<string | undefined> {
  const reg = ctx.modelRegistry;
  const models = TITLE_MODELS.map(([p, id]) => reg.find(p, id)).filter(Boolean);
  if (ctx.model) models.push(ctx.model);
  const prompt = PROMPT.replace("{{TEXT}}", text.slice(0, 4000));
  for (const model of models) {
    try {
      if (!reg.hasConfiguredAuth(model)) continue;
      const res = await reg.complete(
        model,
        { messages: [{ role: "user", content: [{ type: "text", text: prompt }], timestamp: Date.now() }] },
        { cacheRetention: "none", maxTokens: 200 },
      );
      const out = (res?.content ?? [])
        .filter((c) => c.type === "text")
        .map((c) => c.text)
        .join("");
      const title = cleanTitle(out);
      if (title) return title;
    } catch {
      // try the next model
    }
  }
  return undefined;
}

function conversationText(ctx): string {
  const parts: string[] = [];
  for (const e of ctx.sessionManager.getBranch?.() ?? []) {
    if (e.type !== "message") continue;
    const role = e.message?.role;
    if (role !== "user" && role !== "assistant") continue;
    const c = e.message.content;
    const text = typeof c === "string"
      ? c
      : (Array.isArray(c) ? c : []).filter((b) => b?.type === "text").map((b) => b.text).join("\n");
    if (text.trim()) parts.push(`${role === "user" ? "User" : "Assistant"}: ${text.trim().slice(0, 800)}`);
  }
  // The latest exchanges say most about what the session became.
  return parts.slice(-8).join("\n\n");
}

export default function (pi) {
  let tui = false;
  let naming = false;

  async function nameSession(ctx, text: string) {
    if (naming) return;
    naming = true;
    try {
      const title = (await generateTitle(ctx, text)) ?? fallbackTitle(text);
      if (title) pi.setSessionName(title);
    } finally {
      naming = false;
    }
  }

  pi.on("session_start", async (_event, ctx) => {
    tui = ctx?.mode === "tui";
    if (!tui) return;
    lastReported = undefined;
    reportToHerdr(pi.getSessionName());
  });

  pi.on("session_info_changed", async (event) => {
    if (tui) reportToHerdr(event?.name);
  });

  pi.on("input", async (event, ctx) => {
    if (!tui || pi.getSessionName()) return;
    const text = (event?.text ?? "").trim();
    if (!text || text.startsWith("/") || text.startsWith("!")) return;
    // Do not block the prompt; the title lands a few seconds later.
    void nameSession(ctx, text);
  });

  pi.registerCommand("retitle", {
    description: "Regenerate the session title from the conversation (or set it: /retitle <title>)",
    handler: async (args, ctx) => {
      const manual = args.trim();
      if (manual) {
        pi.setSessionName(cleanTitle(manual));
        return;
      }
      const text = conversationText(ctx);
      if (!text) {
        ctx.ui.notify("No conversation to title yet", "warning");
        return;
      }
      const title = await generateTitle(ctx, text);
      if (!title) {
        ctx.ui.notify("Title generation failed", "warning");
        return;
      }
      pi.setSessionName(title);
      ctx.ui.notify(`Session title: ${title}`, "info");
    },
  });
}
