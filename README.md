# Brute Force / Failed Login Detector

A bash script I built during my SOC internship to practice log analysis and brute-force detection logic.

It reads a login/auth log file, counts failed attempts per IP, and flags anything that looks suspicious — including a specific warning if an IP failed several times and then succeeded, since that's a stronger sign of an actual compromise than failures alone.

## Usage

```bash
bash detector_v1.sh <logfile>
```

You'll be prompted for a destination/internal IP to ignore. This is useful when a log line contains both a source IP and a destination IP — press Enter to skip if it doesn't apply.

To view the report and save it to a file at the same time:
```bash
bash detector_v1.sh <logfile> | tee report.txt
```

Example:
```bash
bash detector_v1.sh sample_auth.log
```

## What it flags

| Label | Meaning |
|---|---|
| `[CRITICAL]` | IP failed 3+ times, then succeeded — possible compromise |
| `[WARNING]` | IP failed more than 3 times, no success yet |
| `[INFO]` | Normal activity, or a whitelisted source |

## Files

| File | Purpose |
|---|---|
| `detector_v1.sh` | The detector script |
| `generate_test_log.sh` | Generates a synthetic auth log to test against |
| `sample_auth.log` | Sample output from the generator |

## How it extracts IPs

Rather than assuming the IP always sits in a fixed position (e.g. "always the 11th word"), the script asks once at the start for a destination/internal IP to treat as constant. Then, for every line, it pulls out every IP-shaped value found on that line and skips any that match the destination IP — whatever's left is treated as the source IP. This makes it more adaptable across different log formats than hardcoding a field number, as long as each line has at most one source IP and one destination IP.

It identifies failed vs. successful lines by searching for the words "fail" and "success" (case-insensitive). If a real log uses different wording — e.g. "denied" or "authenticated" — those keywords need to be updated at the top of the script.

## Known limitations

- Tested on synthetic data and one real sample so far — not yet validated against full production logs
- The failure threshold (3) and the fail/success keywords are hardcoded, not configurable via flags yet
- If a line has more than 2 IPs (i.e. more than one source or destination), the script just takes the first non-destination IP it finds — this may not always be correct for more complex formats
- No time-window logic yet — 5 failures in one minute and 5 failures spread across a week are currently treated the same

## Why the whitelist exists

While reviewing some real web management logs earlier in this internship, I found a large number of failed login attempts all coming from `127.0.0.1` (localhost). It turned out to likely be an internal script running with the wrong credentials, not an actual attack. That's the reasoning behind treating localhost as a separate, lower-priority category instead of flagging it the same as an external IP.

## Next steps

- Get real login logs from the team to test against production data
- Make the threshold and fail/success keywords configurable instead of hardcoded
- Add time-window logic so a burst of failures is treated differently than the same count spread over days
