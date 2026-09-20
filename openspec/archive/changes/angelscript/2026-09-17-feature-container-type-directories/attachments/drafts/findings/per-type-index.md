# Nine-type exploration index

Source: draft finding (Chinese original; approval R2/R6). Nine explore subagents read pockets, binds, and Pending. This file keeps order; trees live in [per-type-trees.md](per-type-trees.md).

## Quality severity

```
TMap          // three dumps ~1400 lines; highest C4883 risk
  TArray      // tag/body mismatch; truncated class
  TSoftObjectPtr  // SYNTAX; not a compile baseline
  TObjectPtr / TWeakObjectPtr / TSubclassOf / TSet / TOptional
  SoftObjectPath  // cleanest; placeholder summaries
```

## Shared rules

- FileTag is `Containers/<Type>/<Observation>`. Trees follow each bind surface.
- Do not dump Pending. Hand-split, rename, and add from that type's list.
- One observation per `@begin`. Type and `&in`/`&out` variants are their own files.
- No conversion scripts.
- Counts, Fail directories, and type-axis files follow Bind evidence.

## Quality first, then coverage

| type | first | then |
|---|---|---|
| TMap | split the three dumps; fix duplicate symbols | fix wrong summaries |
| TArray | rename `array`; drop `// Last() is 40`; repair truncated UObject; drop duplicate set-num | split assignment |
| TSet | repair struct/UObject blocks | drop duplicate add/contains/remove |
| TOptional | close property class; drop reset/overwrite dupes | split assignment |
| TSoftObjectPtr | repair SYNTAX and names; move SoftObjectPath case | RuntimeFail if Bind forbids |
| TWeakObjectPtr | clear fragments | IsStale after GC |
| TSubclassOf | clear fragments | extra write Throws |
| TObjectPtr | clear CORRUPT comments | RoundTrip |
| SoftObjectPath | fix summaries; rename Queries_02 | Fail only if Bind diagnoses |

Named coverage: [coverage-wave.md](coverage-wave.md). Fail oracle: [fail-siblings.md](fail-siblings.md).
