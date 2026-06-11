#!/usr/bin/env bash
# ~/.claude/statusline.sh
# Claude Code カスタムステータスライン（3行構成）
#   1行目: ディレクトリ | Git ブランチ
#   2行目: モデル | コンテキスト% | 5h レート制限 | 7d レート制限
#   3行目: セッション課金 | 当日累計（円換算）
#
# 依存: jq（必須） / ccusage(daily 表示に使用・任意)

input=$(cat)

# ============ 設定 ============
JPY_RATE=157        # USD -> JPY 換算レート（適宜更新）
ENABLE_DAILY=1      # 1 で ccusage による当日累計を表示、0 で非表示

# ============ 色 ============
DIM='\033[2m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; BLUE='\033[34m'; RESET='\033[0m'

# ============ JSON 抽出 ============
DIR=$(echo "$input"        | jq -r '.workspace.current_dir // ""')
MODEL=$(echo "$input"      | jq -r '.model.display_name // "?"')
CTX=$(echo "$input"        | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
SESSION_USD=$(echo "$input"| jq -r '.cost.total_cost_usd // 0')

FIVE_PCT=$(echo "$input"   | jq -r '.rate_limits.five_hour.used_percentage // empty')
FIVE_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
WEEK_PCT=$(echo "$input"   | jq -r '.rate_limits.seven_day.used_percentage // empty')
WEEK_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# ============ Git ブランチ ============
BRANCH=""
git rev-parse --git-dir >/dev/null 2>&1 && BRANCH=$(git branch --show-current 2>/dev/null)

# ============ ユーティリティ ============
# epoch -> HH:MM （GNU date / BSD(macOS) date 両対応）
fmt_time() { [ -z "$1" ] && return; date -d "@$1" +%H:%M 2>/dev/null || date -r "$1" +%H:%M 2>/dev/null; }
# epoch -> M/D HH:MM
fmt_date() {
  [ -z "$1" ] && return
  local d
  d=$(date -d "@$1" "+%m/%d %H:%M" 2>/dev/null || date -r "$1" "+%m/%d %H:%M" 2>/dev/null)
  echo "$d" | sed 's/^0//'   # 月の先頭ゼロを除去 (06/14 -> 6/14)
}
# 数値に 3桁区切りカンマ
commafy() { echo "$1" | sed -e ':a' -e 's/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/;ta'; }
# USD -> JPY（四捨五入の整数）
to_jpy() { awk -v u="$1" -v r="$JPY_RATE" 'BEGIN{printf "%d", u*r+0.5}'; }

FIVE_RESET_F=$(fmt_time "$FIVE_RESET")
WEEK_RESET_F=$(fmt_date "$WEEK_RESET")
SESSION_JPY=$(commafy "$(to_jpy "$SESSION_USD")")

# ============ 当日累計（ccusage） ============
DAILY_JPY=""
if [ "$ENABLE_DAILY" = "1" ]; then
  TODAY=$(date +%Y%m%d)
  # ccusage / bunx / npx のいずれかを使用
  if command -v ccusage >/dev/null 2>&1; then CCMD="ccusage"
  elif command -v bunx >/dev/null 2>&1; then CCMD="bunx ccusage"
  elif command -v npx  >/dev/null 2>&1; then CCMD="npx -y ccusage"
  else CCMD=""; fi
  if [ -n "$CCMD" ]; then
    DAILY_USD=$($CCMD daily --json --since "$TODAY" --until "$TODAY" 2>/dev/null \
                | jq -r '[.daily[].totalCost] | add // 0' 2>/dev/null)
    [ -n "$DAILY_USD" ] && [ "$DAILY_USD" != "0" ] && DAILY_JPY=$(commafy "$(to_jpy "$DAILY_USD")")
  fi
fi

# ============ コンテキスト% の色分け ============
if   [ "${CTX:-0}" -ge 90 ]; then CTX_COL=$RED
elif [ "${CTX:-0}" -ge 70 ]; then CTX_COL=$YELLOW
else CTX_COL=$GREEN; fi

# ============ 出力（3行） ============
# 1行目
LINE1="${BLUE}📁 ${DIR##*/}${RESET}"
[ -n "$BRANCH" ] && LINE1="$LINE1 ${DIM}|${RESET} ${GREEN}🌿 ${BRANCH}${RESET}"
echo -e "$LINE1"

# 2行目
LINE2="⛁ ${MODEL} ${DIM}|${RESET} ${CTX_COL}📈 ${CTX}%${RESET}"
[ -n "$FIVE_PCT" ] && LINE2="$LINE2 ${DIM}|${RESET} 🕐 5h $(printf '%.0f' "$FIVE_PCT")% ⟳ ${FIVE_RESET_F}"
[ -n "$WEEK_PCT" ] && LINE2="$LINE2 ${DIM}|${RESET} 📅 7d $(printf '%.0f' "$WEEK_PCT")% ⟳ ${WEEK_RESET_F}"
echo -e "$LINE2"

# 3行目
LINE3="💲¥${SESSION_JPY} (session)"
[ -n "$DAILY_JPY" ] && LINE3="$LINE3 ${DIM}|${RESET} 💲¥${DAILY_JPY} (daily)"
echo -e "$LINE3"
