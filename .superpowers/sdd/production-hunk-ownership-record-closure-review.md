# Production Hunk Ownership Record Closure — Independent Review

Date: 2026-07-27

## Verdict

- **Spec compliance: FAIL**
- **Code/record quality: FAIL**
- **Ranked findings: 1**

The 164-hunk ownership reconciliation itself is complete and internally
consistent. The failure is narrower: the double-to-64-bit OpenSpec names an
existing StaticJIT regression that does not exercise the conversion direction,
integer width, or generated-code path claimed by the record and required by its
specification.

## Ranked Finding

### [High] The claimed StaticJIT double-to-int64 parity owner tests the opposite conversion

The new `fix-as-double-int64-bytecode-execution` record identifies
`FAngelscriptStaticJITPrimitiveConversionTests::BitCastAndNumericParity` as the
secondary parity owner:

- `proposal.md:41-42`;
- `background.md:27`;
- checked `tasks.md:5`;
- pending execution task `tasks.md:17`; and
- the closure report at
  `.superpowers/sdd/production-hunk-ownership-record-closure-report.md:33`.

That ownership claim does not match the current test implementation:

- `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptStaticJITPrimitiveConversionTests.cpp:186`
  calls `ConvertPrimitiveValue<double, int>(-1)`;
- line 187 calls
  `ConvertPrimitiveValue<double, asDWORD>(0xFFFFFFFFu)`;
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StaticJITHeader.h:328-331`
  defines the template as `OutT ConvertPrimitiveValue(InT InValue)`.

The test therefore covers signed/unsigned **32-bit integer to double**
conversion. It does not cover double to signed/unsigned 64-bit conversion.
Moreover, the method directly calls the conversion helper; it does not compile
or execute generated StaticJIT code for `asBC_dTOi64` or `asBC_dTOu64`.

This conflicts with the delta specification at
`specs/as-double-int64-bytecode-execution/spec.md:23-33`, which requires
interpreter and StaticJIT execution to agree for representative signed and
unsigned double-to-64-bit conversions. Running the currently recorded task 3.4
cannot produce that evidence.

The production P091/P092 classification remains correct: those hunks are the
interpreter's operand-1 decoding and two-word advancement fixes. The defect is
in the claimed regression boundary, not in their hunk ownership. To close it,
the records should either:

1. state that no exact StaticJIT double-to-int64/uint64 parity owner currently
   exists and leave an explicit task to add one; or
2. name a real test that executes generated `dTOi64`/`dTOu64` paths with
   representative signed and unsigned results.

Until then, checked ownership task 1.3 and the asserted regression completeness
are not truthful at the exactness required for this closure.

## Stage 1 — Production-Hunk Reconciliation

### Independent population and key check

I parsed the current plugin production diff directly with:

```text
git -C Plugins/Angelscript diff --unified=0 -- Source/AngelscriptRuntime
```

and independently extracted each `@@` header rather than accepting counts from
the existing reports.

| Check | Independent result |
|---|---:|
| Runtime files with content hunks | 22 |
| Current zero-context hunks | 164 |
| Unique current `File + NewStart` keys | 164 |
| CSV data rows | 164 |
| Unique CSV `File + NewLine` keys | 164 |
| Unique CSV `HunkId` values | 164 |
| Missing current diff keys in CSV | 0 |
| Extra CSV keys absent from current diff | 0 |
| Duplicate CSV keys | 0 |
| Rows still marked `Unowned` | 0 |

`as_compiler.h` appears in plugin status but has no content diff; an
ignore-end-of-line diff also reports no content. Excluding it from the 22-file
hunk population is therefore correct.

### Terminal owner totals

| Terminal owner | Hunks |
|---|---:|
| `fix-as-reference-bytecode-ownership-persistence` | 62 |
| script lifecycle owner | 56 |
| object-last/reference owner | 34 |
| engine default-property owner | 1 |
| completed native SDK regression-suite owner | 2 |
| StaticJIT debug-text whitespace owner | 1 |
| switch `INT_MAX` lowering owner | 4 |
| double-to-int64 interpreter execution owner | 2 |
| explicit user-authorized non-semantic cleanup | 2 |
| **Total** | **164** |

The CSV has 162 semantic/build-surface rows and exactly two terminal
non-semantic rows. The latter are P073/P074 and use
`Terminal-UserAuthorizedNonSemantic`; they are not assigned a behavioral
root-cause owner.

The disposition totals also reconcile:

- 159 `OwnedConsistent-LinkedOpen`;
- 3 `OwnedConsistent-LinkedClosed`; and
- 2 `Terminal-UserAuthorizedNonSemantic`.

### Mixed-file boundary check

The three files with multiple owners reconcile exactly:

| File | Owner split | Total |
|---|---|---:|
| `as_compiler.cpp` | reference 20; lifecycle 7; object-last 2; switch 4; user-authorized terminology 2 | 35 |
| `as_context.cpp` | reference 9; lifecycle 15; object-last 11; double-to-int64 2 | 37 |
| `as_restore.cpp` | reference 10; lifecycle 14; object-last 10 | 34 |

No whole-file assignment obscures the mixed semantic boundaries.

### Former 15-gap check

Each former gap was matched once to its current diff key and inspected in the
actual patch:

| Hunk(s) | Current patch meaning | Recorded boundary result |
|---|---|---|
| P019 | `Out.TrimEndInline()` in generated debug text | StaticJIT debug-text whitespace; exact new linked change |
| P022 | exported `Process` declaration | reference-bytecode persistence; amended existing change |
| P066-P069 | `asINT64` case bounds/density and widened comparison | switch `INT_MAX` lowering; exact new linked change |
| P073-P074 | comment terminology changes to “priority table” / “table” | retain as terminal user-authorized non-semantic cleanup |
| P091-P092 | source from `SWORDARG1(l_bc)` and `l_bc += 2` | double-to-int64 interpreter execution; exact new linked change, subject to the regression-owner finding above |
| P138 | reader recognizes uppercase `asBCTYPE_W_rW_ARG` | reference/GETOBJ persistence |
| P142 | restore adjustment applies only to operand 1 | reference/GETOBJ persistence |
| P149 | GETOBJ format comment corrected to `W_rW_ARG` | reference/GETOBJ persistence invariant |
| P150 | writer-side adjustment applies only to operand 1 | reference/GETOBJ persistence |
| P151 | writer emits both `W_rW_ARG` words | reference/GETOBJ persistence |

The requested P073/P074 constraint is satisfied. Both edits remain present in
the production diff, are comment-only, and are not treated as a behavioral
owner or given a fabricated behavioral regression.

### GETOBJ/reference versus numeric conversion

The corrected classification is supported by current bytecode metadata:

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h:1896`
  declares GETOBJ with uppercase `W_rW_ARG`;
- GETOBJREF and GETREF use the same reference-style format;
- lines 1977 and 1979 declare `dTOi64` and `dTOu64` with lowercase
  `wW_rW_ARG`; and
- both formats currently occupy two words, but they have different operand
  semantics.

Accordingly, P138/P142/P150/P151, with P149 documenting the invariant, belong
to GETOBJ/reference reader-writer persistence and not numeric conversion.
P091/P092 alone form the interpreter numeric-conversion pair.

### Task 2.6 versus 2.7

The comprehensive record is truthful on this distinction:

- task 2.6 may remain checked because the current 164-hunk population has an
  exact terminal disposition with no missing, extra, duplicate, or `Unowned`
  key;
- task 2.7 correctly remains open because fresh final build/runtime evidence is
  still pending in the open linked changes.

The finding above does not reopen hunk reconciliation, but it does require the
double-to-64-bit linked record to correct its claimed regression coverage before
the final verification task can be completed honestly.

## Stage 2 — OpenSpec and Record Quality

### Reviewed record set

I read the complete `proposal.md`, `design.md`, `background.md`, `issues.md`,
`tasks.md`, `verification.md`, delta spec, and `.openspec.yaml` for:

- `fix-as-static-jit-debug-text-whitespace`;
- `fix-as-switch-int-max-lowering`;
- `fix-as-double-int64-bytecode-execution`; and
- amended `fix-as-reference-bytecode-ownership-persistence`.

I also inspected every comprehensive living record named by the closure:

- `proposal.md`;
- `impact-map.md`;
- `runtime-change-map.md`;
- `tasks.md`;
- `progress.md`;
- `issues.md`;
- `verification.md`;
- both final ownership handoffs; and
- `scripts/ValidatePlanningRecords.ps1`.

The source paths and named regression methods referenced by those records were
checked against the current tree.

### Quality results apart from the ranked finding

- The three new changes and the amended reference change contain substantive
  proposal, design, background, issue, task, verification, and requirement
  content. They are not empty scaffolds.
- Semantic and build-surface hunk boundaries are explicit, and rollback
  boundaries are recorded. “Roll back” wording is present where appropriate.
- The StaticJIT whitespace change separates the exact generated-output owner
  from its additional literal-output scan.
- The switch change names the exact near-`INT_MAX` boundary values and the
  dense-case regression owner.
- The amended reference change explicitly owns P022 and the
  P138/P142/P149/P150/P151 GETOBJ/reference persistence set.
- Current state and historical evidence are distinguished. Earlier
  “15 Unowned” wording appears only as historical/former-gap context; current
  records consistently state zero unowned hunks.
- Case-insensitive scanning of the edited closure records found no remaining
  generic `matrix` terminology. The P073/P074 “priority table” / “table”
  terminology is preserved.
- Scanning the four linked change directories found no `TODO`, `TBD`,
  placeholder, “implement later,” or “fill details” residue.

### Linked-path validator

`ValidatePlanningRecords.ps1` was read in full. Its explicit linked list covers
the seven current root-cause change directories and verifies both directory
existence and presence in `runtime-change-map.md`. The completed regression
suite is intentionally represented as a separate already-closed owner rather
than an open root-cause link.

A fresh `-RequireClean` validator run completed with zero violations and an
empty output artifact.

### Strict validation

Fresh strict validation passed independently for all five affected changes:

- `test-as-native-sdk-comprehensive-coverage`;
- `fix-as-reference-bytecode-ownership-persistence`;
- `fix-as-static-jit-debug-text-whitespace`;
- `fix-as-switch-int-max-lowering`; and
- `fix-as-double-int64-bytecode-execution`.

Each command reported `1 passed, 0 failed` / `0 issues`. This confirms OpenSpec
schema validity, but it does not detect the semantic mismatch in the named
StaticJIT regression owner.

### Whitespace and file hygiene

A fail-fast byte/line scan covered 44 exact files: all files in the three new
changes and amended reference change, both SDD audit/report files, and the ten
named comprehensive living records. It found:

- no missing final newline;
- no trailing spaces or tabs;
- no multiple blank EOF;
- no NUL bytes; and
- no empty record files.

Scoped `git diff --check` over the affected parent-repository record paths
passed with no output. Untracked files were covered by the direct byte/line
scan because `git diff --check` does not inspect them.

An initial hygiene command used an obsolete guessed comprehensive-change path
and produced missing-path errors; its apparent `HYGIENE_OK` output was
discarded. The corrected command used the actual
`test-as-native-sdk-comprehensive-coverage` paths, enabled fail-fast error
handling, checked all 44 files, and passed.

## Review Boundary

This was a read-only source and record review except for this requested review
artifact. I did not modify production code or OpenSpec records, run a build,
run runtime/automation tests, or create a commit.
