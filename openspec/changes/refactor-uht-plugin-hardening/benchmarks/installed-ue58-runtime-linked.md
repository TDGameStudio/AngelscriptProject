# Installed UE 5.8 Runtime-linked benchmark

Environment: installed UE 5.8, `AngelscriptProjectEditor`, Win64 Development, `-NoXGE`.

| Metric | Before hardening baseline | Current result |
|---|---:|---:|
| UHT analyzed functions | 5,830 | 5,830 |
| Runtime-linked functions | 1,247 | 1,247 |
| Reflective fallback functions | 4,583 | 4,583 |
| UHT generated shards | 29 | 29 |
| Generated Runtime aggregators | 704 fixed wrapper translation units | 11 per-module aggregators |
| Generated shard source size | not captured | 870,853 bytes |
| Shard include directives | approximately 224 repeated per Engine shard | 527 total, 37 maximum per shard |
| UHT generation time | not captured | 9.12 seconds |
| Full build time | not captured | 72.10 seconds (`7/7` actions) |

The current output preserves the shard count and analyzed-function distribution while reducing generated wrapper translation units from the fixed wrapper set to one aggregator per configured module. The aggregator still uses conditional includes for the configured shard cap, so a future benchmark should separately measure compile time after changing the cap or moving to a generated manifest.

Source-engine target-module generation was exercised separately and produced 373 native target bindings, 3 generated files, and 3,679 skipped diagnostics. Its full C++ build remains blocked by the existing UE 5.8 source compatibility gap in the available UE 5.7.2 checkout; see `verification.md`.
