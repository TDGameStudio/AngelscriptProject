/**
 * An unknown UFUNCTION specifier is rejected. InvalidSpecifier is not a legal
 * function specifier, so the declaration cannot be generated. This file is
 * the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.UnknownFunctionSpecifier
 * @Harness CompileReject
 * @Tag Definitions.UFunction.UnknownFunctionSpecifier
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(InvalidSpecifier) void Foo()
 * @Return does not compile; diagnostic "Unknown function specifier"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: unknown UFUNCTION specifier.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 1 AssertFailsToCompile.
 * @Provenance sha256=5122ab921557e4fbae355c52149b9e8a3b6f750c6783c885bc18c8f08a9c82fa; lines 199-205.
 * @Provenance Expected compile failure: "Unknown function specifier" (Contains, 3).
 */

class AUFuncInvalidActor : AActor
{
	/**
	 * Illegal UFUNCTION using an unknown specifier.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(InvalidSpecifier)
	 * @Return does not compile
	 */
	UFUNCTION(InvalidSpecifier)
	void Foo()
	{
	}
}
