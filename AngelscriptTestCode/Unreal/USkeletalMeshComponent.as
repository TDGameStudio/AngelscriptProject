/**
 * @version v1
 * @summary USkeletalMeshComponent host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic USkeletalMeshComponent
 *
 * set-skeletal-mesh-asset
 * get-linked-anim-instances
 * get-skeletal-mesh-asset
 */
/**
 * @begin set-skeletal-mesh-asset
 * @summary object.
 * @topic Unreal
 */
/**
 * @function ObserveSetSkeletalMeshAssetNominal
 * @summary object.
 * @covers USkeletalMeshComponent.set-skeletal-mesh-asset
 * @inputs USkeletalMeshComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetSkeletalMeshAssetNominal(USkeletalMeshComponent Mesh, USkeletalMesh Asset)
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
/** @end */
/**
 * @begin get-linked-anim-instances
 * @summary asset, and a follow-
 * @topic Unreal
 */
/**
 * @function ObserveGetLinkedAnimInstancesNominal
 * @summary asset, and a follow-
 * @covers USkeletalMeshComponent.get-linked-anim-instances
 * @inputs USkeletalMeshComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
// asset, and a follow-

up Num() read on the returned array reference.
// Expected observations: GetLinkedAnimInstances returns a reference whose Num
// is stable across two reads. After SetSkeletalMeshAsset the getter returns
// that identity; nullptr clears it.
// Boundary/ownership: The linked-instance array aliases component storage.
// GetSkeletalMeshAsset does not transfer mesh ownership. SetupOwner=Runner.
bool ObserveGetLinkedAnimInstancesNominal(USkeletalMeshComponent Mesh)
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
/** @end */
/**
 * @begin get-skeletal-mesh-asset
 * @summary GetSkeletalMeshAsset does not transfer mesh ownership.
 * @topic Unreal
 */
/**
 * @function ObserveGetSkeletalMeshAssetNominal
 * @summary GetSkeletalMeshAsset does not transfer mesh ownership.
 * @covers USkeletalMeshComponent.get-skeletal-mesh-asset
 * @inputs USkeletalMeshComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
// asset, and a follow-

bool ObserveGetSkeletalMeshAssetNominal(USkeletalMeshComponent Mesh, USkeletalMesh Asset)
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
/** @end */
