#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Open Clipboard URL in Active Chrome
# @raycast.mode silent
# @raycast.packageName Utils
# @raycast.icon 📋

set -euo pipefail

clip="$(pbpaste | head -n 1 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"

if [ -z "$clip" ]; then
  echo "クリップボードが空っぽ"
  exit 0
fi

# スキーム無ければ https:// を足す
case "$clip" in
  http://*|https://*) url="$clip" ;;
  *) url="https://$clip" ;;
esac

/usr/bin/osascript - "$url" <<'APPLESCRIPT'
on run argv
  set theURL to item 1 of argv
  tell application "Google Chrome"
    activate
    if (count of windows) = 0 then
      make new window
    end if
    tell front window
      make new tab with properties {URL:theURL}
      set active tab index to (count of tabs)
    end tell
  end tell
end run
APPLESCRIPT

echo "Opened: $url"
