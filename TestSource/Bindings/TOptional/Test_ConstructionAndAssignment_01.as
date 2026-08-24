// Purpose: Observe TOptional copy assignment of set and unset states, plus
// assignment from a bare value. The bool return is the runner-readable
// oracle.
// AS-facing API: Left = Right; Optional = Value;
// Inputs: Unset Right, Right set to 7, Left copied from each, then Left = 11,
// and an FString optional assigned "Alpha".
// Expected observations: Copy of unset stays unset. Copy of 7 is set to 7
// independently of later mutation of Right. Assigning 11 sets Left. String
// assignment stores Alpha.
// Boundary/ownership: Copy assignment copies the contained value. Assigning a
// value marks the optional set without sharing storage with the source.

namespace TS_TOptional_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		TOptional<int32> UnsetRight;
		TOptional<int32> Left;
		Left = UnsetRight;
		bool bCopiedUnset = !Left.IsSet() && !UnsetRight.IsSet();
		TOptional<int32> SetRight;
		SetRight = 7;
		Left = SetRight;
		bool bCopiedSet = Left.IsSet() && Left.GetValue() == 7;
		SetRight = 9;
		bool bCopyIndependent = Left.GetValue() == 7 && SetRight.GetValue() == 9;
		Left = 11;
		TOptional<FString> Text;
		Text = "Alpha";
		return bCopiedUnset && bCopiedSet && bCopyIndependent && Left.IsSet() && Left.GetValue() == 11 && Text.IsSet() && Text.GetValue() == "Alpha";
	}
}
