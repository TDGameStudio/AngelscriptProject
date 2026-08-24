// Purpose: Observe InvalidateCachedBounds forcing bounds recalculation, plus
// a null-receiver diagnostic.
// Runner owns the Mesh fixture.
// AS-facing API: void USkinnedMeshComponent.InvalidateCachedBounds();
// Inputs: Runner-owned USkinnedMeshComponent, a repeated invalidate, and a
// null component handle as the diagnostic path.
// Expected observations: After invalidate, GetBoundsExtent axes are >= 0 and
// a second invalidate keeps the same non-negative extent.
// Boundary/ownership: Cached bounds belong to the component. Calling the method
// on a null handle is the expected-failure path. SetupOwner=Runner.

namespace TS_USkinnedMeshComponent_Behavior_01
{
	bool Observe_InvalidateCachedBounds_Nominal(USkinnedMeshComponent Mesh)
	{
		if (Mesh is null)
		{
			throw("TS_USkinnedMeshComponent_Behavior_01 setup: required Mesh is null");
		}
		Mesh.InvalidateCachedBounds();
		FVector ExtentAfter = Mesh.GetBoundsExtent();
		Mesh.InvalidateCachedBounds();
		FVector ExtentRepeated = Mesh.GetBoundsExtent();
		return ExtentAfter.X >= 0.0 && ExtentAfter.Y >= 0.0 && ExtentAfter.Z >= 0.0 && ExtentRepeated.Equals(ExtentAfter);
	}

	void ExerciseExpectedFailure()
	{
		USkinnedMeshComponent NullComponent;
		NullComponent.InvalidateCachedBounds();
	}
}
