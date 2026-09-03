/**
 * Unknown UCLASS specifier ShowCategories is rejected at the class level.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UnsupportedTopLevelShowCategories
 * @Harness CompileReject
 * @Tag Definitions.UClass.UnsupportedTopLevelShowCategories
 * @Kind CompileReject
 * @Covers UClass.Specifier
 * @Inputs UCLASS(ShowCategories="Rendering")
 * @Return does not compile; diagnostic "Unknown class specifier ShowCategories"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier ShowCategories.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: Unknown class specifier ShowCategories.
 * @Provenance DiagnosticOnly. Do not drop ShowCategories; that would make the program compile.
 */

UCLASS(ShowCategories="Rendering")
class UCoverageUClassUnsupportedShowCategoriesObject : UObject
{
}
