/**
 * @version v1
 * @summary Observe FKey identity equality for matching, different, and empty keys.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FKey identity equality for matching, different, and empty keys.
 * @topic Baseline
 */
// default-constructed empty key.
// Expected observations: Matching names compare true. SpaceBar is not Enter.
// Empty is not SpaceBar. Two empty keys compare true.
// Boundary/ownership: Equality compares key identity. Copies are independent
// values.

namespace TS_InputEvents_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FKey Left = n"SpaceBar";
		FKey Right = n"SpaceBar";
		FKey Other = n"Enter";
		FKey Empty;
		FKey OtherEmpty;
		return (Left == Right) && !(Left == Other) && !(Left == Empty) && (Empty == OtherEmpty);
	}
}
/** @end */
