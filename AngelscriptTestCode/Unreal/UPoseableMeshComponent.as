/**
 * @version v1
 * @summary UPoseableMeshComponent host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic UPoseableMeshComponent
 *
 * allocate-transform-data
 * refresh-bone-transforms
 */
/**
 * @begin allocate-transform-data
 * @summary rebuilds component-space bones from that storage.
 * @topic Unreal
 */
/**
 * @function ObserveAllocateTransformDataNominal
 * @summary rebuilds component-space bones from that storage.
 * @covers UPoseableMeshComponent.allocate-transform-data
 * @inputs UPoseableMeshComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAllocateTransformDataNominal(UPoseableMeshComponent Component)
{
	if (Component is null)
	{
		throw("TS_UPoseableMeshComponent_Behavior_01 setup: required Component is null");
	}
	Component.AllocateTransformData();
	Component.AllocateTransformData();
	return IsValid(Component) && Component.GetBoundsRadius() >= 0.0;
}
/** @end */
/**
 * @begin refresh-bone-transforms
 * @summary rebuilds component-space bones from that storage.
 * @topic Unreal
 */
/**
 * @function ObserveRefreshBoneTransformsNominal
 * @summary rebuilds component-space bones from that storage.
 * @covers UPoseableMeshComponent.refresh-bone-transforms
 * @inputs UPoseableMeshComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRefreshBoneTransformsNominal(UPoseableMeshComponent Component)
{
	if (Component is null)
	{
		throw("TS_UPoseableMeshComponent_Behavior_01 setup: required Component is null");
	}
	Component.AllocateTransformData();
	Component.RefreshBoneTransforms();
	Component.RefreshBoneTransforms();
	return IsValid(Component) && Component.GetBoundsRadius() >= 0.0;
}
/** @end */
