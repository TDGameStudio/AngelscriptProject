// Purpose: Observe AVolume.GetBounds on a runner-owned volume.
// AS-facing API: FBoxSphereBounds Volume.GetBounds() const;
// Inputs: Runner-owned AVolume.
// Expected observations: GetBounds origin matches the volume actor location
// and SphereRadius is non-negative.
// Boundary/ownership: Bounds are returned by value. SetupOwner=Runner.
// CleanupOwner=Runner. Null Volume throws.

namespace TS_AVolume_Queries_01
{
	bool Observe_GetBounds_Nominal(AVolume Volume)
	{
		if (Volume is null)
		{
			throw("TS_AVolume_Queries_01 setup: required Volume is null");
		}
		FBoxSphereBounds Bounds = Volume.GetBounds();
		return Bounds.Origin.Equals(Volume.GetActorLocation()) && Bounds.SphereRadius >= 0.0;
	}
}
