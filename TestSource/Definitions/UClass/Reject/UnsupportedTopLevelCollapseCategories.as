/**
 * Unknown UCLASS specifier CollapseCategories is rejected at the class level.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UnsupportedTopLevelCollapseCategories
 * @Harness CompileReject
 * @Tag Definitions.UClass.UnsupportedTopLevelCollapseCategories
 * @Kind CompileReject
 * @Covers UClass.Specifier
 * @Inputs UCLASS(CollapseCategories)
 * @Return does not compile; diagnostic "Unknown class specifier CollapseCategories"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier CollapseCategories.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: Unknown class specifier CollapseCategories.
 * @Provenance DiagnosticOnly. Do not drop CollapseCategories; that would make the program compile.
 */

UCLASS(CollapseCategories)
class UCoverageUClassUnsupportedCollapseCategoriesObject : UObject
{
}
