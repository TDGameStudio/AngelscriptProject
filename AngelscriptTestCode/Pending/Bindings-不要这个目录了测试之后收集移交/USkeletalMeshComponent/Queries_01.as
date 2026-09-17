/**
 * @version v1
 * @summary Observe linked anim-instance aliasing and skeletal-mesh asset identity on a runner-owned skeletal-mesh component.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe linked anim-instance aliasing and skeletal-mesh asset identity on a runner-owned skeletal-mesh component.
 * @topic Baseline
 */
// USkeletalMesh USkeletalMeshComponent.GetSkeletalMeshAsset() const;
// Inputs: Runner-owned USkeletalMeshComponent, runner-owned USkeletalMesh
// asset, and a follow-up Num() read on the returned array reference.
// Expected observations: GetLinkedAnimInstances returns a reference whose Num
// is stable across two reads. After SetSkeletalMeshAsset the getter returns
// that identity; nullptr clears it.
// Boundary/ownership: The linked-instance array aliases component storage.
// GetSkeletalMeshAsset does not transfer mesh ownership. SetupOwner=Runner.

namespace TS_USkeletalMeshComponent_Queries_01
{
	bool Observe_GetLinkedAnimInstances_Nominal(USkeletalMeshComponent Mesh)
	{
		if (Mesh is null)
		{
			throw("TS_USkeletalMeshComponent_Queries_01 setup: required Mesh is null");
		}
		const TArray<UAnimInstance>& Linked = Mesh.GetLinkedAnimInstances();
		int32 FirstNum = Linked.Num();
		const TArray<UAnimInstance>& Alias = Mesh.GetLinkedAnimInstances();
		int32 SecondNum = Alias.Num();
		return FirstNum == SecondNum;
	}

	bool Observe_GetSkeletalMeshAsset_Nominal(USkeletalMeshComponent Mesh, USkeletalMesh Asset)
	{
		if (Mesh is null)
		{
			throw("TS_USkeletalMeshComponent_Queries_01 setup: required Mesh is null");
		}
		if (Asset is null)
		{
			throw("TS_USkeletalMeshComponent_Queries_01 setup: required Asset is null");
		}
		USkeletalMesh Original = Mesh.GetSkeletalMeshAsset();
		Mesh.SetSkeletalMeshAsset(Asset);
		USkeletalMesh Stored = Mesh.GetSkeletalMeshAsset();
		Mesh.SetSkeletalMeshAsset(nullptr);
		USkeletalMesh Cleared = Mesh.GetSkeletalMeshAsset();
		Mesh.SetSkeletalMeshAsset(Original);
		return Stored == Asset && Cleared is null;
	}
}
/** @end */
