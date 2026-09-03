/**
 * Unknown UCLASS specifier DontCollapseCategories is rejected at the class
 * level.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UnsupportedTopLevelDontCollapseCategories
 * @Harness CompileReject
 * @Tag Definitions.UClass.UnsupportedTopLevelDontCollapseCategories
 * @Kind CompileReject
 * @Covers UClass.Specifier
 * @Inputs UCLASS(DontCollapseCategories)
 * @Return does not compile; diagnostic "Unknown class specifier DontCollapseCategories"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier DontCollapseCategories.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: Unknown class specifier DontCollapseCategories.
 * @Provenance DiagnosticOnly. Do not drop DontCollapseCategories; that would make the program compile.
 */

UCLASS(DontCollapseCategories)
class UCoverageUClassUnsupportedDontCollapseCategoriesObject : UObject
{
}
