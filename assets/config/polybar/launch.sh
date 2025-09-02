#!/usr/bin/env bash
set -euo pipefail

# Stop any running polybar instances cleanly, then hard-stop as fallback
if command -v polybar-msg >/dev/null 2>&1; then
	polybar-msg cmd quit >/dev/null 2>&1 || true
fi

if command -v pkill >/dev/null 2>&1; then
	pkill -u "${USER:-$(id -un)}" -x polybar >/dev/null 2>&1 || true
elif command -v killall >/dev/null 2>&1; then
	killall -q polybar || true
fi

# Wait until all polybar processes have exited
while pgrep -u "${USER:-$(id -un)}" -x polybar >/dev/null 2>&1; do
	sleep 0.3
done

# Launch bar(s) for all connected monitors
if command -v polybar >/dev/null 2>&1; then
	if polybar --list-monitors >/dev/null 2>&1; then
		mapfile -t monitors < <(polybar --list-monitors | cut -d: -f1)
	elif command -v xrandr >/dev/null 2>&1; then
		mapfile -t monitors < <(xrandr --listmonitors | awk 'NR>1 {print $4}')
	else
		monitors=("${MONITOR:-eDP-1}")
	fi

	if [ ${#monitors[@]} -eq 0 ]; then
		monitors=("${MONITOR:-eDP-1}")
	fi

	for m in "${monitors[@]}"; do
		MONITOR="$m" polybar example &
	done
fi
