#!/bin/bash
# Layout preset: arrange two windows into a 2/3 + 1/3 horizontal split.
#
# Usage:
#   dev.sh         — focused window becomes ~2/3 (default)
#   dev.sh narrow  — focused window becomes ~1/3
#
# The resize delta is based on monitor count as a rough heuristic:
#   External monitor (~2560px) → 450
#   Laptop only (~1440-1512px) → 260
# Tweak these values if the ratio doesn't look right on your displays.

DIRECTION="${1:-wide}"

MONITOR_COUNT=$(aerospace list-monitors 2>/dev/null | wc -l | tr -d ' ')

if [ "$MONITOR_COUNT" -gt 1 ]; then
  DELTA=450
else
  DELTA=260
fi

aerospace flatten-workspace-tree
aerospace layout tiles horizontal
aerospace balance-sizes

if [ "$DIRECTION" = "narrow" ]; then
  aerospace resize width "-$DELTA"
else
  aerospace resize width "+$DELTA"
fi
