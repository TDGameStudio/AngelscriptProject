/**
 * A TScriptInterface property type is rejected without script interfaces.
 * Do not add an interface declaration that would change the diagnostic.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.TScriptInterfaceTypeRejected
 * @Harness CompileReject
 * @Tag Definitions.UInterface.TScriptInterfaceTypeRejected
 * @Kind CompileReject
 * @Covers UInterface.TScriptInterfaceTypeRejected
 * @Inputs TScriptInterface<ICoverageUnsupportedInterface> InterfaceRef
 * @Return does not compile; "Expected method or property" / "Instead found identifier 'TScriptInterface'"
 * @Provenance Theme: Definitions.UInterface. NegativeDiagnostic: TScriptInterface property type.
 * @Provenance C++: AngelscriptCoverageUInterfaceTests.cpp::TScriptInterfaceTypeRejected
 * @Provenance ExpectUInterfaceBoundaryRejected.
 * @Provenance sha256=8ca0a12e6382f8ca00c51f1afb14cbcdb26c80896ceb810f280283b87317b731; lines 245-252.
 * @Provenance Expected diagnostic: "Expected method or property" / "Instead found identifier 'TScriptInterface'".
 * @Provenance Isolate this failing program. Do not add an interface that would change the diagnostic.
 * @Provenance DiagnosticOnly.
 */

UCLASS()
class ACoverageUnsupportedTScriptInterfaceActor : AActor
{
	UPROPERTY()
	TScriptInterface<ICoverageUnsupportedInterface> InterfaceRef;
}
