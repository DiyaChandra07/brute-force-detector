# Brute Force / Failed Login Detector

A bash script that scans an authentication log file, counts failed login attempts per source IP, and flags suspicious activity — including a distinct alert for IPs that failed multiple times and then succeeded (a possible compromise indicator).

## What it does

- Parses a log file for `Failed password` and `Accepted password` entries
- Counts failed attempts per source IP
- Flags any IP with more than 3 failed attempts as **SUSPICIOUS**
- Flags any IP that failed multiple times *and* eventually succeeded as **CRITICAL - POSSIBLE COMPROMISE**
- Whitelists known-safe sources (currently just `127.0.0.1` / localhost) so internal noise doesn't get flagged as an external threat
- Outputs a clean, categorized report (Alerts vs Normal/Whitelisted)

## Usage

```bash
bash detector_v1.sh <logfile>
```

To save the report to a file as well as viewing it on screen:
```bash
bash detector_v1.sh <logfile> | tee report.txt
```

Example:
```bash
bash detector_v1.sh sample_auth.log
```

## Files

| File | Purpose |
|---|---|
| `detector_v1.sh` | The main detector script |
| `generate_test_log.sh` | Generates a synthetic test log with realistic normal traffic, a brute-force pattern, a fail-then-success pattern, and localhost noise |
| `sample_auth.log` | Example synthetic log produced by the generator, safe to share/commit |

## How detection works

The script expects standard SSH `auth.log`-style lines, e.g.:
```
Jul 13 10:12:01 server sshd[2841]: Failed password for root from 203.0.113.77 port 51422 ssh2
```

It extracts the source IP (field 11) from every failed and accepted login line, tallies failures per IP using a bash associative array, and cross-references which IPs eventually succeeded.

## Whitelist

Currently whitelists: `127.0.0.1`

This list should be reviewed and expanded with input from the team — internal/monitoring IPs specific to the actual environment should be added here once known. A whitelisted IP with a high failure count may still indicate a misconfigured internal tool and is worth investigating even though it isn't treated as an external threat.

## Limitations / Next Steps

- Currently tested only against **synthetic data** (not yet run against real company logs)
- Threshold (currently `> 3` failures) is hardcoded — could be made configurable via a command-line flag
- Only supports the standard SSH auth.log format — a differently formatted log (e.g. web server access logs, Windows Event Logs) would need a different parsing approach
- Does not yet account for time windows (e.g. distinguishing "5 fails in 1 minute" from "5 fails spread across a week") — all failures for an IP are currently counted regardless of when they occurred
- Next step: request real login logs from the team to validate against actual production data

## Background

Built as a learning project during a SOC internship to understand brute-force detection logic at the log-parsing level, informed by hands-on analysis of real Avaya IP Office / Tomcat web management logs (which surfaced a real localhost-based false-positive pattern that shaped the whitelist design in this script).
