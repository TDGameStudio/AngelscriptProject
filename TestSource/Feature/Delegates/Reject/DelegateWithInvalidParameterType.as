/**
 * A delegate whose parameter type is unknown is rejected. NonExistentType is
 * not a declared script type, so the signature cannot be formed.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateWithInvalidParameterType
 * @Harness CompileReject
 * @Tag Feature.Delegates.DelegateWithInvalidParameterType
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs delegate void FOnActionBadParam(NonExistentType X)
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail: unknown delegate parameter type.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_InvalidParamType
 * @Provenance sha256=01dd64d3c6d87bbea77a857be39e3192644e58961b442a5b7ed0fb936ef2e16c; lines 171-173.
 * @Provenance Expected diagnostic: "Delegate with invalid parameter type should fail".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * The isolated failing program: a delegate parameterized by an unknown type.
 *
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs NonExistentType X
 * @Return does not compile; the parameter type is undeclared
 */
delegate void FOnActionBadParam(NonExistentType X);
