// Purpose: Observe AVolume.SetBrushColor writing the volume brush color.
// Runner owns the Volume fixture and teardown.
// AS-facing API: void Volume.SetBrushColor(FLinearColor InBrushColor);
// Inputs: Runner-owned AVolume, FLinearColor(1,0,0,1) as red, and
// FLinearColor(0,1,0,1) as a second write.
// Expected observations: SetBrushColor completes on a live volume. The volume
// stays initialized after both writes.
// Boundary/ownership: The bind stores a converted FColor and sets bColored.
// SetupOwner=Runner. CleanupOwner=Runner. Null Volume throws.

namespace TS_AVolume_MutationAndLifecycle_01
{
	bool Observe_SetBrushColor_Nominal(AVolume Volume)
	{
		if (Volume is null)
		{
			throw("TS_AVolume_MutationAndLifecycle_01 setup: required Volume is null");
		}
		FLinearColor Red(1.0, 0.0, 0.0, 1.0);
		Volume.SetBrushColor(Red);
		FLinearColor Green(0.0, 1.0, 0.0, 1.0);
		Volume.SetBrushColor(Green);
		return Volume.IsActorInitialized();
	}
}
