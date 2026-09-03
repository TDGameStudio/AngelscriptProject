/**
 * A default statement whose value does not match the property type is rejected.
 * This file is the illegal program itself; do not change the string literal to an int.
 *
 * @Theme Feature.Default
 * @Subject Default.TypeMismatch
 * @Harness CompileReject
 * @Tag Feature.Default.DefaultTypeMismatch
 * @Kind CompileReject
 * @Covers Default.Attribute
 * @Inputs default Health = "hello" on an int UPROPERTY
 * @Return does not compile; diagnostic "Default with type mismatch should fail"
 * @Provenance Theme: Feature.Default. Isolated compile-fail: default value type mismatch.
 * @Provenance C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Negative AssertFailsToCompile
 * @Provenance ASSyntaxDS_AttrTypeMismatch. Expected diagnostic: "Default with type mismatch should fail".
 * @Provenance DiagnosticOnly. Do not change the string literal to an int.
 */

class AAttrTypeMismatchActor : AActor
{
	UPROPERTY()
	int Health = 0;

	default Health = "hello";
}
