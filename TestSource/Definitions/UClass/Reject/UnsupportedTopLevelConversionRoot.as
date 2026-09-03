/**
 * Unknown UCLASS specifier ConversionRoot is rejected at the class level.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UnsupportedTopLevelConversionRoot
 * @Harness CompileReject
 * @Tag Definitions.UClass.UnsupportedTopLevelConversionRoot
 * @Kind CompileReject
 * @Covers UClass.Specifier
 * @Inputs UCLASS(ConversionRoot)
 * @Return does not compile; diagnostic "Unknown class specifier ConversionRoot"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier ConversionRoot.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: Unknown class specifier ConversionRoot.
 * @Provenance DiagnosticOnly. Do not drop ConversionRoot; that would make the program compile.
 */

UCLASS(ConversionRoot)
class UCoverageUClassUnsupportedConversionRootObject : UObject
{
}
