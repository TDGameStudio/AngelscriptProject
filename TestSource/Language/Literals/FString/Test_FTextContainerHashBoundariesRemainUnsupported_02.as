// Theme: Language.Literals.FString. NegativeDiagnostic: FText is not a TSet element.
// C++: AngelscriptCoverageFStringPropertyTests.cpp::FTextContainerHashBoundariesRemainUnsupported block 2
// sha256=85487d026747093f642f8b6e6d30487fe8c4019b7147079b98fa9dbb8330874e; lines 1450-1457.
// Expected diagnostic: "Key type does not have a hash function defined".
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

int UseTextSetElement()
{
	TSet<FText> Values;
	Values.Add(FText::FromString("Value"));
	return Values.Num();
}
