/**
 * @version v1
 * @summary Observe FGuid.IsValid and GetTypeHash for zero and nonzero values.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FGuid.IsValid and GetTypeHash for zero and nonzero values.
 * @topic Baseline
 */
// and two identical nonzero GUIDs as hash keys.
// Expected observations: Nonzero IsValid is true; zero IsValid is false.
// Identical GUIDs share a hash. Invalidate is not used here.
// Boundary/ownership: IsValid reports whether any word is nonzero. Hashing
// does not mutate the GUID.

namespace TS_FGuid_Queries_01
{
	bool Observe_IsValid_Nominal()
	{
		FGuid Valid(1, 2, 3, 4);
		FGuid Invalid(0, 0, 0, 0);
		return Valid.IsValid() && !Invalid.IsValid();
	}

	bool Observe_GetTypeHash_Nominal()
	{
		FGuid Left(1, 2, 3, 4);
		FGuid Right(1, 2, 3, 4);
		FGuid Other(5, 6, 7, 8);
		uint32 LeftHash = Left.GetTypeHash();
		uint32 RightHash = Right.GetTypeHash();
		return LeftHash == RightHash && !(Other == Left) && Other.IsValid();
	}
}
/** @end */
