#!/usr/bin/env bash
# Prepare a vial-qmk tree that can build this keymap. Safe to re-run.
#
#   $QMK_DIR/vial-qmk                           Vial fork of QMK
#   $QMK_DIR/ymdk-BCorne_M57-RGB                BCorne M57 keyboard definition
#   vial-qmk/keyboards/m57_bcorne            -> keyboard definition
#   vial-qmk/keyboards/m57_bcorne/keymaps/dsantos -> this repo
set -euo pipefail

QMK_DIR="${QMK_DIR:-$HOME/dev/qmk}"
KEYMAP_NAME="${KEYMAP_NAME:-dsantos}"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
VIAL_QMK="$QMK_DIR/vial-qmk"
KB_REPO="$QMK_DIR/ymdk-BCorne_M57-RGB"

for cmd in git qmk arm-none-eabi-gcc; do
	command -v "$cmd" >/dev/null || { echo "missing: $cmd (see README)" >&2; exit 1; }
done

mkdir -p "$QMK_DIR"

if [ ! -d "$VIAL_QMK" ]; then
	git clone --depth 1 https://github.com/vial-kb/vial-qmk "$VIAL_QMK"
	git -C "$VIAL_QMK" submodule update --init --recursive --depth 1
fi

if [ ! -d "$KB_REPO" ]; then
	git clone https://github.com/kolbenhans/ymdk-BCorne_M57-RGB "$KB_REPO"
fi

ln -sfn "$KB_REPO/m57_bcorne" "$VIAL_QMK/keyboards/m57_bcorne"
ln -sfn "$REPO_DIR" "$KB_REPO/m57_bcorne/keymaps/$KEYMAP_NAME"
cp "$KB_REPO"/ld/*.ld "$VIAL_QMK/platforms/chibios/boards/common/ld/"

echo "ready: cd $VIAL_QMK && qmk compile -kb m57_bcorne -km $KEYMAP_NAME"
