/**
 * TArray of TScriptInterface is an explicit unsupported container boundary.
 * Do not add an interface declaration that would change the diagnostic.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.TScriptInterfaceArrayRejected
 * @Harness CompileReject
 * @Tag Definitions.UInterface.TScriptInterfaceArrayRejected
 * @Kind CompileReject
 * @Covers UInterface.TScriptInterfaceArrayRejected
 * @Inputs TArray<TScriptInterface<ICoverageUnsupportedInterface>> InterfaceRefs
 * @Return does not compile; "Expected method or property" / "Instead found identifier 'TArray'"
 * @Provenance Theme: Definitions.UInterface. NegativeDiagnostic: TArray of TScriptInterface is unsupported.
 * @Provenance C++: AngelscriptCoverageUInterfaceTests.cpp::TScriptInterfaceArrayRejected
 * @Provenance Expected compile failure: "Expected method or property" / "Instead found identifier 'TArray'".
 * @Provenance Isolate the failing program. Do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

UCLASS()
class ACoverageUnsupportedTScriptInterfaceArrayActor : AActor
{
	UPROPERTY()
	TArray<TScriptInterface<ICoverageUnsupportedInterface>> InterfaceRefs;
}
