/**
 * @version v1
 * @summary Observe GUID equality and indexed word access, including aliasing through the mutable subscript.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe GUID equality and indexed word access, including aliasing through the mutable subscript.
 * @topic Baseline
 */
// const uint32& Word = ConstGuid[Index];
// Inputs: Guid(1,2,3,4), an identical copy, a zero Guid(0,0,0,0), and index
// 0 as the first word plus 3 as the last word.
// Expected observations: Identical GUIDs compare true. Zero vs nonzero is
// false. Guid[0] is 1. Assigning through the mutable reference changes word 0
// and is visible on a later read of Guid[0].
// Boundary/ownership: Subscript returns an alias into the GUID words.
// Out-of-range index is the diagnostic path.

namespace TS_FGuid_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FGuid Left(1, 2, 3, 4);
		FGuid Right(1, 2, 3, 4);
		FGuid Zero(0, 0, 0, 0);
		return Left == Right && !(Left == Zero);
	}

	bool Observe_Index_Nominal()
	{
		FGuid Guid(1, 2, 3, 4);
		uint32 First = Guid[0];
		uint32 Last = Guid[3];
		Guid[0] = 9;
		uint32 Aliased = Guid[0];
		const FGuid ConstGuid(1, 2, 3, 4);
		uint32 ConstWord = ConstGuid[1];
		return First == 1 && Last == 4 && Aliased == 9 && ConstWord == 2;
	}

	void ExerciseExpectedFailure()
	{
		FGuid Guid(1, 2, 3, 4);
		uint32 OutOfRange = Guid[4];
	}
}
/** @end */
