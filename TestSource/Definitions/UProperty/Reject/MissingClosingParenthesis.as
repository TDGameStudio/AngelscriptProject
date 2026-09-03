/**
 * A UPROPERTY missing its closing parenthesis is rejected. This file is the
 * illegal program itself; do not close the specifier list.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.MissingClosingParenthesis
 * @Harness CompileReject
 * @Tag Definitions.UProperty.MissingClosingParenthesis
 * @Kind CompileReject
 * @Covers UProperty.MissingClosingParenthesis
 * @Inputs UPROPERTY( int X = 0;
 * @Return does not compile; diagnostic "Missing closing parenthesis should fail"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: missing UPROPERTY closing paren.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
 * @Provenance UPropSN_MissingParen; lines 263-268;
 * @Provenance sha256=7e65ded9b0372ba9a6ffefc4e0891c06ebcf6b60621402ee1192a57313e87106.
 * @Provenance Expected diagnostic: Missing closing parenthesis should fail.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

class AUPropMisParenActor : AActor
{
	UPROPERTY( int X = 0;
}
