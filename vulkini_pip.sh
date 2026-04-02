#!/bin/bash
VENV="$HOME/.venvs/mesa"
PY_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
if ! dpkg -s python${PY_VER}-venv >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y python${PY_VER}-venv
fi
if [ ! -f "$VENV/bin/activate" ]; then
    echo "[vulkini_meson] Creating venv at $VENV"
    python3 -m venv "$VENV"
    source "$VENV/bin/activate"
    echo "[vulkini_meson] Installing meson + ninja"
    pip install --upgrade pip
    pip install meson ninja
else
    source "$VENV/bin/activate"
fi

"$@"

if command -v deactivate >/dev/null 2>&1; then
    deactivate
fi
