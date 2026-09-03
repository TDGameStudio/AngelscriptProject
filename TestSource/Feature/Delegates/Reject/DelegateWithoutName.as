/**
 * A delegate declaration without a type name is rejected. The signature must
 * name the type between the return type and the parameter list.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateWithoutName
 * @Harness CompileReject
 * @Tag Feature.Delegates.DelegateWithoutName
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs delegate void ();
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail: delegate without a type name.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_NoName
 * @Provenance sha256=0a31bb2702d11d39cd78acbf98a71a2b0d35af5ea2361e66d5edeb8873a8129c; lines 159-161.
 * @Provenance Expected diagnostic: "Delegate without name should fail".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * The isolated failing program: a delegate with no type name.
 *
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return does not compile; the type is unnamed
 */
delegate void ();
