/**
 * UFUNCTION may not annotate a property. int X is a field, not a method, so
 * the specifier is illegal. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.UFunctionOnProperty
 * @Harness CompileReject
 * @Tag Definitions.UFunction.UFunctionOnProperty
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION() int X = 0
 * @Return does not compile; diagnostic "UFUNCTION on property should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: UFUNCTION on a property.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 4 AssertFailsToCompile.
 * @Provenance sha256=e880cbd81a548f16e71fffac7ce45797473bf9f1fd014c5d79e033c3c96dc688; lines 232-238.
 * @Provenance Expected compile failure: "UFUNCTION on property should fail".
 */

class AUFuncOnPropActor : AActor
{
	UFUNCTION()
	int X = 0;
}
