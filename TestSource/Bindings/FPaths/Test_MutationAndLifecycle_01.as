// Purpose: Observe SetExtension returning a new path and
// RemoveDuplicateSlashes mutating in place, including empty and repeated
// calls.
// AS-facing API: FString FPaths::SetExtension(const FString& InPath,
// const FString& InNewExtension);
// void FPaths::RemoveDuplicateSlashes(FString& InPath);
// Inputs: "Dir/Test.as" with "txt" and empty extension, "A//B///C" with
// duplicate slashes, an already-clean path, and empty InPath.
// Expected observations: SetExtension replaces .as with .txt and does not
// mutate the source. RemoveDuplicateSlashes collapses repeated separators.
// A second collapse leaves the cleaned path unchanged.
// Boundary/ownership: SetExtension returns a new FString. RemoveDuplicateSlashes
// writes InPath in place.

namespace TS_FPaths_MutationAndLifecycle_01
{
	bool Observe_SetExtension_Nominal()
	{
		FString Source = "Dir/Test.as";
		FString Replaced = FPaths::SetExtension(Source, "txt");
		FString EmptyExtension = FPaths::SetExtension(Source, "");
		FString EmptyPath = FPaths::SetExtension("", "txt");
		bool bSourceUnchanged = Source == "Dir/Test.as";
		bool bReplacedTxt = Replaced.Contains("Test") && FPaths::GetExtension(Replaced) == "txt";
		bool bEmptyExtensionHasBase = EmptyExtension.Contains("Test");
		bool bEmptyPathHasTxt = EmptyPath.Contains("txt");
		return bSourceUnchanged && bReplacedTxt && bEmptyExtensionHasBase && bEmptyPathHasTxt;
	}

	bool Observe_RemoveDuplicateSlashes_Nominal()
	{
		FString Path = "A//B///C";
		FString Before = Path;
		FPaths::RemoveDuplicateSlashes(Path);
		bool bCollapsed = Path != Before && Path.Contains("A") && Path.Contains("B") && Path.Contains("C") && !Path.Contains("//");
		FString AfterFirst = Path;
		FPaths::RemoveDuplicateSlashes(Path);
		bool bSecondCallStable = Path == AfterFirst;
		FString Empty;
		FPaths::RemoveDuplicateSlashes(Empty);
		bool bEmptyRemainsEmpty = Empty.IsEmpty();
		FString Clean = "A/B/C";
		FPaths::RemoveDuplicateSlashes(Clean);
		bool bCleanUnchanged = Clean == "A/B/C";
		return bCollapsed && bSecondCallStable && bEmptyRemainsEmpty && bCleanUnchanged;
	}
}
