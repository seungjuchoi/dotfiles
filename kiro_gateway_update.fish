#!/usr/bin/env fish
# Install or update jwadow/kiro-gateway into ~/.local/share/kiro-gateway
# and re-apply the local Claude Code patches (Opus 5 model list, system role).

set -g REPO $HOME/.local/share/kiro-gateway
set -g ORIGIN_URL https://github.com/jwadow/kiro-gateway.git
set -g SCRIPT_DIR (dirname (status --current-filename))
set -g PATCH $SCRIPT_DIR/tools/kiro-gateway/local.patch

function info
    echo "› $argv" >&2
end

function die
    echo "✗ $argv" >&2
    exit 1
end

function find_python
    for py in python3.13 python3.12 python3.11 python3.10 python3
        if type -q $py
            set -l ver ($py -c 'import sys; print("%d.%d" % sys.version_info[:2])')
            set -l major (string split . $ver)[1]
            set -l minor (string split . $ver)[2]
            if test $major -gt 3; or test $major -eq 3 -a $minor -ge 10
                echo $py
                return 0
            end
        end
    end
    return 1
end

if not type -q git
    die "git not found"
end

if test -d $REPO/.git
    info "updating $REPO"
    git -C $REPO fetch --quiet origin
    or die "git fetch failed"
    git -C $REPO reset --hard --quiet origin/main
    or git -C $REPO reset --hard --quiet origin/master
    or die "git reset failed"
else if test -e $REPO
    die "path exists but is not a git repo: $REPO"
else
    info "cloning $ORIGIN_URL → $REPO"
    mkdir -p (dirname $REPO)
    git clone --depth=1 $ORIGIN_URL $REPO
    or die "git clone failed"
end

if test -f $PATCH
    if git -C $REPO apply --check $PATCH >/dev/null 2>&1
        info "applying local patches"
        git -C $REPO apply $PATCH
        or die "failed to apply $PATCH"
    else if git -C $REPO apply -R --check $PATCH >/dev/null 2>&1
        info "local patches already applied"
    else
        echo "⚠ local patch did not apply cleanly; continuing with upstream" >&2
    end
end

set -l py (find_python)
or die "Python 3.10+ required (brew install python@3.13)"

if not test -x $REPO/.venv/bin/python
    info "creating venv with $py"
    $py -m venv $REPO/.venv
    or die "venv create failed"
end

info "installing Python deps"
$REPO/.venv/bin/pip install -q -U pip
or die "pip upgrade failed"
$REPO/.venv/bin/pip install -q -r $REPO/requirements.txt
or die "pip install failed"

echo "✓ kiro-gateway ready at $REPO" >&2
