/**
 * Unknown UCLASS specifier ProjectUserConfig is rejected.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UnsupportedProjectUserConfig
 * @Harness CompileReject
 * @Tag Definitions.UClass.UnsupportedProjectUserConfig
 * @Kind CompileReject
 * @Covers UClass.Specifier
 * @Inputs UCLASS(ProjectUserConfig)
 * @Return does not compile; diagnostic "Unknown class specifier ProjectUserConfig"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier ProjectUserConfig.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: Unknown class specifier ProjectUserConfig.
 * @Provenance DiagnosticOnly. Do not drop ProjectUserConfig; that would make the program compile.
 */

UCLASS(ProjectUserConfig)
class UCoverageUClassUnsupportedProjectUserConfigObject : UObject
{
}
