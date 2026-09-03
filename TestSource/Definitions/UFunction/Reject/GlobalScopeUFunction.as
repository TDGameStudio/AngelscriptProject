/**
 * A UFUNCTION at global scope is rejected. UFUNCTION methods belong on a
 * UCLASS or the generated statics class, not as a bare global. This file is
 * the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.GlobalScopeUFunction
 * @Harness CompileReject
 * @Tag Definitions.UFunction.GlobalScopeUFunction
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION() void GlobalFunc()
 * @Return does not compile; diagnostic "UFUNCTION at global scope should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: UFUNCTION at global scope.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 2 AssertFailsToCompile.
 * @Provenance sha256=9b8c187c821bb2f8849931ff846d300aff4402e7cc0369e80c4a960c026686a0; lines 211-213.
 * @Provenance C++ currently wraps this AssertFailsToCompile in #if 0
 * @Provenance (#as-engine-behavior structural-validation-absent). Isolated failing program kept.
 * @Provenance Expected compile failure: UFUNCTION at global scope should fail.
 */

/**
 * Illegal global UFUNCTION with no owning class.
 *
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION() void GlobalFunc()
 * @Return does not compile
 */
UFUNCTION()
void GlobalFunc()
{
}
