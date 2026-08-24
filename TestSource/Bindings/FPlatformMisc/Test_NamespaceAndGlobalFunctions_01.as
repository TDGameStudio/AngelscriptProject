// Purpose: Observe both FPlatformMisc::RequestExit overloads returning after
// a graceful shutdown request. This file is not default-executable.
// AS-facing API: void FPlatformMisc::RequestExit(bool Force);
// void FPlatformMisc::RequestExit(bool Force, const FString& CallSite);
// Inputs: Runner must pass bAllowHostExit=true. Force false for both
// overloads, empty CallSite, and CallSite
// "TS_FPlatformMisc_NamespaceAndGlobalFunctions_01". Force true is not invoked.
// Expected observations: Both overloads return to the caller. Empty and
// named CallSite are accepted.
// Boundary/ownership: SubprocessOnly. SetupOwner=Runner. CleanupOwner=None.
// Missing allow-flag is setup failure.

namespace TS_FPlatformMisc_NamespaceAndGlobalFunctions_01
{
	bool Observe_RequestExit_Nominal(bool bAllowHostExit)
	{
		if (!bAllowHostExit)
		{
			throw("TS_FPlatformMisc_NamespaceAndGlobalFunctions_01 setup: RequestExit requires SubprocessOnly host");
		}
		FPlatformMisc::RequestExit(false);
		FString EmptyCallSite;
		FPlatformMisc::RequestExit(false, EmptyCallSite);
		FPlatformMisc::RequestExit(false, "TS_FPlatformMisc_NamespaceAndGlobalFunctions_01");
		return true;
	}
}
