/**
 * Unknown UCLASS specifier NotBlueprintType is rejected.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UnsupportedNotBlueprintType
 * @Harness CompileReject
 * @Tag Definitions.UClass.UnsupportedNotBlueprintType
 * @Kind CompileReject
 * @Covers UClass.Specifier
 * @Inputs UCLASS(NotBlueprintType)
 * @Return does not compile; diagnostic "Unknown class specifier NotBlueprintType"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier NotBlueprintType.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: Unknown class specifier NotBlueprintType.
 * @Provenance DiagnosticOnly. Do not drop NotBlueprintType; that would make the program compile.
 */

UCLASS(NotBlueprintType)
class UCoverageUClassUnsupportedNotBlueprintTypeObject : UObject
{
}
