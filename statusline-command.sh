#!/usr/bin/env bash

input=$(cat)

# --- Extract fields ---
model=$(echo "$input" | jq -r '.model.display_name // "Unknown Model"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
cache_write=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')

# --- ANSI colors ---
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

FG_WHITE="\033[97m"
FG_CYAN="\033[36m"
FG_YELLOW="\033[33m"
FG_GREEN="\033[32m"
FG_RED="\033[31m"
FG_MAGENTA="\033[35m"
FG_BLUE="\033[34m"
FG_GRAY="\033[90m"

# --- Git branch (skip optional lock) ---
git_branch=""
if [ -n "$cwd" ]; then
  git_branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
fi

# --- Context bar (10 blocks) ---
context_bar=""
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  filled=$(( used_int * 10 / 100 ))
  [ $filled -gt 10 ] && filled=10
  empty=$(( 10 - filled ))

  if [ "$used_int" -ge 80 ]; then
    bar_color="$FG_RED"
  elif [ "$used_int" -ge 50 ]; then
    bar_color="$FG_YELLOW"
  else
    bar_color="$FG_GREEN"
  fi

  bar=""
  for i in $(seq 1 $filled); do bar="${bar}█"; done
  for i in $(seq 1 $empty);  do bar="${bar}░"; done

  context_bar=$(printf "${bar_color}${bar}${RESET} ${DIM}${used_int}%%${RESET}")
fi

# --- Session cost estimate ---
# Pricing for claude-opus-4-6 (per million tokens):
#   Input:        $15.00   Cache write: $18.75   Cache read: $1.50   Output: $75.00
input_cost=$(echo "$total_input $cache_write $cache_read $total_output" | awk '{
  base   = ($1 - $2 - $3) * 15.00    / 1000000
  cwrite = $2              * 18.75   / 1000000
  cread  = $3              * 1.50    / 1000000
  out    = $4              * 75.00   / 1000000
  total  = base + cwrite + cread + out
  if (total < 0) total = 0
  printf "$%.4f", total
}')

# --- Assemble output ---
parts=()

# Model
parts+=("$(printf "${BOLD}${FG_CYAN}%s${RESET}" "$model")")

# Git branch
if [ -n "$git_branch" ]; then
  parts+=("$(printf "${FG_MAGENTA} %s${RESET}" "$git_branch")")
fi

# Context bar
if [ -n "$context_bar" ]; then
  parts+=("$(printf "ctx ${context_bar}")")
fi

# Session cost
parts+=("$(printf "${FG_GRAY}%s${RESET}" "$input_cost")")

# Join with separators
output=""
for part in "${parts[@]}"; do
  if [ -z "$output" ]; then
    output="$part"
  else
    output="$(printf "%s ${DIM}|${RESET} %s" "$output" "$part")"
  fi
done

printf "%b\n" "$output"
