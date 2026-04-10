#!/bin/bash
input=$(cat)

# Extract data
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
version=$(echo "$input" | jq -r '.version // ""')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

current_used=$(awk "BEGIN {printf \"%.0f\", ($used_pct * $context_size) / 100}")

fmt() {
  local n=$1
  if [ "$n" -ge 1000000 ] 2>/dev/null; then
    awk "BEGIN {printf \"%.1fM\", $n/1000000}"
  elif [ "$n" -ge 1000 ] 2>/dev/null; then
    awk "BEGIN {printf \"%.1fk\", $n/1000}"
  else
    echo "${n:-0}"
  fi
}

# Progress bar with color
pct_int=$(awk "BEGIN {printf \"%.0f\", ${used_pct:-0}}" 2>/dev/null || echo "0")
filled=$((pct_int / 10))
[ "$filled" -gt 10 ] && filled=10
empty=$((10 - filled))
bar=""
for ((i=0; i<filled; i++)); do bar+="█"; done
for ((i=0; i<empty; i++)); do bar+="░"; done

if [ "$pct_int" -ge 80 ]; then
  color="\033[31m"
elif [ "$pct_int" -ge 50 ]; then
  color="\033[33m"
else
  color="\033[32m"
fi
reset="\033[0m"

cost_str=$(awk "BEGIN {printf \"$%.4f\", $cost}")

printf "%s v%s │ ${color}%s %d%%${reset} (%s/%s) │ %s │ +%d -%d" \
  "$model" "$version" "$bar" "$pct_int" \
  "$(fmt $current_used)" "$(fmt $context_size)" \
  "$cost_str" "$added" "$removed"

