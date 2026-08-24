// Purpose: Observe FName assignment, string prefixing, and formatter
// interpolation.
// AS-facing API: Left = Right; FString Combined = Name + String;
// Name += String; FString Text = f"{Name}";
// Inputs: n"Alpha", copy into Left from NAME_None, suffix "_Tail", and empty
// string as the zero operand.
// Expected observations: Assignment replaces Left with Alpha identity.
// Name + "_Tail" returns text that starts with Alpha. += prefixes the string
// operand. f"{Name}" is non-empty.
// Boundary/ownership: FName assignment copies interned identity, not a new
// string buffer. + returns a new FString; the name itself is unchanged.

namespace TS_FName_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FName Left = NAME_None;
		FName Right = n"Alpha";
		Left = Right;
		FString Formatted = f"{Left}";
		return Left == Right && Left != NAME_None && Formatted.Len() > 0;
	}

	bool Observe_AddAssign_Nominal()
	{
		FName Name = n"Alpha";
		FString Combined = Name + "_Tail";
		FString Operand = "_Tail";
		Name += Operand;
		FString Empty = "";
		FString EmptyCombined = Name + Empty;
		return Combined == "Alpha_Tail" && Operand == "Alpha_Tail" && EmptyCombined == "Alpha";
	}
}
