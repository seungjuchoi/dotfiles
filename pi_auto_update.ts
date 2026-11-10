// Auto-update pi itself on launch, the way Claude Code's autoUpdate does.
//
// On a fresh start (not /new, /resume, fork or reload) this runs `pi update`
// (pi only, not packages) in the background, at most once every 6 hours.
// The managed install keeps one folder per release under install/releases/
// and picks one through install/current-version, so updating while pi runs
// does not touch the running release. The new version applies on the next
// launch. If the update lands while this session is still open, a notice
// says so.
//
// Output goes to ~/.pi/agent/auto-update.log. Set PI_OFFLINE or
// PI_NO_AUTO_UPDATE=1 to skip.
// Installed by dotfiles 3_set_config.fish as ~/.pi/agent/extensions/auto-update.ts.
// @ts-nocheck

import { spawn } from "node:child_process";
import { closeSync, existsSync, openSync, readFileSync, statSync, writeFileSync } from "node:fs";
import os from "node:os";
import path from "node:path";

const INTERVAL_MS = 6 * 60 * 60 * 1000;

const agentDir = path.join(os.homedir(), ".pi/agent");
const installRoot = process.env.PI_MANAGED_INSTALL_ROOT || path.join(agentDir, "install");
const versionFile = path.join(installRoot, "current-version");
const stampFile = path.join(agentDir, "auto-update.stamp");
const logFile = path.join(agentDir, "auto-update.log");

function readVersion(): string | undefined {
  try {
    return readFileSync(versionFile, "utf8").trim();
  } catch {
    return undefined;
  }
}

function piBin(): string {
  const managed = path.join(path.dirname(installRoot), "bin/pi");
  return existsSync(managed) ? managed : "pi";
}

function due(): boolean {
  try {
    return Date.now() - statSync(stampFile).mtimeMs >= INTERVAL_MS;
  } catch {
    return true;
  }
}

export default function (pi) {
  pi.on("session_start", async (event, ctx) => {
    if (event.reason !== "startup") return;
    if (process.env.PI_OFFLINE || process.env.PI_NO_AUTO_UPDATE === "1") return;
    // Without the managed install there is nothing for `pi update` to swap.
    if (!existsSync(versionFile) || !due()) return;

    // Write the stamp first so panes started at the same moment skip.
    writeFileSync(stampFile, `${new Date().toISOString()}\n`);

    const before = readVersion();
    const log = openSync(logFile, "a");
    const child = spawn(piBin(), ["update", "--self", "--no-approve"], {
      cwd: os.homedir(),
      detached: true, // finish even if this pi exits first
      stdio: ["ignore", log, log],
    });
    closeSync(log);
    child.on("error", () => {});
    child.on("exit", (code) => {
      const after = readVersion();
      if (code === 0 && after && after !== before && ctx.hasUI) {
        ctx.ui.notify(`pi ${before} → ${after} 업데이트됨. 다음 실행부터 적용.`, "info");
      }
    });
    child.unref();
  });
}
