/**
 * @version v1
 * @summary Observe four-word and string FGuid constructors, lexical ordering, and Invalidate.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe four-word and string FGuid constructors, lexical ordering, and Invalidate.
 * @topic Baseline
 */
// FGuid Guid(const FString& InGuidStr); bool bOrdered = Left < Right;
// void Guid.Invalidate();
// Inputs: Words (1,2,3,4), the default ToString of that GUID, empty string
// construction as the boundary, and a larger GUID for ordering.
// Expected observations: Word constructor stores indexable words. String
// constructor round-trips ToString. Left < Right is true for (1,..) vs
// (5,..). Invalidate clears IsValid.
// Boundary/ownership: Invalid string construction is the diagnostic path.
// Ordering uses the same opCmp surface for <=, >, and >=.

namespace TS_FGuid_Behavior_01
{
	bool Observe_Guid_Nominal()
	{
		FGuid FromWords(1, 2, 3, 4);
		FString Text = FromWords.ToString();
		FGuid FromString(Text);
		return FromWords[0] == 1 && FromWords[3] == 4 && FromString == FromWords;
	}

	bool Observe_Ordering_Nominal()
	{
		FGuid Left(1, 2, 3, 4);
		FGuid Right(5, 6, 7, 8);
		return Left < Right && Left <= Right && Right > Left && Right >= Left;
	}

	bool Observe_Invalidate_Nominal()
	{
		FGuid Guid(1, 2, 3, 4);
		bool bWasValid = Guid.IsValid();
		Guid.Invalidate();
		bool bNowInvalid = !Guid.IsValid();
		Guid.Invalidate();
		bool bRepeatedInvalidateStable = !Guid.IsValid();
		return bWasValid && bNowInvalid && bRepeatedInvalidateStable;
	}

	void ExerciseExpectedFailure()
	{
		FGuid Invalid("not-a-guid");
	}
}
/** @end */
