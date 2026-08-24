// Theme: HotReload VersionPair After. Isolated failing reload source.
// C++: AngelscriptHotReloadFunctionTests.cpp::FailureKeepsOldCodeAndDiagnostics
// Expected diagnostic: Identifier 'MissingType' is not a data type; keep old script code.
// Retained live state: Before GetValue still returns 5.
// Replaced: this broken GetValue body must not become active.
// FixtureIsolated. Do not add declarations that would make this compile.

UCLASS()
class UHotReloadFailureKeepsOldCode : UObject
{
	UFUNCTION()
	MissingType GetValue()
	{
		MissingType Value;
		return Value;
	}
}
