#!/usr/bin/env fish

set DOTFILES_DIR (cd (dirname (status filename)); and pwd)

mkdir -p ~/.claude
ln -sf $DOTFILES_DIR/AGENTS_global.md ~/.claude/CLAUDE.md

mkdir -p ~/.codex
ln -sf $DOTFILES_DIR/AGENTS_global.md ~/.codex/AGENTS.md

echo "AGENTS_global.md linked to ~/.claude/CLAUDE.md and ~/.codex/AGENTS.md"
