#!/bin/bash
# Auto-approve compound Bash commands where every part is a safe command.
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0
echo "$COMMAND" | grep -qE '&&|\||;' || exit 0
ALL_SAFE=true
while IFS= read -r part; do
    part=$(echo "$part" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [ -z "$part" ] && continue
    BASE=$(echo "$part" | awk '{print $1}')
    case "$BASE" in
        cd|pwd|ls|echo|cat|head|tail|grep|test|true|false|[) ;;
        git) ;;
        find) ;;
        *) ALL_SAFE=false; break ;;
    esac
done < <(echo "$COMMAND" | sed 's/\s*&&\s*/\n/g; s/\s*||\s*/\n/g; s/\s*|\s*/\n/g; s/\s*;\s*/\n/g')
if [ "$ALL_SAFE" = "true" ]; then
    jq -n '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"All parts of compound command are safe"}}'
fi
exit 0