/**
 * The UDELEGATE() macro spelling is rejected. AngelScript declares delegates
 * with the `delegate` keyword, not the C++ UDELEGATE wrapper.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.UDelegateMacroDeclarationRejected
 * @Harness CompileReject
 * @Tag Feature.Delegates.UDelegateMacroDeclarationRejected
 * @Kind CompileReject
 * @Covers Delegates.UDelegateMacro
 * @Inputs UDELEGATE() delegate void FCoverageUnsupportedUDelegate(int Value)
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail: UDELEGATE() macro spelling is rejected.
 * @Provenance C++: AngelscriptCoverageMacrosTests.cpp::UDelegateMacroDeclarationRejected
 * @Provenance CompileAndExpectFailure: "Expected identifier" and "Instead found '('.
 * @Provenance Isolate this failing construct; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * The isolated failing program: UDELEGATE() is not a script specifier.
 *
 * @Kind CompileReject
 * @Covers Delegates.UDelegateMacro
 * @Inputs int Value
 * @Return does not compile; UDELEGATE is not an identifier here
 */
UDELEGATE()
delegate void FCoverageUnsupportedUDelegate(int Value);
