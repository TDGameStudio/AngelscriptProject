// Purpose: Observe empty/copy FText construction and NSLOCTEXT gatherable
// literals.
// AS-facing API: FText Text(); FText Text(const FText& Other);
// FText NSLOCTEXT(const FString& Namespace, const FString& Key, const FString& Text);
// Inputs: Empty construction, copy of FromString("Hello"), and NSLOCTEXT
// literals "TestSource", "Greeting", "Hello".
// Expected observations: Default FText is empty. Copy is independent after
// later assignment of the source. NSLOCTEXT display string contains Hello.
// Boundary/ownership: NSLOCTEXT requires string literals for all three
// arguments so the gatherer can collect them.

namespace TS_FText_Behavior_01
{
	bool Observe_Text_Nominal()
	{
		FText Empty;
		FText Source = FText::FromString("Hello");
		FText Copied(Source);
		Source = FText::FromString("Other");
		return Empty.IsEmpty() && Copied.ToString().Contains("Hello") && Source.ToString().Contains("Other");
	}

	bool Observe_NSLOCTEXT_Nominal()
	{
		FText Localized = NSLOCTEXT("TestSource", "Greeting", "Hello");
		FText EmptyKey = NSLOCTEXT("TestSource", "Empty", "");
		return Localized.ToString().Contains("Hello") && EmptyKey.IsEmpty();
	}
}
