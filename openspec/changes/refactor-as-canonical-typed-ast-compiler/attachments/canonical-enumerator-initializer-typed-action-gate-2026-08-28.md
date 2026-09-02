# CTA-S36: Canonical enumerator-initializer typed-action gate

Date: 2026-08-28

Status: `GREEN`

Enumerator names already cross `ActOnEnumeratorName`, but an explicit value
still crosses `ActOnEnumeratorInitializerFromNode`. Declaration Sema unwraps
the retained `snAssignment`, re-enters `ActOnExprFromNode`, and therefore keeps
a native-node semantic adapter after expression actions have published exact
identities. CTA-S36 removes that adapter without changing the retained native
Parser/AST or explicit LEGACY compiler path.

## Scope and action contract

Parser must publish one `asSEnumeratorInitializerAction` containing:

- the exact enumerator `asASTDeclId` returned by its typed name action;
- the exact already-published initializer `asASTExprId`;
- copied half-open initializer source offsets;
- an explicit recovery fact.

The action contains no `asCScriptNode*`, token/source-buffer pointer, Runtime
object pointer, numeric Runtime `typeId`, HIR object, dump or replay payload.
Sema validates enum ownership and copied source facts, evaluates the exact
Canonical expression as an integer constant, replaces the provisional implicit
value, and binds the expression once.

## Required AST facts

1. A direct action with no Parser node binds the exact Binary ExprId and freezes
   its evaluated constant value.
2. An exact repeated action is idempotent; a distinct ExprId cannot overwrite
   an already explicit enumerator initializer.
3. Parser source with binary and negative values binds the exact Binary/Unary
   roots rather than a superficial first token or a reconstructed expression.
4. Implicit following enumerators continue to advance from the frozen explicit
   value.
5. Non-constant expressions continue to diagnose and do not replace the
   provisional value with an invalid init.
6. `ActOnEnumeratorInitializerFromNode` is physically absent from Parser and
   public Sema. Native `ParseEnumeration`, `snEnum`, `asCScriptNode`, Builder,
   `asCCompiler` and LEGACY remain.

## RED tests

- `SemaEnumeratorInitializerTypedActionOwnsExactExprWithoutScriptNode`
- `ParserEnumeratorInitializerUsesTypedActionAndExactIdentity`
- strengthen `ParserEnumUsesTypedNameActionsWithoutEnumNodeReplay` to require
  the initializer action and physical removal of the native-node adapter.

Expected RED is a compile failure because the action struct and Sema entry do
not exist. The strengthened production source contract also remains red while
the old adapter is present.

## Required GREEN evidence

1. Development Editor build.
2. Focused direct action, Parser exact-identity, implicit-successor and
   non-constant failure tests.
3. Full SemaAuthority.
4. ProductionCodeGen + Canonical Semantics + retained native ScriptNode.
5. Production source scan, strict OpenSpec validation and parent/plugin
   `git diff --check`.

Every unexpected RED/GREEN issue and any bounded unsupported enum initializer
shape must be appended to the final-completion issue log before GREEN.

## GREEN implementation

`ParseEnumeration` now publishes `asSEnumeratorInitializerAction` with the
exact typed-name DeclId, the one exact already-published expression root,
copied initializer offsets and recovery state. Declaration Sema validates the
source range, enum ownership and expression identity before invoking constant
evaluation. Identical repeat publication is idempotent; a conflicting explicit
rebind diagnoses `enumerator-initializer-already-bound` without mutation.

`ActOnEnumeratorInitializerFromNode` is physically absent from production.
Native `ParseEnumeration`, `snEnum`, Builder, `asCCompiler` and LEGACY remain
unchanged for syntax/recovery/reference/differential/rollback use.

No unexpected GREEN issue was found. A non-constant exact expression remains a
valid typed action request but fails semantic constant evaluation, records
`enumerator-init-not-constant`, binds no init and leaves the provisional
implicit value intact. This is the required fail-closed behavior.

## Verified evidence

- expected missing-action RED build:
  `Saved/Build/cta-s36-enumerator-initializer-action-red/20260828_032455_441_f90cec13/RunMetadata.json`;
- implementation GREEN build:
  `Saved/Build/cta-s36-enumerator-initializer-action-build-1/20260828_032815_893_e41d6703/RunMetadata.json`;
- final incremental test build:
  `Saved/Build/cta-s36-enumerator-initializer-test-build/20260828_033002_793_2c4327a9/RunMetadata.json`;
- direct action, non-constant failure, Parser exact Binary/Unary roots, implicit
  successor and production source contract: **5/5 PASS** at
  `Saved/Tests/cta-s36-enumerator-initializer-focused-1/20260828_033053_206_642701dd/RunMetadata.json`;
- full SemaAuthority: **372/372 PASS** at
  `Saved/Tests/cta-s36-sema-authority-full/20260828_033127_151_a58b2e2a/RunMetadata.json`;
- ProductionCodeGen + Canonical Semantics + retained native ScriptNode:
  **158/158 PASS** at
  `Saved/Tests/cta-s36-secondary-gates/20260828_033306_170_a3661f8d/RunMetadata.json`;
- production source scan, strict OpenSpec validation and parent/plugin
  `git diff --check` pass, with only existing line-ending conversion warnings.

No umbrella task row is independently complete. The mechanical ratio remains
**87/125 (69.6%)**, weighted implementation **about 68%**, and safe default-
CANONICAL cutover readiness **about 40%**.
