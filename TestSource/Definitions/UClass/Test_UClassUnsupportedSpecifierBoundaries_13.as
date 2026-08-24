// Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier SparseClassDataTypes.
// C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: Unknown class specifier SparseClassDataTypes.
// DiagnosticOnly. Do not drop SparseClassDataTypes; that would make the program compile.

UCLASS(SparseClassDataTypes="SparseData")
class UCoverageUClassUnsupportedSparseClassDataTypesObject : UObject
{
}
