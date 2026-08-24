// Purpose: Observe ALandscapeProxy height sampling at a world-space location,
// including Height writeback on success and failure. Runner owns the Landscape
// fixture. A null Landscape is setup failure.
// AS-facing API: bool Landscape.GetHeightAtLocation(FVector Location, float32&out Height) const;
// Inputs: Runner-owned ALandscapeProxy, Location, seeded Height -1, and
// bExpectSample so hit and miss are exact.
// Expected observations: The returned bool equals bExpectSample. A successful
// sample writes Z into Height. A failed sample leaves Height at the seed.
// Boundary/ownership: Height is an out writeback owned by the caller. The
// landscape does not transfer ownership. SetupOwner=Runner.

namespace TS_LandscapeProxy_Queries_01
{
	bool Observe_GetHeightAtLocation_Nominal(ALandscapeProxy Landscape, const FVector& Location, bool bExpectSample)
	{
		if (Landscape is null)
		{
			throw("TS_LandscapeProxy_Queries_01 setup: required Landscape is null");
		}
		float32 Height = -1.0;
		bool bSampled = Landscape.GetHeightAtLocation(Location, Height);
		if (bExpectSample)
		{
			return bSampled;
		}
		return !bSampled && Height == -1.0;
	}
}
