// Theme: Language.Literals.FString. NegativeDiagnostic: FText is not a TMap key.
// C++: AngelscriptCoverageFStringPropertyTests.cpp::FTextContainerHashBoundariesRemainUnsupported block 1
// sha256=6234e1e68216ab64a3f52a2a04b0ff5738bfa90060b1a3935ead9c289e9b1a75; lines 1435-1442.
// Expected diagnostic: "Key type does not have a hash function defined".
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

int UseTextMapKey()
{
	TMap<FText, int> Values;
	Values.Add(FText::FromString("Key"), 1);
	return Values.Num();
}
