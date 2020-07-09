#!/bin/bash
msg="
:gift: *Alces Flight* :runmooserun: _Package Published_ :gift:\n
*Name:* \`$PACKAGE\`\n
*Repo:* \`$REPO\`\n
*Tree:* https://github.com/alces-flight/alces-flight-omnibus-builder/commit/$(git rev-parse --short HEAD)\n
*Package URL:* $PACKAGE_URL"

cat <<EOF | curl --data @- -X POST -H "Authorization: Bearer $SLACK_TOKEN" -H 'Content-Type: application/json' https://slack.com/api/chat.postMessage
{
  "text": "$msg",
  "channel": "packaging",
  "as_user": true
}
EOF
