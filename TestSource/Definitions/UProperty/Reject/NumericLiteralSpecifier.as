/**
 * A numeric literal used as a UPROPERTY specifier is rejected. This file is the
 * illegal program itself; do not replace 123 with a named specifier.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.NumericLiteralSpecifier
 * @Harness CompileReject
 * @Tag Definitions.UProperty.NumericLiteralSpecifier
 * @Kind CompileReject
 * @Covers UProperty.NumericLiteralSpecifier
 * @Inputs UPROPERTY(123) int X
 * @Return does not compile; diagnostic "Numeric literal as specifier should fail"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: numeric literal as specifier.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
 * @Provenance UPropSN_NumberSpec; lines 355-361;
 * @Provenance sha256=476165cb02742df45b939c5096a306c88580a222ea21dd82bfe3eda9934f2a70.
 * @Provenance Expected diagnostic: Numeric literal as specifier should fail.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

class AUPropNumSpecActor : AActor
{
	UPROPERTY(123)
	int X = 0;
}
