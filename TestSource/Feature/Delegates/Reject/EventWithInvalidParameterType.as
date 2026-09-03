/**
 * An event whose parameter type is unknown is rejected. NonExistentType is not
 * a declared script type, so the signature cannot be formed.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.EventWithInvalidParameterType
 * @Harness CompileReject
 * @Tag Feature.Delegates.EventWithInvalidParameterType
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs event void FOnChangedBadParam(NonExistentType X)
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail: unknown event parameter type.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_EventWithInvalidParamType
 * @Provenance sha256 from theme-refs TS-FEAT-0341; lines 280-282.
 * @Provenance Expected diagnostic: "Event with invalid parameter type should fail".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * The isolated failing program: an event parameterized by an unknown type.
 *
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs NonExistentType X
 * @Return does not compile; the parameter type is undeclared
 */
event void FOnChangedBadParam(NonExistentType X);
