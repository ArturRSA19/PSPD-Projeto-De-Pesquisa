#!/usr/bin/env bash
set -euo pipefail

# Minimal comparative latency script: gRPC (via gateway) vs REST services.
# Goal: measure simple avg & p95 for selected endpoints with N iterations.
# Requirements:
#  - Gateway running (gRPC path) exposing /users/{id} and /scores/{userId}
#  - REST User service running (FASTAPI) -> env REST_USERS_BASE (e.g. http://localhost:9001)
#  - REST Stats service running (Go) -> env REST_STATS_BASE (e.g. http://localhost:9002)
#  - Tool: curl + awk + sort (standard)
#
# Usage examples:
#   GATEWAY_BASE=http://localhost:8080 REST_USERS_BASE=http://localhost:9001 REST_STATS_BASE=http://localhost:9002 \
#     ITER=50 ./scripts/quick_compare.sh
#
# Output: table printed to stdout.

GATEWAY_BASE=${GATEWAY_BASE:-http://localhost:8080}
REST_USERS_BASE=${REST_USERS_BASE:-http://localhost:9001}
REST_STATS_BASE=${REST_STATS_BASE:-http://localhost:9002}
ITER=${ITER:-30}
USER_ID=${USER_ID:-1}
TMP_DIR=$(mktemp -d)

now_ms() { python3 - <<'PY'
import time; print(int(time.time()*1000))
PY
}

measure() {
  local label="$1" url="$2"; shift 2
  local file="$TMP_DIR/$label.times"
  for i in $(seq 1 "$ITER"); do
    start=$(now_ms)
    if curl -fs -o /dev/null "$url"; then
      end=$(now_ms)
      echo $((end-start)) >>"$file"
    else
      echo "-1" >>"$file"
    fi
  done
  awk '$1>=0 {print}' "$file" | sort -n > "$file.sorted" || true
  count=$(wc -l < "$file.sorted" || echo 0)
  if [ "$count" -eq 0 ]; then
    echo "$label;N/A;N/A;N/A;0"; return
  fi
  sum=$(awk '{s+=$1} END {print s}' "$file.sorted")
  avg=$(awk -v s="$sum" -v c="$count" 'BEGIN {printf "%.2f", s/c}')
  idx=$(awk -v c="$count" 'BEGIN {printf "%d", (c*0.95<1)?1:int(c*0.95)}')
  p95=$(awk -v i="$idx" 'NR==i {printf "%.2f", $1}' "$file.sorted")
  minv=$(head -n1 "$file.sorted")
  echo "$label;$avg;$p95;$minv;$count"
}

# Warmup (one request each)
warm_urls=( \
  "$GATEWAY_BASE/users/$USER_ID" \
  "$REST_USERS_BASE/users/$USER_ID" \
  "$GATEWAY_BASE/scores/$USER_ID" \
  "$REST_STATS_BASE/scores/$USER_ID" \
)
for u in "${warm_urls[@]}"; do curl -fs -o /dev/null "$u" || true; done

printf "Scenario;Avg_ms;p95_ms;Min_ms;Samples\n"
measure "gRPC-GetUser(gateway)" "$GATEWAY_BASE/users/$USER_ID"
measure "REST-GetUser" "$REST_USERS_BASE/users/$USER_ID"
measure "gRPC-GetScore(gateway)" "$GATEWAY_BASE/scores/$USER_ID"
measure "REST-GetScore" "$REST_STATS_BASE/scores/$USER_ID"

rm -rf "$TMP_DIR"
