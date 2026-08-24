// Purpose: Observe FPlatformMisc::GetEnvironmentVariable for a known key,
// an unset key, and an empty name.
// AS-facing API: FString FPlatformMisc::GetEnvironmentVariable(const FString& VariableName);
// Inputs: "PATH" as the known-positive lookup, "TestSource_MissingEnvironmentVariable"
// as the unset key, and empty VariableName.
// Expected observations: PATH is non-empty on this host. An unset name returns
// empty. Empty VariableName returns empty.
// Boundary/ownership: The helper returns a new FString snapshot of process
// environment state and does not own the variable.

namespace TS_FPlatformMisc_Queries_01
{
	bool Observe_GetEnvironmentVariable_Nominal()
	{
		FString PathEnv = FPlatformMisc::GetEnvironmentVariable("PATH");
		FString Missing = FPlatformMisc::GetEnvironmentVariable("TestSource_MissingEnvironmentVariable");
		FString EmptyName = FPlatformMisc::GetEnvironmentVariable("");
		return PathEnv.Len() > 0 && Missing.IsEmpty() && EmptyName.IsEmpty();
	}
}
