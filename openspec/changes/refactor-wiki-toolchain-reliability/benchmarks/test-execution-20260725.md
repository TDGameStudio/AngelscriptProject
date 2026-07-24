# Test-execution implementation evidence — 2026-07-25

This workstation currently has Node `25.5.0` and no `pnpm` command. It is not the supported Node 24/pnpm 11.8.0 baseline, so the measurements below do not complete task 7.4 and must not be used as release evidence.

| Command | Result | Duration |
|---|---:|---:|
| Direct Node fast-contract aggregation (70 tests; no artifact publish or test port) | 70 passed | 1.90 s |
| TypeScript check (`node node_modules/typescript/bin/tsc --noEmit --skipLibCheck`) | passed | 1.9 s |
| `node scripts/run-product-tests.mjs feature shell` | 3 passed | 7.9 s |
| `node scripts/run-product-tests.mjs smoke` | 6 passed | 10.7 s |
| Targeted `code` clipboard regression | 2 passed | 10.6 s |

The fast-layer Node aggregation intentionally excludes the offline publisher and fixed-port artifact server. Those checks are part of explicit `integration`/`release` escalation, so the ordinary loop never publishes an artifact or reserves port `4173`. The 30-second `test:fast` budget remains pending measurement on the required Node 24/pnpm 11.8.0 environment, where the actual package command also runs local lint.
