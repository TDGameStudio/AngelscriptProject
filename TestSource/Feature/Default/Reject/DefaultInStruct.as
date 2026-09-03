/**
 * A default statement inside a struct is rejected. Default statements belong
 * on UCLASS / actor class bodies. This file is the illegal program itself;
 * do not move default onto a UCLASS.
 *
 * @Theme Feature.Default
 * @Subject Default.InStruct
 * @Harness CompileReject
 * @Tag Feature.Default.DefaultInStruct
 * @Kind CompileReject
 * @Covers Default.Attribute
 * @Inputs default X = 5 inside struct FAttrStruct
 * @Return does not compile; diagnostic "Default statement in struct should fail"
 * @Provenance Theme: Feature.Default. Isolated compile-fail: default statement inside a struct.
 * @Provenance C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Negative AssertFailsToCompile
 * @Provenance ASSyntaxDS_AttrInStruct. Expected diagnostic: "Default statement in struct should fail".
 * @Provenance DiagnosticOnly. Do not move default onto a UCLASS.
 */

struct FAttrStruct
{
	int X = 0;

	default X = 5;
}
