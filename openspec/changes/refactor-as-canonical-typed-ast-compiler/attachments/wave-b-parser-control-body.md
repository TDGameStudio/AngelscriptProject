# Wave B remaining complete-body Parser Sema action (B-parser-control-body)

> **LANDED.** RED SemaAuthority **87/82** (5 incomplete-body failures). GREEN SemaAuthority **87/87**, CanonicalAST **102/102**. Do not redo. Next exclusive UBT is `attachments/wave-d-r09-task2plus.md`. **13.2 stays `[ ]`.**

> **For exclusive-UBT workers:** REQUIRED SUB-SKILL: Use superpowers:test-driven-development. Add the failing SemaAuthority methods first. `RunBuild.ps1 -NoXGE` then the SemaAuthority prefix **before** filling `as_parser.cpp`. Do **not** check `tasks.md` 13.2 / 5.9 / 4.2.

**Goal:** Clang-shaped Parser `ActOnParsedStmt` **after the complete then/body/cases** (and on body parse error) for `if` / `while` / `for` / `do-while` / `switch`, so an incomplete body still intern the control stmt plus the selected overload. This is **not** 13.2 close and **not** production `Build()` routing.

**Prerequisite (do not redo):** B-parser-foreach-body is green (SemaAuthority **77/77**, Compiler CanonicalAST **92/92**). Error-path missing-`)` ActOn for these statements already exists.

**Architecture today:**

| Parser | ActOn today | Complete body |
| --- | --- | --- |
| `ParseForeach` | missing `:`/range/`)` **and** after `ParseStatement` error+success | Parser owns body |
| `ParseIf` | missing `)` only | WalkOne |
| `ParseWhile` | missing `)` only | WalkOne |
| `ParseFor` | missing condition/incr/`)` only | WalkOne |
| `ParseDoWhile` | missing `)` after condition only | WalkOne |
| `ParseSwitch` | missing `)` only | WalkOne |

Same trap as foreach header: **do not ActOn after `)` / `{` before then/body/cases**. That intern an empty control stmt; `FindExistingStmt` then drops the body on WalkOne.

---

## Header

| Field | Value |
| --- | --- |
| Worktree | `D:\as-cta` |
| Date | 2026-08-21 |
| Change | `refactor-as-canonical-typed-ast-compiler` |
| Package | **B-parser-control-body** |
| Mode now | Exclusive UBT when AngelscriptProject UBT is idle |
| UBT mutex | One UBT user in `D:\as-cta`. `-NoXGE`. Do not share `as_parser.cpp` with a CodeGen writer |

---

## File map

- Modify: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` — add 10 methods after `ParserActOnForeachBodyRecordsSelectedCallOnSuccessfulParse`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp`
  - `ParseIf` ~4762–4775
  - `ParseFor` ~4859–4861
  - `ParseWhile` ~5053–5055
  - `ParseDoWhile` ~5075–5076 and ~5109–5118
  - `ParseSwitch` ~4604–4632
- Do not edit `as_sema*` unless GREEN proves `FindExistingStmt` drops body children (foreach-body did not need Sema edits).
- Do not re-enable script `funcdef` / `@` / `is`.
- Do not route production `Build()`.

Expected counts after adding 10 methods: SemaAuthority **87**, CanonicalAST **102**. RED should fail only the five incomplete-body methods (success selected-call is already WalkOne-green, same as foreach-body RED 77/76).

---

### Task 1: Write the ten failing tests <!-- TDD -->

Clone the foreach-body pair. Shared overload fixture:

```cpp
int F(int x)
{
	return x;
}

int F(float x)
{
	return 0;
}
```

Incomplete bodies omit the closing `}` / `;` so parse fails. Success bodies are complete and must Seal.

Add these methods (names must match):

1. `ParserActOnIfBodyBeforeBlockCloseFails` — `if (1) { n = F(1` must dump `kind=If` and `callee=F(int)` not `F(float)`.
2. `ParserActOnIfBodyRecordsSelectedCallOnSuccessfulParse` — one `kind=If` plus `callee=F(int)`.
3. `ParserActOnWhileBodyBeforeBlockCloseFails` — `while (1) { n = F(1`
4. `ParserActOnWhileBodyRecordsSelectedCallOnSuccessfulParse`
5. `ParserActOnForBodyBeforeBlockCloseFails` — `for (int i = 0; i < 1; i += 1) { n = F(1`
6. `ParserActOnForBodyRecordsSelectedCallOnSuccessfulParse`
7. `ParserActOnDoWhileBodyBeforeBlockCloseFails` — `do { n = F(1` (fail during body, before `while`)
8. `ParserActOnDoWhileBodyRecordsSelectedCallOnSuccessfulParse` — `do { n = F(1); } while (0);`
9. `ParserActOnSwitchBodyBeforeBlockCloseFails` — `switch (x) { case 1: n = F(1`
10. `ParserActOnSwitchBodyRecordsSelectedCallOnSuccessfulParse`

Copy the foreach-body engine/module/parser/dump harness. Change only the script, dump tokens (`kind=If` / `While` / `For` / `DoWhile` / `Switch`), and uniqueness counts.

If-body success script:

```as
int Entry()
{
	int n = 0;
	if (1)
	{
		n = F(1);
	}
	return n;
}
```

For-body success script must keep the existing one-For uniqueness (`ParserActOnForDoesNotDuplicateOnSuccessfulParse`).

Switch success script:

```as
int Entry()
{
	int n = 0;
	int x = 1;
	switch (x)
	{
	case 1:
		n = F(1);
		break;
	}
	return n;
}
```

- [ ] **Step 1: append the ten methods, tests only**

---

### Task 2: Prove RED <!-- TDD -->

```powershell
Set-Location D:\as-cta
Tools\RunBuild.ps1 -NoXGE -Label wave-b-control-body-red
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-control-body-red
```

Expected: total=87. Incomplete-body methods FAIL (no control-stmt ActOn after `ParseStatement` error). Success selected-call methods may already PASS via WalkOne. Do not fill parser until that RED is on disk.

- [ ] **Step 2: RED report recorded**

---

### Task 3: Minimal GREEN in `ParseIf` / `ParseWhile` / `ParseFor` / `ParseDoWhile` / `ParseSwitch`

Pattern (proven by `ParseForeach` after `ParseStatement`):

```cpp
node->AddChildLast(ParseStatement());
if( isSyntaxError )
{
	if( sema )
	{
		sema->ActOnParsedStmt(node, script);
	}
	return node;
}
if( sema )
{
	sema->ActOnParsedStmt(node, script);
}
return node;
```

**If-else:** ActOn after then **only when there is no else**. If `ttElse` follows, parse the else statement first, then ActOn once (error or success). A then-only ActOn plus later FindExisting would drop else.

**Do-while:** ActOn after body parse error (today `if( isSyntaxError ) return node` at ~5076 with no ActOn). Also ActOn after a successful condition+`;`. Missing `)` after condition already ActOn — keep that.

**Switch:** ActOn after the case loop on syntax error **and** after a successful `}`. Do not ActOn after `)` before `{`.

**Hard no:** ActOn immediately after `)` / `{` with an empty then/body.

`FindExistingStmt` already covers If/While/For/DoWhile/Switch. Existing `DoesNotDuplicateOnSuccessfulParse` tests must stay 1 stmt.

- [ ] **Step 3: parser ActOn after complete body only**

---

### Task 4: Prove GREEN <!-- TDD -->

```powershell
Set-Location D:\as-cta
Tools\RunBuild.ps1 -NoXGE -Label wave-b-control-body-green
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-control-body-green
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-control-body-canonical
```

Expected: SemaAuthority **87/87**. CanonicalAST **102/102**. IsolatedDifferential stays 3/3 if touched; only rerun if a local-var duplicate appears (the for-slice While `Y` bug).

Leave **13.2 / 4.2 / 5.9 / 13.3 `[ ]`**. Production Bytecode is still `asCCompiler` (criterion 4). This slice only advances criterion 1.

Record counts in `attachments/wave-b-results.md`. Patch `tasks.md` progress notes only.

- [ ] **Step 4: GREEN prefixes recorded; boxes still open**

---

## Why this still does not close 13.2

1. Complete if/while/for/do-while/switch become Parser actions — closer to criterion (1).
2. Criterion (4) stays false until production `Build()` consumes the sealed graph through `asCBytecodeCodeGen`.
3. Script `funcdef` stays fork-rejected; some expr interiors still `ActOn*FromNode`.
4. Checking 13.2 from 87/87 would be 虚标.
