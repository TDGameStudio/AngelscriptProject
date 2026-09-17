/**
 * @version v1
 * @summary Observe poseable-mesh transform storage allocation and component- space bone rebuild.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe poseable-mesh transform storage allocation and component- space bone rebuild.
 * @topic Baseline
 */
// Runner owns the Component fixture.
// AS-facing API: void UPoseableMeshComponent.AllocateTransformData();
// void UPoseableMeshComponent.RefreshBoneTransforms();
// Inputs: Runner-owned UPoseableMeshComponent, AllocateTransformData then
// RefreshBoneTransforms, and a repeated allocate/refresh pair.
// Expected observations: After allocate/refresh the component remains valid
// and bounds radius is >= 0.
// Boundary/ownership: Transform storage is owned by the component. Refresh
// rebuilds component-space bones from that storage. SetupOwner=Runner.

namespace TS_UPoseableMeshComponent_Behavior_01
{
	bool Observe_AllocateTransformData_Nominal(UPoseableMeshComponent Component)
	{
		if (Component is null)
		{
			throw("TS_UPoseableMeshComponent_Behavior_01 setup: required Component is null");
		}
		Component.AllocateTransformData();
		Component.AllocateTransformData();
		return IsValid(Component) && Component.GetBoundsRadius() >= 0.0;
	}

	bool Observe_RefreshBoneTransforms_Nominal(UPoseableMeshComponent Component)
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
}
/** @end */
