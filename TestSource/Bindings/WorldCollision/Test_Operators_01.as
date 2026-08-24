// Purpose: Observe packed FTraceHandle equality, including default, identical
// packed values, and a distinct packed value.
// AS-facing API: Handle == Other;
// Inputs: Two default handles, two handles packed from uint64 1, and one handle
// packed from uint64 2.
// Expected observations: Default handles compare equal. Identical packed
// values compare equal. 1 vs 2 compares false. Equality does not mutate either
// handle.
// Boundary/ownership: Comparison uses packed identity, not query completion
// state.

namespace TS_WorldCollision_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FTraceHandle Left;
		FTraceHandle Right;
		uint64 FirstValue = 1;
		uint64 SecondValue = 2;
		FTraceHandle First(FirstValue);
		FTraceHandle FirstCopy(FirstValue);
		FTraceHandle Second(SecondValue);
		return (Left == Right) && (First == FirstCopy) && !(First == Second) && !(Left == First);
	}
}
