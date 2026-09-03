/**
 * A delegate declaration that omits the terminating semicolon is rejected.
 * The signature must end with `;` rather than being left open.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.MissingSemicolonAfterDelegate
 * @Harness CompileReject
 * @Tag Feature.Delegates.MissingSemicolonAfterDelegate
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs delegate void FOnActionNoSemi()
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail: missing semicolon after delegate.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_MissingSemicolon
 * @Provenance sha256=b6d3fc273f90b27703cb045cb238805a6e3fd454623fd21f69a56a8184b86073; lines 211-213.
 * @Provenance Expected diagnostic: "Missing semicolon after delegate should fail".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * The isolated failing program: a delegate signature with no semicolon.
 *
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return does not compile; the declaration is not terminated
 */
delegate void FOnActionNoSemi()
