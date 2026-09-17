/**
 * @version v1
 * @summary Observe operating-system user name and platform bundle identifier.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe operating-system user name and platform bundle identifier.
 * @topic Baseline
 */
// FString Id = FPlatformProcess::GameBundleId();
// Inputs: The current process identity. Empty/default is an empty FString
// comparison baseline.
// Expected observations: UserName is non-empty on this host. GameBundleId is
// stable across two calls and may be empty on platforms without a bundle id.
// Boundary/ownership: Both helpers return new FString snapshots and do not
// own OS identity.

namespace TS_FPlatformProcess_NamespaceAndGlobalFunctions_02
{
	bool Observe_UserName_Nominal()
	{
		FString Empty;
		FString Name = FPlatformProcess::UserName();
		return Name.Len() > 0 && Empty.IsEmpty();
	}

	bool Observe_GameBundleId_Nominal()
	{
		FString Empty;
		FString Id = FPlatformProcess::GameBundleId();
		FString Again = FPlatformProcess::GameBundleId();
		return Id == Again && Empty.IsEmpty();
	}
}
/** @end */
