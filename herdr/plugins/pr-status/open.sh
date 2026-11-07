#!/bin/sh
# Action entrypoint: open the PR status popup pane.
exec "$HERDR_BIN_PATH" plugin pane open --plugin georgef.pr-status --entrypoint board
