/**
 * Unknown UCLASS specifier Placeable is rejected.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UnsupportedExplicitPlaceable
 * @Harness CompileReject
 * @Tag Definitions.UClass.UnsupportedExplicitPlaceable
 * @Kind CompileReject
 * @Covers UClass.Specifier
 * @Inputs UCLASS(Placeable)
 * @Return does not compile; diagnostic "Unknown class specifier Placeable"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier Placeable.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: Unknown class specifier Placeable.
 * @Provenance DiagnosticOnly. Do not drop Placeable; that would make the program compile.
 */

UCLASS(Placeable)
class ACoverageUClassUnsupportedExplicitPlaceableActor : AActor
{
}
