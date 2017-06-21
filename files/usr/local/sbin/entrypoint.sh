#!/bin/sh
set -e

# initialize workspace
chown -R "$SPONGE_USER":"$SPONGE_GROUP" "$SPONGE_WORKSPACE"

# execute user command
exec "$@"
