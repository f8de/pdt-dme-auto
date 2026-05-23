#!/bin/sh
# Run once after cloning: sh scripts/install-hooks.sh
HOOK=.git/hooks/post-push
cp scripts/post-push.hook "$HOOK"
chmod +x "$HOOK"
echo "post-push hook installed."
