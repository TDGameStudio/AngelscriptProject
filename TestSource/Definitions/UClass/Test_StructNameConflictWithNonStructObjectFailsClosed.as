// Theme: Definitions.UClass. Isolated compile-fail: USTRUCT vs a pre-existing non-struct Unreal object.
// C++: AngelscriptClassGeneratorNameConflictTests.cpp::StructNameConflictWithNonStructObjectFailsClosed
// CompileModuleWithSummary bCompiled=false. CSV SourceShape Positive is wrong; C++ expects compile failure.
// Expected diagnostic: has a name conflict with non-struct unreal object.
// DiagnosticOnly. Do not rename the struct; that would make the program compile under the C++ fixture.

USTRUCT()
struct FClassGeneratorNameConflictStruct
{
	UPROPERTY()
	int Value = 1;
}
