// Purpose: Observe FString declaration, literals, assignment, in-place append,
// and formatter-contributed appends.
// AS-facing API: struct FString; FString Text = "literal"; Text = Other;
// Text += Other; Text += ContributedValue; Text += Value;
// Inputs: Literal "alpha", Other "beta", empty string, integer 7 as a
// contributed/type-erased append value.
// Expected observations: Assignment replaces contents independently of Other.
// += concatenates. Appending 7 grows the string with decimal text.
// Boundary/ownership: FString is a UTF-16 value type. += mutates the
// destination; Other is copied, not moved from script's perspective.

namespace TS_FString_ConstructionAndAssignment_01
{
	// FString literal factory and default empty. Inputs "literal" and default.
	// Literal equals "literal"; default IsEmpty. Value type; no fixture.
	bool Observe_Surface001_Nominal()
	{
		FString Text = "literal";
		FString Empty;
		return Text == "literal" && Empty.IsEmpty();
	}

	// FString assignment. Inputs "alpha" then Other "beta", then Other "gamma".
	// Text becomes "beta" and stays "beta" after Other changes. Copy, not alias.
	bool Observe_Assignment_Nominal()
	{
		FString Text = "alpha";
		FString Other = "beta";
		Text = Other;
		Other = "gamma";
		return Text == "beta" && Other == "gamma";
	}

	// FString += FString/int. Inputs "alpha" + "beta", then 7, then 8, and
	// empty += "x". Result contains alphabeta/7/8; empty becomes "x". Mutates
	// the destination.
	bool Observe_AddAssign_Nominal()
	{
		FString Text = "alpha";
		Text += "beta";
		Text += 7;
		int32 Value = 8;
		Text += Value;
		FString Empty = "";
		Empty += "x";
		return Text.StartsWith("alphabeta") && Text.Contains("7") && Text.Contains("8") && Empty == "x";
	}
}
