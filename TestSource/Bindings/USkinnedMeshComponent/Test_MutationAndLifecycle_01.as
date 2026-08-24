// Purpose: Observe USkinnedMeshComponent.UpdateLODStatus refreshing LOD state
// on a runner-owned skinned-mesh component, including a repeated call.
// AS-facing API: void USkinnedMeshComponent.UpdateLODStatus();
// Inputs: Runner-owned USkinnedMeshComponent and two UpdateLODStatus calls.
// Expected observations: UpdateLODStatus leaves the component valid with a
// non-negative bounds radius. A second call is still accepted as a refresh.
// Boundary/ownership: LOD status is stored on the component. SetupOwner=Runner.

namespace TS_USkinnedMeshComponent_MutationAndLifecycle_01
{
	bool Observe_UpdateLODStatus_Nominal(USkinnedMeshComponent Mesh)
	{
		if (Mesh is null)
		{
			throw("TS_USkinnedMeshComponent_MutationAndLifecycle_01 setup: required Mesh is null");
		}
		Mesh.UpdateLODStatus();
		Mesh.UpdateLODStatus();
		return IsValid(Mesh) && Mesh.GetBoundsRadius() >= 0.0;
	}
}
