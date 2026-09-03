/**
 * Declaring a default argument from a string literal for an FText parameter is
 * rejected: the literal is an FString and does not convert to text implicitly.
 * This file is the illegal program itself; do not rewrite the default with
 * FText::FromString, since the implicit conversion is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.FTextDefaultLiteralRejected
 * @Harness CompileReject
 * @Tag Language.Literals.FTextDefaultLiteralRejected
 * @Kind CompileReject
 * @Covers Literals.FText
 * @Inputs FString TextDefaultLiteral(FText text = "DefaultText")
 * @Return does not compile; diagnostic "Default argument value ... has type const FString"
 * @Provenance C++: AngelscriptCoverageFStringFunctionTests.cpp::UnsupportedFunctionSignatureBoundaries
 * @Provenance sha256 from TS-LANG-0148; lines 709-719.
 * @Provenance Expected compile failure: Default argument value "DefaultText" has type const FString.
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

/**
 * Declare the failing string-literal default argument for an FText parameter.
 */
FString TextDefaultLiteral(FText text = "DefaultText")
{
	return text.ToString();
}

/**
 * Invoke the failing default argument implicitly.
 */
FString TextDefaultLiteralImplicit()
{
	return TextDefaultLiteral();
}
