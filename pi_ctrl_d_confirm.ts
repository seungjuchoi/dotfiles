// Ctrl+D twice to exit, the way Claude Code does it.
//
// pi exits on the first Ctrl+D when the editor is empty. This extension swaps
// in an editor that shows "Ctrl+D 한 번 더 누르면 종료" in the footer on the
// first press and exits only if Ctrl+D comes again within CONFIRM_MS. Any other
// key cancels. With text in the editor Ctrl+D still deletes forward as before.
// Only the main editor is affected; Ctrl+D in /resume (delete session) is not.
// Installed by dotfiles 3_set_config.fish as ~/.pi/agent/extensions/ctrl-d-confirm.ts.
// @ts-nocheck

import { CustomEditor } from "@earendil-works/pi-coding-agent";

const CONFIRM_MS = 1500;
const STATUS_KEY = "ctrl-d-confirm";

export default function (pi) {
  pi.on("session_start", (_event, ctx) => {
    if (!ctx.hasUI) return;

    let armedUntil = 0;
    let timer;
    const disarm = () => {
      armedUntil = 0;
      if (timer) clearTimeout(timer);
      timer = undefined;
      ctx.ui.setStatus(STATUS_KEY, undefined);
    };

    class ConfirmExitEditor extends CustomEditor {
      handleInput(data) {
        const isExit = this.keybindings.matches(data, "app.exit") && this.getText().length === 0;
        if (!isExit) {
          if (armedUntil) disarm();
          super.handleInput(data);
          return;
        }
        if (Date.now() < armedUntil) {
          disarm();
          super.handleInput(data); // CustomEditor runs pi's exit handler
          return;
        }
        armedUntil = Date.now() + CONFIRM_MS;
        if (timer) clearTimeout(timer);
        timer = setTimeout(disarm, CONFIRM_MS);
        ctx.ui.setStatus(STATUS_KEY, ctx.ui.theme.fg("warning", "Ctrl+D 한 번 더 누르면 종료"));
      }
    }

    ctx.ui.setEditorComponent(
      (tui, theme, keybindings) => new ConfirmExitEditor(tui, theme, keybindings, { embedWorkingStatus: true }),
    );
  });
}
