/**
 * @version v1
 * @summary Observe FName identity equality and name-vs-string equality.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FName identity equality and name-vs-string equality.
 * @topic Baseline
 */
// "Alpha" versus "Beta".
// Expected observations: Identical interned names compare true. Alpha vs
// NAME_None is false. Name == "Alpha" is true; Name == "Beta" is false.
// Boundary/ownership: Name-name equality uses FName identity. Name-string
// equality compares text and does not intern a temporary as a side effect
// that the test relies on.

namespace TS_FName_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FName Left = n"Alpha";
		FName Right = n"Alpha";
		FName Other = n"Beta";
		bool bSame = Left == Right;
		bool bDifferent = Left == Other;
		bool bVsNone = Left == NAME_None;
		bool bNameEqualsString = Left == "Alpha";
		bool bNameNotEqualsOtherString = Left == "Beta";
		return bSame && !bDifferent && !bVsNone && bNameEqualsString && !bNameNotEqualsOtherString;
	}
}
/** @end */
