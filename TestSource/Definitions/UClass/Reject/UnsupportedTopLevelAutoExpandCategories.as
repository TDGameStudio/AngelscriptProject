/**
 * Unknown UCLASS specifier AutoExpandCategories is rejected at the class
 * level.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UnsupportedTopLevelAutoExpandCategories
 * @Harness CompileReject
 * @Tag Definitions.UClass.UnsupportedTopLevelAutoExpandCategories
 * @Kind CompileReject
 * @Covers UClass.Specifier
 * @Inputs UCLASS(AutoExpandCategories="Coverage")
 * @Return does not compile; diagnostic "Unknown class specifier AutoExpandCategories"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier AutoExpandCategories.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: Unknown class specifier AutoExpandCategories.
 * @Provenance DiagnosticOnly. Do not drop AutoExpandCategories; that would make the program compile.
 */

UCLASS(AutoExpandCategories="Coverage")
class UCoverageUClassUnsupportedAutoExpandCategoriesObject : UObject
{
}
