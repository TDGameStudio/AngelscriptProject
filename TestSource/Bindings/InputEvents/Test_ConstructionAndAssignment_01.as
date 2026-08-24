// Purpose: Observe implicit FName-to-FKey conversion and FKey string
// formatting, including copy assignment and the empty key.
// AS-facing API: FKey Key = Name; FString Text = f"{Key}";
// Inputs: n"SpaceBar" as the named key, a copied FKey, and a default-constructed
// empty key.
// Expected observations: Implicit conversion yields a key whose formatted
// text contains SpaceBar. A copy equals the source. Formatting the empty key
// still produces a consumed FString.
// Boundary/ownership: Conversion copies the name into a new FKey. Formatting
// returns a new FString and does not own the key.

namespace TS_InputEvents_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FName Name = n"SpaceBar";
		FKey Key = Name;
		FKey Copied = Key;
		FKey Empty;
		FString Text = f"{Key}";
		FString CopiedText = f"{Copied}";
		FString EmptyText = f"{Empty}";
		FKey Assigned;
		Assigned = Name;
		FString AssignedText = f"{Assigned}";
		return Text.Contains("SpaceBar") && CopiedText == Text && AssignedText == Text && EmptyText == "None";
	}
}
