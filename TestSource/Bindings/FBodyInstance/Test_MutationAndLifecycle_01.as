// Purpose: Observe FBodyInstance.SetUseCCD enabling and disabling CCD.
// The bool return is the runner-readable oracle.
// AS-facing API: void FBodyInstance.SetUseCCD(bool bInUseCCD);
// Inputs: Default FBodyInstance, bInUseCCD true then false.
// Expected observations: SetUseCCD(true) then SetUseCCD(false) complete on
// a default body that has no live physics handle. GetBodySetup stays null.
// Boundary/ownership: CCD is stored on this body instance. There is no live
// physics world required for the bind call.

namespace TS_FBodyInstance_MutationAndLifecycle_01
{
	bool Observe_SetUseCCD_Nominal()
	{
		FBodyInstance Body;
		UBodySetup Before = Body.GetBodySetup();
		Body.SetUseCCD(true);
		Body.SetUseCCD(false);
		UBodySetup After = Body.GetBodySetup();
		return Before is null && After is null;
	}
}
