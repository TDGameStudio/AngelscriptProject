// Purpose: Observe FInputActionKeyMapping equality on action name, key, and
// modifier flags.
// AS-facing API: bool bEqual = Mapping == Other;
// Inputs: Default-constructed mappings, a Jump/SpaceBar mapping, an identical
// copy, a different action name, and a Shift-modified copy.
// Expected observations: Defaults compare equal. Identical name/key/modifiers
// compare true. Changing ActionName, Key, or bShift makes equality false.
// Boundary/ownership: Equality compares value fields. Copies are independent
// after assignment.

namespace TS_FInputActionKeyMapping_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FInputActionKeyMapping Left;
		FInputActionKeyMapping Right;
		bool bDefaultsEqual = Left == Right;

		Left.ActionName = n"Jump";
		Left.Key = n"SpaceBar";
		bool bNamedDiffersFromDefault = !(Left == Right);

		FInputActionKeyMapping Copy = Left;
		bool bCopyEqualsSource = Copy == Left;

		Copy.bShift = true;
		bool bShiftDiffers = !(Copy == Left);

		FInputActionKeyMapping Other;
		Other.ActionName = n"Fire";
		Other.Key = n"SpaceBar";
		bool bActionNameDiffers = !(Left == Other);

		FInputActionKeyMapping DifferentKey;
		DifferentKey.ActionName = n"Jump";
		DifferentKey.Key = n"Enter";
		bool bKeyDiffers = !(Left == DifferentKey);

		return bDefaultsEqual && bNamedDiffersFromDefault && bCopyEqualsSource && bShiftDiffers && bActionNameDiffers && bKeyDiffers;
	}
}
