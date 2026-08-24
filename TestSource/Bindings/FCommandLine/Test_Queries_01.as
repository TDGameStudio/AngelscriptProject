// Purpose: Observe the process command line text returned by FCommandLine.
// AS-facing API: FString FCommandLine::Get();
// Inputs: The current process command line. Empty/default is an empty FString
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
