/**
 * A delegate declaration with a function body is rejected. The signature is
 * only a type; it does not carry an implementation.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateWithBody
 * @Harness CompileReject
 * @Tag Feature.Delegates.DelegateWithBody
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs delegate void FOnActionBody() { }
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail: delegate declaration with a body.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_DelegateWithBody
 * @Provenance sha256=cabd5f68dc793436e71556d01ae0f5f174d7c84877321f9294f04386bb89a4de; lines 223-225.
 * @Provenance Expected diagnostic: "Delegate with body should fail".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * The isolated failing program: a delegate type with a body.
 *
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return does not compile; delegate types have no body
 */
delegate void FOnActionBody()
{
}
