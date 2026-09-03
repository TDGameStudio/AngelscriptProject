/**
 * Unknown UCLASS specifier NonTransient is rejected.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UnsupportedNonTransient
 * @Harness CompileReject
 * @Tag Definitions.UClass.UnsupportedNonTransient
 * @Kind CompileReject
 * @Covers UClass.Specifier
 * @Inputs UCLASS(NonTransient)
 * @Return does not compile; diagnostic "Unknown class specifier NonTransient"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: unknown UCLASS specifier NonTransient.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassUnsupportedSpecifierBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: Unknown class specifier NonTransient.
 * @Provenance DiagnosticOnly. Do not drop NonTransient; that would make the program compile.
 */

UCLASS(NonTransient)
class UCoverageUClassUnsupportedNonTransientObject : UObject
{
}
