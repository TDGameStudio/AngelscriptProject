/**
 * A delegate type nested inside a class is rejected. Delegate types belong at
 * script scope, not as members of ADelNestedActor.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.NestedDelegateInsideClass
 * @Harness CompileReject
 * @Tag Feature.Delegates.NestedDelegateInsideClass
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs delegate void FOnActionNested() inside ADelNestedActor
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail: nested delegate inside a class.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_NestedDelegate
 * @Provenance sha256=10666051980d07217f461a6ba53be2fd53ebf97faacd7f315ebe163db720f923; lines 235-240.
 * @Provenance Expected diagnostic: "Nested delegate inside class should fail".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

class ADelNestedActor : AActor
{
	/**
	 * The isolated failing program: a delegate type nested in a class.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.Declaration
	 * @Inputs none
	 * @Return does not compile; delegate types are not class members
	 */
	delegate void FOnActionNested();
}
