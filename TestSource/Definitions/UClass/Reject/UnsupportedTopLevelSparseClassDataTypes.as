/**
 * Unknown UCLASS specifier SparseClassDataTypes is rejected at the class
 * level.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UnsupportedTopLevelSparseClassDataTypes
 * @Harness CompileReject
 * @Tag Definitions.UClass.UnsupportedTopLevelSparseClassDataTypes
 * @Kind CompileReject
 * @Covers UClass.Specifier
 * @Inputs UCLASS(SparseClassDataTypes="SparseData")
 * @Return does not compile; diagnostic "Unknown class specifier SparseClassDataTypes"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier SparseClassDataTypes.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: Unknown class specifier SparseClassDataTypes.
 * @Provenance DiagnosticOnly. Do not drop SparseClassDataTypes; that would make the program compile.
 */

UCLASS(SparseClassDataTypes="SparseData")
class UCoverageUClassUnsupportedSparseClassDataTypesObject : UObject
{
}
