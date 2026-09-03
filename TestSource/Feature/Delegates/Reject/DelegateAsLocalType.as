/**
 * A delegate type declared as a local inside a function is rejected. Delegate
 * types belong at script scope, not inside Foo.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateAsLocalType
 * @Harness CompileReject
 * @Tag Feature.Delegates.DelegateAsLocalType
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs delegate void FOnActionLocal() inside Foo
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail: delegate as a local type in Foo.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_DelegateAsLocalType
 * @Provenance sha256=576c1ed8a947d254351268f61dfa14b353888aba5dead919480bfae2e5401404; lines 250-258.
 * @Provenance Expected diagnostic: "Delegate as local type inside function should fail".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

class ADelLocalActor : AActor
{
	/**
	 * The isolated failing program: a delegate type declared as a local.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.Declaration
	 * @Inputs none
	 * @Return does not compile; delegate types are not locals
	 */
	void Foo()
	{
		delegate void FOnActionLocal();
	}
}
