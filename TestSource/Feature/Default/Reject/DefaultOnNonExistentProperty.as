/**
 * A default statement targeting a property that does not exist is rejected.
 * This file is the illegal program itself; do not declare NonExistentProp.
 *
 * @Theme Feature.Default
 * @Subject Default.OnNonExistentProperty
 * @Harness CompileReject
 * @Tag Feature.Default.DefaultOnNonExistentProperty
 * @Kind CompileReject
 * @Covers Default.Attribute
 * @Inputs default NonExistentProp = 42 on AAttrNonExistActor
 * @Return does not compile; diagnostic "Default on non-existent property should fail"
 * @Provenance Theme: Feature.Default. Isolated compile-fail: default on a missing property.
 * @Provenance C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Negative AssertFailsToCompile
 * @Provenance ASSyntaxDS_AttrNonExist. Expected diagnostic: "Default on non-existent property should fail".
 * @Provenance DiagnosticOnly. Do not declare NonExistentProp.
 */

class AAttrNonExistActor : AActor
{
	default NonExistentProp = 42;
}
