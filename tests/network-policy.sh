#!/usr/bin/env bash
set -euo pipefail
SSH=(ssh -J sandbox-admin@10.20.0.1 agent@10.20.0.10)
"${SSH[@]}" curl -fsS --proxy http://10.20.0.1:3128 https://github.com/ -o /dev/null
if "${SSH[@]}" curl -fsS --max-time 10 --proxy http://10.20.0.1:3128 https://example.com/ -o /dev/null; then echo 'allowlist bypass' >&2; exit 1; fi
if "${SSH[@]}" curl -fsS --max-time 10 --noproxy '*' https://1.1.1.1/ -o /dev/null; then echo 'direct egress available' >&2; exit 1; fi
echo 'network policy checks passed'

