// Theme: Definitions.UClass. Isolated compile-fail: UCLASS vs a pre-existing non-class Unreal object.
// C++: AngelscriptClassGeneratorNameConflictTests.cpp::ClassNameConflictWithNonClassObjectFailsClosed
// CompileModuleWithSummary bCompiled=false. CSV SourceShape Positive is wrong; C++ expects compile failure.
// Expected diagnostic: has a name conflict with non-class unreal object.
// DiagnosticOnly. Do not rename the class; that would make the program compile under the C++ fixture.

UCLASS()
class UClassGeneratorNameConflictObject : UObject
{
	UPROPERTY()
	int Value = 1;
}
