/**
 * @version v1
 * @summary Observe the process command line text returned by FCommandLine.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe the process command line text returned by FCommandLine.
 * @topic Baseline
 */
// used only as a comparison baseline.
// Expected observations: Get returns a copied command-line string. Two reads
// match. Mutating the first copy does not change a later Get.
// Boundary/ownership: Get returns a new FString and does not alias native
// command-line storage.

namespace TS_FCommandLine_Queries_01
{
	bool Observe_Get_Nominal()
	{
		FString First = FCommandLine::Get();
		FString Second = FCommandLine::Get();
		int FirstLen = First.Len();
		First += "_mutated";
		FString Third = FCommandLine::Get();
		return Second == Third && First.Len() > FirstLen;
	}
}
/** @end */
