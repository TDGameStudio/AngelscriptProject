// Purpose: Observe SetSkeletalMeshAsset assigning and clearing the skeletal
// mesh, including a repeated write.
// Runner owns the mesh component and asset fixtures.
// AS-facing API: void USkeletalMeshComponent.SetSkeletalMeshAsset(USkeletalMesh NewMesh);
// Inputs: Runner-owned USkeletalMeshComponent, runner-owned USkeletalMesh,
// repeated assignment, and nullptr clear.
// Expected observations: SetSkeletalMeshAsset is visible on GetSkeletalMeshAsset.
// Repeating the same asset keeps that identity. nullptr clears the assigned mesh.
// Boundary/ownership: The component does not take unique ownership of the asset
// object. SetupOwner=Runner.

namespace TS_USkeletalMeshComponent_MutationAndLifecycle_01
{
	bool Observe_SetSkeletalMeshAsset_Nominal(USkeletalMeshComponent Mesh, USkeletalMesh Asset)
	{
		if (Mesh is null)
		{
			throw("TS_USkeletalMeshComponent_MutationAndLifecycle_01 setup: required Mesh is null");
		}
		if (Asset is null)
		{
			throw("TS_USkeletalMeshComponent_MutationAndLifecycle_01 setup: required Asset is null");
		}
		USkeletalMesh Original = Mesh.GetSkeletalMeshAsset();
		Mesh.SetSkeletalMeshAsset(Asset);
		USkeletalMesh First = Mesh.GetSkeletalMeshAsset();
		Mesh.SetSkeletalMeshAsset(Asset);
		USkeletalMesh Repeated = Mesh.GetSkeletalMeshAsset();
		Mesh.SetSkeletalMeshAsset(nullptr);
		USkeletalMesh Cleared = Mesh.GetSkeletalMeshAsset();
		Mesh.SetSkeletalMeshAsset(Original);
		return First == Asset && Repeated == Asset && Cleared is null;
	}
}
