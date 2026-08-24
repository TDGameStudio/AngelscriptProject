# Planning Decisions

1. The change ID is `test-as-source-generation-rules`.
2. This OpenSpec creation pass changes only its own directory.
3. `TestSource` is the future source/rule authority; `script-corpus` is retired as a design direction.
4. `Tools/AngelscriptCodeGen` hosts Python and portable C++ development implementations.
5. Python and C++ independently implement the same specification and must emit byte-identical canonical outputs.
6. Explicit matrices are always exhaustive; randomness can vary only declared legal slots.
7. Observable RNG is versioned `SplitMix64-v1` with FNV-1a identity input, rejection sampling, deterministic Fisher-Yates, and named substreams.
8. Generation is in memory by default; only explicit Saved/temp, small golden, and release modes write files.
9. The plugin retains only generated C++ release artifacts.
10. The unified plugin class is `FAngelscriptTestCode`.
11. There is one static function per authored fixture or generated product/candidate, not per expanded matrix cell.
12. Static functions return a complete `FAngelscriptGeneratedCase`, including source, manifest, typed oracle, axes, seed, comments, and references.
13. Generic lookup/enumeration uses generated sorted data; static registrars and ForceLink are excluded.
14. AS comments carry knowledge facts but have no universal rigid prose template.
15. Negative cases are one named mutation from a valid baseline and include recovery source when the reference oracle requires it.
16. All 614 manual-bind source paths, 271 SDK products, 1,022 Coverage methods, and current inline AS units are inventoried.
17. Existing tests/builders are not replaced in this change; adoption receives a separate OpenSpec.
