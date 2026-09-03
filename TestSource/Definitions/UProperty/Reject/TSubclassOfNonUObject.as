/**
 * TSubclassOf of a non-UObject type is rejected. This file is the illegal
 * program itself; do not replace int with a UObject-derived class.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.TSubclassOfNonUObject
 * @Harness CompileReject
 * @Tag Definitions.UProperty.TSubclassOfNonUObject
 * @Kind CompileReject
 * @Covers UProperty.TSubclassOfNonUObject
 * @Inputs UPROPERTY() TSubclassOf<int> BadClass
 * @Return does not compile; diagnostic "TSubclassOf with non-UObject type should fail"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: TSubclassOf of a non-UObject type.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative AssertFailsToCompile
 * @Provenance UPropTN_SubclassNonObj; lines 520-526;
 * @Provenance sha256=eb7e32475987057a0fd93a770775d3f4d4bd2bea92e1dd2f61b95f3ac39d522f.
 * @Provenance Expected diagnostic: TSubclassOf with non-UObject type should fail.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

class AUPropSubNonObjActor : AActor
{
	UPROPERTY()
	TSubclassOf<int> BadClass;
}
