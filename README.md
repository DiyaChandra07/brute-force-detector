# Brute Force / Failed Login Detector

A small bash script I built during my SOC internship to practice log analysis and detection logic.

It reads an auth log file, counts failed login attempts per IP, and flags anything suspicious.

## Usage

```bash
bash detector_v1.sh <logfile>
```

To also save the output to a file:
```bash
bash detector_v1.sh <logfile> | tee report.txt
```

Example:
```bash
bash detector_v1.sh sample_auth.log
```

## What it checks for

- Counts failed login attempts per IP
- Flags an IP as **SUSPICIOUS** if it has more than 3 failed attempts
- Flags an IP as **CRITICAL** if it failed several times and then had a successful login (possible compromise)
- Whitelists `127.0.0.1` (localhost) so internal traffic isn't treated as an external threat

## Files

- `detector_v1.sh` — the actual script
- `generate_test_log.sh` — generates a fake test log to run the script against
- `sample_auth.log` — example output from the generator

## Notes

- Only tested on synthetic/fake data so far, not real company logs yet
- Threshold for "too many fails" (3) is hardcoded right now
- Only works with standard SSH auth.log format
- Doesn't account for time windows yet (e.g. 5 fails in a minute vs 5 fails spread over a week look the same right now)

## Why the whitelist exists

While looking through some real web management logs earlier in this internship, I found a large number of failed login attempts all coming from `127.0.0.1` (localhost) — turned out to likely be an internal script with wrong credentials, not an actual attack. That's why this script treats localhost separately instead of flagging it the same as an external IP.
