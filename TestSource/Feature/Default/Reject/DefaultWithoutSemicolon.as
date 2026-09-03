/**
 * A default statement without a terminating semicolon is rejected.
 * This file is the illegal program itself; do not add the missing semicolon.
 *
 * @Theme Feature.Default
 * @Subject Default.WithoutSemicolon
 * @Harness CompileReject
 * @Tag Feature.Default.DefaultWithoutSemicolon
 * @Kind CompileReject
 * @Covers Default.Attribute
 * @Inputs default X = 5 with no semicolon
 * @Return does not compile; diagnostic "Default without semicolon should fail"
 * @Provenance Theme: Feature.Default. Isolated compile-fail: default statement without a semicolon.
 * @Provenance C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Negative AssertFailsToCompile
 * @Provenance ASSyntaxDS_AttrNoSemicolon. Expected diagnostic: "Default without semicolon should fail".
 * @Provenance DiagnosticOnly. Do not add the missing semicolon.
 */

class AAttrNoSemiActor : AActor
{
	UPROPERTY()
	int X = 0;

	default X = 5
}
