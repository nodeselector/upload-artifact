#!/bin/sh
set -eou pipefail

PROGRAM="$(realpath "$1")"
shift

if [[ -z $BLOB_NAME ]]; then
    echo "no blob name provided"
    exit 1
fi

OUTPUT="$BLOB_NAME.trace"
xcrun xctrace record \
  --template ./vm.tracetemplate \
  --no-prompt \
  --output "$OUTPUT" \
  --target-stdout - \
  --launch -- "$PROGRAM" "$@"