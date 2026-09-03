/**
 * Two delegate types with the same name are rejected. The second declaration
 * cannot reuse FOnActionDup even with a different signature.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DuplicateDelegateName
 * @Harness CompileReject
 * @Tag Feature.Delegates.DuplicateDelegateName
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs two FOnActionDup declarations
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail: duplicate delegate type name.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_DuplicateDelegate
 * @Provenance sha256=b3cce4f2b3415ab9aece4f5d530e017766f598ecd792d1e6b6d0d8637e984207; lines 198-201.
 * @Provenance Expected diagnostic: "Duplicate delegate name should fail".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * The first FOnActionDup declaration.
 *
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return a void unicast with no parameters
 */
delegate void FOnActionDup();

/**
 * The isolated failing program: a second FOnActionDup with an int parameter.
 *
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs int X
 * @Return does not compile; the name is already taken
 */
delegate void FOnActionDup(int X);
