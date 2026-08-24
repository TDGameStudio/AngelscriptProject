// Theme: Definitions.UInterface. NegativeDiagnostic: TArray of TScriptInterface is unsupported.
// C++: AngelscriptCoverageUInterfaceTests.cpp::TScriptInterfaceArrayRejected
// Expected compile failure: "Expected method or property" / "Instead found identifier 'TArray'".
// Isolate the failing program. Do not add declarations that would compile it away.
// DiagnosticOnly.

UCLASS()
class ACoverageUnsupportedTScriptInterfaceArrayActor : AActor
{
	UPROPERTY()
	TArray<TScriptInterface<ICoverageUnsupportedInterface>> InterfaceRefs;
}
