#!/bin/bash

#counting fails
declare -A fail_count
whitelist="127.0.0.1"

is_whitelisted() {
    local check_ip="$1"
    for safe_ip in $whitelist; do
        if [ "$check_ip" == "$safe_ip" ]; then
            return 0
        fi
    done
    return 1
}


ip_list=$(grep "Failed password" sample_auth.log | awk '{print $11}')

for ip in $ip_list; do

	fail_count["$ip"]=$(( ${fail_count["$ip"]:-0} + 1 ))

done

#counting successes
declare -A success_ips

success_list=$(grep "Accepted password" sample_auth.log | awk '{print $11}')

for ip in $success_list; do
    success_ips["$ip"]=1
done

#output line
echo "=== Brute Force Detection Report ==="
echo "Scan time: $(date)"
echo "Log file: sample_auth.log"
echo ""

echo "--- ALERTS ---"
for key in "${!fail_count[@]}"; do
    count=${fail_count[$key]}
    if is_whitelisted "$key"; then
        continue
    elif [ -n "${success_ips[$key]}" ] && [ $count -gt 3 ]; then
        echo "[CRITICAL] $key => $count fails then SUCCESS - POSSIBLE COMPROMISE!"
    elif [ $count -gt 3 ]; then
        echo "[WARNING] $key => $count FAILS (SUSPICIOUS)"
    fi
done

echo ""
echo "--- NORMAL / WHITELISTED ---"
for key in "${!fail_count[@]}"; do
    count=${fail_count[$key]}
    if is_whitelisted "$key"; then
        echo "[INFO] $key => $count fails (WHITELISTED - internal/known source)"
    elif [ $count -le 3 ]; then
        echo "[INFO] $key => $count fails (normal)"
    fi
done
