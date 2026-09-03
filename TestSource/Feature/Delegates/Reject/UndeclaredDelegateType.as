/**
 * A UPROPERTY whose type is an undeclared delegate is rejected. FNonExistentDelegate
 * has no declaration, so the member cannot be formed.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.UndeclaredDelegateType
 * @Harness CompileReject
 * @Tag Feature.Delegates.UndeclaredDelegateType
 * @Kind CompileReject
 * @Covers Delegates.Binding
 * @Inputs UPROPERTY FNonExistentDelegate OnAction
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail: UPROPERTY of an undeclared delegate.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Binding_Negative_UndeclaredDelegateType
 * @Provenance sha256 from theme-refs TS-FEAT-0349; lines 454-460.
 * @Provenance Expected diagnostic: "Using undeclared delegate type should fail".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

class ADelUndeclaredActor : AActor
{
	UPROPERTY()
	FNonExistentDelegate OnAction;
}
