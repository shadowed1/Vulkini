#!/bin/bash
VENV="$HOME/.venvs/mesa"
PY_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
if ! dpkg -s python${PY_VER}-venv >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y python${PY_VER}-venv
fi
if [ ! -d "$VENV" ]; then
    echo "[vulkini_pip] Creating venv at $VENV"
    python3 -m venv "$VENV"
    source "$VENV/bin/activate"
    pip install --upgrade pip
    pip install meson ninja mako pyyaml ply MarkupSafe
    deactivate
fi
if [ "$1" = "activate" ]; then
    exec bash --rcfile <(echo "source $VENV/bin/activate")
fi
source "$VENV/bin/activate"
"$@"
deactivate
