/**
 * UFUNCTION may not annotate a constructor. AUFuncCtorActor() is a constructor,
 * not a reflected method. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.UFunctionOnConstructor
 * @Harness CompileReject
 * @Tag Definitions.UFunction.UFunctionOnConstructor
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION() AUFuncCtorActor()
 * @Return does not compile; diagnostic "UFUNCTION on constructor should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: UFUNCTION on a constructor.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 14 AssertFailsToCompile.
 * @Provenance sha256=c266124d4f7ff774ec32dc1d9de6809ba879f2c1e9a8bec1b8658bc7dff55e19; lines 348-354.
 * @Provenance Expected compile failure: "UFUNCTION on constructor should fail".
 */

class AUFuncCtorActor : AActor
{
	/**
	 * Illegal UFUNCTION annotating the class constructor.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION() AUFuncCtorActor()
	 * @Return does not compile
	 */
	UFUNCTION()
	AUFuncCtorActor()
	{
	}
}
