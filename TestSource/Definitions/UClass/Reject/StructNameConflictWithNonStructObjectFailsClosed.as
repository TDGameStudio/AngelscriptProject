/**
 * A USTRUCT whose name already belongs to a non-struct Unreal object is
 * rejected. Do not rename the struct; that would make the program compile
 * under the C++ fixture.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.StructNameConflictWithNonStructObjectFailsClosed
 * @Harness CompileReject
 * @Tag Definitions.UClass.StructNameConflictWithNonStructObjectFailsClosed
 * @Kind CompileReject
 * @Covers UClass.NameConflict
 * @Inputs USTRUCT FClassGeneratorNameConflictStruct
 * @Return does not compile; diagnostic "has a name conflict with non-struct unreal object"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: USTRUCT vs a pre-existing non-struct Unreal object.
 * @Provenance C++: AngelscriptClassGeneratorNameConflictTests.cpp::StructNameConflictWithNonStructObjectFailsClosed
 * @Provenance CompileModuleWithSummary bCompiled=false. CSV SourceShape Positive is wrong; C++ expects compile failure.
 * @Provenance Expected diagnostic: has a name conflict with non-struct unreal object.
 * @Provenance DiagnosticOnly. Do not rename the struct; that would make the program compile under the C++ fixture.
 */

USTRUCT()
struct FClassGeneratorNameConflictStruct
{
	UPROPERTY()
	int Value = 1;
}
