/**
 * Unknown UCLASS specifier HideFunctions is rejected at the class level.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UnsupportedTopLevelHideFunctions
 * @Harness CompileReject
 * @Tag Definitions.UClass.UnsupportedTopLevelHideFunctions
 * @Kind CompileReject
 * @Covers UClass.Specifier
 * @Inputs UCLASS(HideFunctions="HiddenA")
 * @Return does not compile; diagnostic "Unknown class specifier HideFunctions"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier HideFunctions.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: Unknown class specifier HideFunctions.
 * @Provenance DiagnosticOnly. Do not drop HideFunctions; that would make the program compile.
 */

UCLASS(HideFunctions="HiddenA")
class UCoverageUClassUnsupportedHideFunctionsObject : UObject
{
}
