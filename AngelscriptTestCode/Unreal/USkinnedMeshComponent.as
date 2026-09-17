/**
 * @version v1
 * @summary USkinnedMeshComponent host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic USkinnedMeshComponent
 *
 * invalidate-cached-bounds
 * update-lod-status
 */
/**
 * @begin invalidate-cached-bounds
 * @summary on a null handle is the expected-failure path.
 * @topic Unreal
 */
/**
 * @function ObserveInvalidateCachedBoundsNominal
 * @summary on a null handle is the expected-failure path.
 * @covers USkinnedMeshComponent.invalidate-cached-bounds
 * @inputs USkinnedMeshComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveInvalidateCachedBoundsNominal(USkinnedMeshComponent Mesh)
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
/** @end */
/**
 * @begin update-lod-status
 * @summary Boundary/ownership: LOD status is stored on the component.
 * @topic Unreal
 */
/**
 * @function ObserveUpdateLODStatusNominal
 * @summary Boundary/ownership: LOD status is stored on the component.
 * @covers USkinnedMeshComponent.update-lod-status
 * @inputs USkinnedMeshComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveUpdateLODStatusNominal(USkinnedMeshComponent Mesh)
{
	if (Mesh is null)
	{
		throw("TS_USkinnedMeshComponent_MutationAndLifecycle_01 setup: required Mesh is null");
	}
	Mesh.UpdateLODStatus();
	Mesh.UpdateLODStatus();
	return IsValid(Mesh) && Mesh.GetBoundsRadius() >= 0.0;
}
/** @end */
