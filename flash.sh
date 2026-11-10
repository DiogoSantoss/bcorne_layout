#!/usr/bin/env bash
# Build the firmware and copy it to the keyboard's UF2 drive.
# Run once per half: plug USB into that half, start this script, then enter
# the bootloader (double-press the PCB reset button, or press QK_BOOT).
set -euo pipefail

QMK_DIR="${QMK_DIR:-$HOME/dev/qmk}"
KEYMAP_NAME="${KEYMAP_NAME:-dsantos}"
VIAL_QMK="$QMK_DIR/vial-qmk"
UF2="$VIAL_QMK/.build/m57_bcorne_${KEYMAP_NAME}.uf2"

(cd "$VIAL_QMK" && qmk compile -kb m57_bcorne -km "$KEYMAP_NAME")

find_drive() {
	for dir in /Volumes/* "/run/media/$USER"/* "/media/$USER"/*; do
		[ -f "$dir/INFO_UF2.TXT" ] && { echo "$dir"; return 0; }
	done
	return 1
}

echo "waiting for the UF2 drive (enter the bootloader on the half to flash)..."
until drive="$(find_drive)"; do sleep 1; done

echo "flashing $UF2 -> $drive"
cp "$UF2" "$drive/"
sync
echo "done. Repeat for the other half."
