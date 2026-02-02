#!/usr/bin/env fish

set DOTFILES_DIR (cd (dirname (status filename)); and pwd)

mkdir -p ~/.claude
cp $DOTFILES_DIR/CLAUDE_Global.md ~/.claude/CLAUDE.md

echo "CLAUDE.md applied to ~/.claude/CLAUDE.md"
