// Theme: Definitions.UInterface. NegativeDiagnostic: TScriptInterface property type.
// C++: AngelscriptCoverageUInterfaceTests.cpp::TScriptInterfaceTypeRejected
// ExpectUInterfaceBoundaryRejected.
// sha256=8ca0a12e6382f8ca00c51f1afb14cbcdb26c80896ceb810f280283b87317b731; lines 245-252.
// Expected diagnostic: "Expected method or property" / "Instead found identifier 'TScriptInterface'".
// Isolate this failing program. Do not add an interface that would change the diagnostic.
// DiagnosticOnly.

UCLASS()
class ACoverageUnsupportedTScriptInterfaceActor : AActor
{
	UPROPERTY()
	TScriptInterface<ICoverageUnsupportedInterface> InterfaceRef;
}
