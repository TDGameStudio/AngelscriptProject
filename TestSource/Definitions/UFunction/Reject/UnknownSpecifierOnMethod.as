/**
 * An unknown UFUNCTION specifier on a generated method is rejected.
 * DefinitelyUnknownSpecifier is not a legal function specifier. This file is
 * the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.UnknownSpecifierOnMethod
 * @Harness CompileReject
 * @Tag Definitions.UFunction.UnknownSpecifierOnMethod
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(DefinitelyUnknownSpecifier) void UnknownSpecifier()
 * @Return does not compile; diagnostic "Unknown function specifier DefinitelyUnknownSpecifier on method ACoverageUFunctionUnknownSpecifierActor::UnknownSpecifier."
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: unknown UFUNCTION specifier.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case unknown function specifier.
 * @Provenance Expected compile failure: "Unknown function specifier DefinitelyUnknownSpecifier on method ACoverageUFunctionUnknownSpecifierActor::UnknownSpecifier."
 */

UCLASS()
class ACoverageUFunctionUnknownSpecifierActor : AActor
{
	/**
	 * Illegal UFUNCTION using DefinitelyUnknownSpecifier.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(DefinitelyUnknownSpecifier)
	 * @Return does not compile
	 */
	UFUNCTION(DefinitelyUnknownSpecifier)
	void UnknownSpecifier()
	{
	}
}
