/**
 * @version v1
 * @summary Observe FOverlapResult.ItemIndex as the overlapped item or body index supplied by a collision query.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FOverlapResult.ItemIndex as the overlapped item or body index supplied by a collision query.
 * @topic Baseline
 */
// as the diagnostic path.
// Expected observations: Default ItemIndex is 0. Assigning 3 is visible on a
// later read. The field is an int value, not a live geometry handle.
// Boundary/ownership: ItemIndex does not keep the overlapping body alive.
// Indexing an empty array with that value is the expected-failure path.

namespace TS_FOverlapResult_Behavior_01
{
	// int FOverlapResult.ItemIndex defaults to 0, write 3 is visible, copy keeps 3.
	bool Observe_Surface001_Nominal()
	{
		FOverlapResult Overlap;
		int DefaultIndex = Overlap.ItemIndex;
		Overlap.ItemIndex = 3;
		int WrittenIndex = Overlap.ItemIndex;
		FOverlapResult Copied = Overlap;
		return DefaultIndex == 0 && WrittenIndex == 3 && Copied.ItemIndex == 3;
	}

	void ExerciseExpectedFailure()
	{
		FOverlapResult Overlap;
		TArray<int> EmptyBodies;
		int MissingBody = EmptyBodies[Overlap.ItemIndex];
	}
}
/** @end */
