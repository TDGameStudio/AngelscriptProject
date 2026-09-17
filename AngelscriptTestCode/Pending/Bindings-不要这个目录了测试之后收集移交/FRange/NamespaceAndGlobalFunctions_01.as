/**
 * @version v1
 * @summary Observe FFloatRange::Difference pieces, empty coverage, and the open-bound GetValue diagnostic path.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FFloatRange::Difference pieces, empty coverage, and the open-bound GetValue diagnostic path.
 * @topic Baseline
 */
// const FFloatRange& B);
// Inputs: A [0,10) minus B [2,4), A fully covered by a wider B, and identical
// ranges. Open bound GetValue is the diagnostic companion.
// Expected observations: Partial difference yields two pieces, one containing
// 1 and one containing 8. Full coverage and identical ranges yield empty
// arrays.
// Boundary/ownership: Difference returns new range pieces of A not covered by
// B. It does not mutate A or B. GetValue on an open bound is native-undefined.

namespace TS_FRange_NamespaceAndGlobalFunctions_01
{
	bool Observe_Difference_Nominal()
	{
		FFloatRange Whole(0.0, 10.0);
		FFloatRange Hole(2.0, 4.0);
		TArray<FFloatRange> Pieces = FFloatRange::Difference(Whole, Hole);
		TArray<FFloatRange> Covered = FFloatRange::Difference(Whole, FFloatRange(-1.0, 11.0));
		TArray<FFloatRange> Identical = FFloatRange::Difference(Whole, FFloatRange(0.0, 10.0));
		return Pieces.Num() == 2 && (Pieces[0].Contains(1.0) || Pieces[1].Contains(1.0)) && (Pieces[0].Contains(8.0) || Pieces[1].Contains(8.0)) && !Pieces[0].Contains(3.0) && !Pieces[1].Contains(3.0) && Covered.Num() == 0 && Identical.Num() == 0;
	}

	void ExerciseExpectedFailure()
	{
		FFloatRangeBound Open = FFloatRangeBound::Open();
		float32 Invalid = Open.GetValue();
	}
}
/** @end */
