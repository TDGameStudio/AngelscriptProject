# Wave B body attach intern — exclusive UBT TDD slice

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
**This is the exclusive UBT now.** One UBT user. Always `-NoXGE`.
**Leave 13.2 / 13.3 / 9.5 / 4.2 / 5.9 / 5.6 `[ ]`.** Do not archive. Do not commit unless asked.

TDD. Dual-repo. Commands only `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1` from `D:\as-cta`.
`RunTests.ps1` does **not** UBT — always `RunBuild.ps1` first after impl.

LLVM/Clang is a shape reference only. Do not link Clang/LLVM. No Unreal types in fork frontend files.
Fork dialect: no script `funcdef` / `@` / `is`; `nullptr` = `ttNull`. Host `RegisterFuncdef` remains legal.
Default pipeline stays LEGACY. CompileFunction stays mixed COMPILER. CALL-without-callee is a hard no.

Companions: `async-work.md` (梳理), `async-dispatch.md` (live table), `wave-b-leftover-after-postfix.md` (inventory; “must wait” expired), `wave-b-nested-extract-next.md` (queued, **not this RED/GREEN**).

## Goal

Make Parser incrementally `ActOnParsedStmt` nested statements and the closed statement block, and attach a function/method/lambda body as an interned **Block** of already interned children, **without** `ActOnReturnStmt` stealing the function body.

This is leftover intern of **body attach**. Compound intern already landed (`ActOnCompoundStmt`). A rename that still walks `asCScriptNode` via `ActOnStmtFromNode` is not intern authority.

This is **not** 13.2. Nested If then/else / loop bodies / switch cases may still extract through `ActOnStmtFromNode` in this slice.

## Why this is unblocked now

Landed (do **not** redo): ctor/dtor/mixin intern, `ActOnListPatternDecl`, leftover Term `++`/`--`. SemaAuthority **186/186**.

The leftover map said body attach must wait until Parser incremental stmt ActOn that does not steal. That wait **is this slice**.

## The steal (do not guess past these sites)

```text
as_sema.cpp:416-421
  ActOnReturnStmt → CreateStmt(RETURN) + SetStmtExpr + SetBody(owner, id)

as_sema_decl.cpp:454-475
  WalkReturnConstants → ActOnReturnStmt   (WalkOne(snReturn) intern)

as_sema_decl.cpp:1204-1208
  WalkOne snFunction → SetBody(fn, ActOnStmtFromNode(body))

as_sema_decl.cpp:1039-1043
  ActOnLambdaFromNode → SetBody(fn, ActOnStmtFromNode(body))

as_parser.cpp:4300-4304
  ParseStatementBlock NotifySema ONLY snDeclaration
  comment: non-decl ActOn would steal the body

as_parser.cpp:5443 / 5455
  ParseReturn already ActOnParsedStmt (not NotifySema)

as_parser.cpp:132-139
  NotifySema = ActOnParsedDeclaration → WalkOne
  NOT ActOnParsedStmt. Do not NotifySema nested statements.

as_sema_decl.cpp:1948-1950
  ActOnParsedStmt default → ActOnStmtFromNode (no snStatementBlock arm)

as_sema.cpp:943-950
  ActOnBlock does NOT SetBody. Keep it that way.

as_sema_stmt.cpp:375-382
  ActOnCompoundStmt FindExisting BLOCK then ActOnBlock. Does NOT SetBody. Keep it that way.

as_ast_dump.cpp:132
  DECL dump has NO body= field. Proof uses asCDecl::body + asCStmt.

as_bytecode_codegen.cpp:362-364
  Generate emits decl->body. Isolated tests that only ActOnReturnStmt currently rely on the steal.
```

`FindExistingStmt` (`as_sema_stmt.cpp:17-35`) returns invalid when `range.begin.offset == 0`. No-script-node tests using `asCSourceRange()` stay unique.

## File map

- Test: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  - After `SemaReturnStmtActionRecordsValueWithoutScriptNode` (~2475)
  - After `SemaCompoundStmtActionRecordsChildrenWithoutScriptNode` (~3508)
  - Extend `ParserActOnReturnDoesNotDuplicateOnSuccessfulParse` (~4596)
  - Add incomplete nested-block steal lock near `ParserActOnBareReturnBeforeFunctionCloseFails` (~7603)
- Production:
  - `.../ThirdParty/angelscript/source/as_sema.cpp` `ActOnReturnStmt`
  - `.../ThirdParty/angelscript/source/as_sema.h` only if a new attach helper is added (not required)
  - `.../ThirdParty/angelscript/source/as_parser.cpp` `ParseStatementBlock`
  - `.../ThirdParty/angelscript/source/as_sema_decl.cpp` WalkOne snFunction body, `ActOnLambdaFromNode`, `WalkReturnConstants`, `ActOnParsedStmt` `snStatementBlock`
  - `.../ThirdParty/angelscript/source/as_sema_stmt.cpp` only if Return FindExisting lives with the other stmt intern APIs
- Isolated tests that used Return-as-function-body (wrap Compound + `SetBody`; do not treat as 9.5):
  - `.../Frontend/CanonicalAST/AngelscriptNativeCanonicalASTCodeGenTests.cpp`
  - `.../Frontend/CanonicalAST/AngelscriptNativeCanonicalASTCodeGenTransactionTests.cpp`
  - `.../Frontend/CanonicalAST/AngelscriptNativeCanonicalASTSemaTests.cpp`
  - `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/TypedASTJIT/CanonicalASTMigration/AngelscriptCanonicalASTJITAdapterTests.cpp`
- If/While/For tests that pass a Return as **then/loop child** stay unchanged.

## Interfaces

- Consumes: `ActOnReturnStmt`, `ActOnCompoundStmt`, `ActOnBlock`, `FindExistingStmt`, `ActOnParsedStmt`, `SetBody`, `asCDecl::body`, `asCStmt::{kind,children}`
- Produces: function/method/lambda `body` is `asAST_STMT_BLOCK`; Return is a child; `ActOnReturnStmt` never writes `asCDecl::body`

Optional helper (implementer may inline instead):

```cpp
asASTStmtId ActOnFunctionBody(asASTDeclId fn, const asCArray<asASTStmtId>& children, const asCSourceRange& range);
// FindExisting BLOCK, else ActOnCompoundStmt, then SetBody(fn, block). Must NOT be called from ActOnReturnStmt.
```

---

### Task 1: RED — Return does not become the function body

**Files:** SemaAuthority tests only. No production edit yet.

- [ ] **Step 1: Write the failing tests**

Add after `SemaReturnStmtActionRecordsValueWithoutScriptNode`. Keep that method’s `kind=Return` dump. Add body identity:

```cpp
TEST_METHOD(SemaReturnStmtActionDoesNotStealFunctionBody)
{
	AngelscriptNativeTestSupport::FNativeTestEngine Engine;
	Engine.Create(*TestRunner);
	ON_SCOPE_EXIT { Engine.Destroy(); };

	asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
	asCASTContext Context;
	asCSema Sema(ScriptEngine, Context);
	const asASTDeclId Tu = Sema.ActOnTranslationUnit("SemaReturnNoSteal");
	const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
	const asCSourceRange Range;
	const asASTDeclId Fn = Sema.ActOnFunctionDecl(Tu, "F", IntType, Range);
	const asASTStmtId Ret = Sema.ActOnReturnStmt(Fn, Sema.ActOnIntegerLiteral(7, Range), Range);
	ASSERT_THAT(IsTrue(Ret.IsValid(), TEXT("ActOnReturnStmt must intern Return")));

	const asCDecl* FnDecl = Context.GetDecl(Fn);
	ASSERT_THAT(IsTrue(FnDecl != nullptr, TEXT("F decl")));
	ASSERT_THAT(IsTrue(!FnDecl->body.IsValid() || FnDecl->body.value != Ret.value,
		TEXT("ActOnReturnStmt must not SetBody(F, Return)")));
}

TEST_METHOD(SemaCompoundStmtActionAttachesBlockAsFunctionBody)
{
	// same engine/sema/Fn setup as SemaCompoundStmtActionRecordsChildrenWithoutScriptNode
	asCArray<asASTStmtId> Children;
	const asASTStmtId Ret = Sema.ActOnReturnStmt(Fn, Sema.ActOnIntegerLiteral(1, Range), Range);
	Children.PushLast(Ret);
	const asASTStmtId Block = Sema.ActOnCompoundStmt(Fn, Children, Range);
	ASSERT_THAT(IsTrue(Block.IsValid(), TEXT("ActOnCompoundStmt intern Block")));
	Context.SetBody(Fn, Block);

	const asCDecl* FnDecl = Context.GetDecl(Fn);
	const asCStmt* Body = FnDecl ? Context.GetStmt(FnDecl->body) : nullptr;
	ASSERT_THAT(IsTrue(Body != nullptr && Body->kind == asAST_STMT_BLOCK,
		TEXT("function body must be Block, not Return")));
	bool HasReturnChild = false;
	for (asUINT i = 0; Body && i < Body->children.GetLength(); ++i)
	{
		if (Body->children[i].value == Ret.value)
		{
			HasReturnChild = true;
		}
	}
	ASSERT_THAT(IsTrue(HasReturnChild, TEXT("Block children must include the Return")));
}
```

Extend `ParserActOnReturnDoesNotDuplicateOnSuccessfulParse` after ReturnCount==1:

```cpp
const asCDecl* Entry = nullptr;
for (asUINT i = 1; i <= Context.GetDeclCount(); ++i)
{
	const asCDecl* Decl = Context.GetDecl(asASTDeclId(i));
	if (Decl && Decl->kind == asAST_DECL_FUNCTION && Decl->name.Equals("Entry"))
	{
		Entry = Decl;
		break;
	}
}
ASSERT_THAT(IsTrue(Entry != nullptr && Entry->body.IsValid(), TEXT("Entry must have a body")));
const asCStmt* Body = Context.GetStmt(Entry->body);
ASSERT_THAT(IsTrue(Body != nullptr && Body->kind == asAST_STMT_BLOCK,
	TEXT("complete parse body must be Block, not Return")));
```

Incomplete nested steal (parse must fail):

```cpp
TEST_METHOD(ParserActOnNestedReturnDoesNotStealFunctionBody)
{
	// source:
	// int Entry()
	// {
	//     return 0;
	//     {
	//         return 1
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		int Entry()
		{
			return 0;
			{
				return 1
	)AS");
	// ParseScript < 0
	// dump contains kind=Return and literal=0 (and may contain literal=1)
	// Entry->body is NOT a STMT_RETURN (invalid, or Block)
}
```

Incomplete `ParserActOnReturnStmtBeforeSemicolonFails` may also assert `Entry->body` is not Return. Keep existing dump locks (`kind=Return`, `literal=1`).

- [ ] **Step 2: Run RED**

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-body-red
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestFilter "SemaReturnStmtActionDoesNotStealFunctionBody|SemaCompoundStmtActionAttachesBlockAsFunctionBody|ParserActOnNestedReturnDoesNotStealFunctionBody|ParserActOnReturnDoesNotDuplicateOnSuccessfulParse" -Label wave-b-body-red -TimeoutMs 600000
```

If `-TestFilter` is unsupported in this runner, use `-TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority"` and read the new method names in the report.

Expected: new body-identity methods Fail (today `ActOnReturnStmt` sets `body=Return`). Do not implement production yet.

---

### Task 2: GREEN — stop steal, incremental ActOnParsedStmt, attach-only Compound

- [ ] **Step 3: Minimal production**

`ActOnReturnStmt` (`as_sema.cpp:416-421`):

```cpp
asASTStmtId asCSema::ActOnReturnStmt(asASTDeclId owner, asASTExprId value, const asCSourceRange& range)
{
	const asASTStmtId existing = FindExistingStmt(context, asAST_STMT_RETURN, range);
	if( existing.IsValid() )
	{
		return existing;
	}
	const asASTStmtId id = context.CreateStmt(asAST_STMT_RETURN, owner, range);
	context.SetStmtExpr(id, value);
	return id; // NO SetBody
}
```

`FindExistingStmt` is currently a `static` in `as_sema_stmt.cpp`. Either:

- move a shared FindExisting next to other intern APIs, or
- intern Return’s FindExisting inside `as_sema_stmt.cpp` by making `ActOnReturnStmt` delegate, or
- duplicate the 15-line lookup next to `ActOnReturnStmt` (worse).

Prefer one FindExisting.

`ParseStatementBlock` (`as_parser.cpp:4280-4306`):

```cpp
if( IsVarDecl() )
	node->AddChildLast(ParseDeclaration());
else
	node->AddChildLast(ParseStatement());
if( sema && node->lastChild && !isSyntaxError )
{
	if( node->lastChild->nodeType == snDeclaration )
	{
		NotifySema(node->lastChild); // local var: ActOnParsedDeclaration
	}
	else
	{
		sema->ActOnParsedStmt(node->lastChild, script); // NOT NotifySema
	}
}
// on ttEndStatementBlock before return:
if( sema && !isSyntaxError )
{
	sema->ActOnParsedStmt(node, script);
}
```

`ActOnParsedStmt` add `case snStatementBlock:` that collects already interned children (FindExisting by child range/kind; leftover FromNode only for kinds this slice does not claim) then `ActOnCompoundStmt`. Do **not** `SetBody` here (nested `{ }` would steal).

WalkOne snFunction / `ActOnLambdaFromNode`:

```cpp
asCScriptNode* body = FirstChildOfType(node, snStatementBlock);
if( body && fn.IsValid() )
{
	const asCSourceRange range = RangeOf(..., body);
	asASTStmtId block = FindExistingStmt(..., asAST_STMT_BLOCK, range);
	if( !block.IsValid() )
	{
		// recovery only if Parser did not intern the closed block
		asCArray<asASTStmtId> children;
		// collect FindExisting of interned children; do not ActOnStmtFromNode as intern
		block = sema->ActOnCompoundStmt(fn, children, range);
	}
	sema->GetContext().SetBody(fn, block);
}
```

`WalkReturnConstants`: if a Return already exists at that range, do **not** call `ActOnReturnStmt` again. Prefer no intern from this helper once Parser `ActOnParsedStmt` owns Return.

Keep LocalDecl flat (`EmitLocalDeclStmts` / sibling `STMT_EXPR`). Do not wrap function-body locals in a nested Block.

Do **not** `SetBody` from `ActOnCompoundStmt` / `ActOnBlock` / `ActOnIfStmt`.

- [ ] **Step 4: Wrap isolated CodeGen tests that relied on the steal**

Search `ActOnReturnStmt` under CanonicalAST + CanonicalASTMigration. If the test never `SetBody`s a Block, wrap:

```cpp
asCArray<asASTStmtId> Body;
Body.PushLast(Sema.ActOnReturnStmt(Fn, Sema.ActOnIntegerLiteral(7, Range), Range));
Context.SetBody(Fn, Sema.ActOnCompoundStmt(Fn, Body, Range));
```

If/While tests that pass Return as a **child stmt** of If/While are not steal users. Leave them.

- [ ] **Step 5: GREEN prefixes**

```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-body
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-body-sema -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-body-canonical -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-b-body-compiler -TimeoutMs 600000
```

Expected: new methods Success; previous SemaAuthority **186** plus the new tests; CanonicalAST / Compiler no regression vs **234/234** / **424/424** plus new methods. ProductionCodeGen **33/33** must stay green inside Compiler prefix (F4 wrap if a CodeGen test lost its body).

- [ ] **Step 6: Do not check 13.2 / 9.5.** Patch `tasks.md` 13.2 **progress note only**. Nested extract stays leftover (`wave-b-nested-extract-next.md`). Do not commit unless asked.

## Must not

- Treat `ActOnStmtFromNode(snStatementBlock)` + `SetBody` as “body intern”
- `NotifySema` nested statements (`WalkOne` / `WalkReturnConstants`)
- `SetBody` inside `ActOnReturnStmt`, `ActOnCompoundStmt`, `ActOnBlock`, nested `{ }`
- Collapse LocalDecl inits onto the enclosing block range (F4)
- Merge nested If then/else extract into this RED/GREEN
- Check 13.2 / 9.5 / 4.2 / 5.9
- Flip default CANONICAL; CANONICAL CompileFunction; re-enable `@` / script `funcdef`
- Second UBT; Wave E–G; archive; commit unless asked
