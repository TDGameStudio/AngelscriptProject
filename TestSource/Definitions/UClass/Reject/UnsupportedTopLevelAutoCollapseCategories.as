/**
 * Unknown UCLASS specifier AutoCollapseCategories is rejected at the class
 * level.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UnsupportedTopLevelAutoCollapseCategories
 * @Harness CompileReject
 * @Tag Definitions.UClass.UnsupportedTopLevelAutoCollapseCategories
 * @Kind CompileReject
 * @Covers UClass.Specifier
 * @Inputs UCLASS(AutoCollapseCategories="Advanced")
 * @Return does not compile; diagnostic "Unknown class specifier AutoCollapseCategories"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier AutoCollapseCategories.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: Unknown class specifier AutoCollapseCategories.
 * @Provenance DiagnosticOnly. Do not drop AutoCollapseCategories; that would make the program compile.
 */

UCLASS(AutoCollapseCategories="Advanced")
class UCoverageUClassUnsupportedAutoCollapseCategoriesObject : UObject
{
}
