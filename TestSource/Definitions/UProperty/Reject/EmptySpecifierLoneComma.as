/**
 * An empty specifier list that is only a comma is rejected. This file is the
 * illegal program itself; do not add a real specifier.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.EmptySpecifierLoneComma
 * @Harness CompileReject
 * @Tag Definitions.UProperty.EmptySpecifierLoneComma
 * @Kind CompileReject
 * @Covers UProperty.EmptySpecifierLoneComma
 * @Inputs UPROPERTY(,) int X
 * @Return does not compile; diagnostic "Empty specifier with lone comma should fail"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: empty specifier with a lone comma.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
 * @Provenance UPropSN_EmptyComma; lines 333-339;
 * @Provenance sha256=5a22345079496b99efc95a0ba9ea065517663ec14b4545632097998e223d5c80.
 * @Provenance Expected diagnostic: Empty specifier with lone comma should fail.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

class AUPropEmptyCommaActor : AActor
{
	UPROPERTY(,)
	int X = 0;
}
