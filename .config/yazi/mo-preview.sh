#!/bin/bash
# Open Markdown file with mo in cmux browser
file="$1"
port=6275

# 既存のmoプロセスを落としてから起動（重複防止）
pkill -f "grip .* $port" 2>/dev/null
grip "$file" "$port" >/dev/null 2>&1 &
sleep 1

# cmuxの同一ペインの別タブでブラウザを開く
surf=$(cmux identify | jq -r '.caller.surface_ref')
cmux browser "$surf" tab new "http://127.0.0.1:$port/"
