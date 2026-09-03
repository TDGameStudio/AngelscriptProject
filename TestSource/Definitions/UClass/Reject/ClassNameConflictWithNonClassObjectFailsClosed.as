/**
 * A UCLASS whose name already belongs to a non-class Unreal object is
 * rejected. Do not rename the class; that would make the program compile
 * under the C++ fixture.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.ClassNameConflictWithNonClassObjectFailsClosed
 * @Harness CompileReject
 * @Tag Definitions.UClass.ClassNameConflictWithNonClassObjectFailsClosed
 * @Kind CompileReject
 * @Covers UClass.NameConflict
 * @Inputs UCLASS UClassGeneratorNameConflictObject
 * @Return does not compile; diagnostic "has a name conflict with non-class unreal object"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: UCLASS vs a pre-existing non-class Unreal object.
 * @Provenance C++: AngelscriptClassGeneratorNameConflictTests.cpp::ClassNameConflictWithNonClassObjectFailsClosed
 * @Provenance CompileModuleWithSummary bCompiled=false. CSV SourceShape Positive is wrong; C++ expects compile failure.
 * @Provenance Expected diagnostic: has a name conflict with non-class unreal object.
 * @Provenance DiagnosticOnly. Do not rename the class; that would make the program compile under the C++ fixture.
 */

UCLASS()
class UClassGeneratorNameConflictObject : UObject
{
	UPROPERTY()
	int Value = 1;
}
