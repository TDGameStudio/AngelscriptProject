/**
 * A BlueprintEvent UFUNCTION must return void. GetVal returning int is
 * illegal. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.BlueprintEventNonVoidReturn
 * @Harness CompileReject
 * @Tag Definitions.UFunction.BlueprintEventNonVoidReturn
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(BlueprintEvent) int GetVal()
 * @Return does not compile; diagnostic "BlueprintEvent with non-void return should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintEvent with non-void return.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 7 AssertFailsToCompile.
 * @Provenance sha256=77648f9a3c595b56ced25e90118004867a0d875cf7c864e25b7328ac518aaf1c; lines 267-273.
 * @Provenance C++ currently wraps this AssertFailsToCompile in #if 0
 * @Provenance (#as-engine-behavior structural-validation-absent). Isolated failing program kept.
 * @Provenance Expected compile failure: "BlueprintEvent with non-void return should fail".
 */

class AUFuncBPEvNVActor : AActor
{
	/**
	 * Illegal BlueprintEvent that returns int instead of void.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(BlueprintEvent) int GetVal()
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintEvent)
	int GetVal()
	{
		return 0;
	}
}
