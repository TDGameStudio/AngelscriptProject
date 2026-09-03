/**
 * Unknown UCLASS specifier GlobalUserConfig is rejected.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UnsupportedGlobalUserConfig
 * @Harness CompileReject
 * @Tag Definitions.UClass.UnsupportedGlobalUserConfig
 * @Kind CompileReject
 * @Covers UClass.Specifier
 * @Inputs UCLASS(GlobalUserConfig)
 * @Return does not compile; diagnostic "Unknown class specifier GlobalUserConfig"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier GlobalUserConfig.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: Unknown class specifier GlobalUserConfig.
 * @Provenance DiagnosticOnly. Do not drop GlobalUserConfig; that would make the program compile.
 */

UCLASS(GlobalUserConfig)
class UCoverageUClassUnsupportedGlobalUserConfigObject : UObject
{
}
