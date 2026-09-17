/**
 * @version v1
 * @summary Observe primitive selectable and lightmap-type mutation on a runner-owned primitive, including repeated writes.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe primitive selectable and lightmap-type mutation on a runner-owned primitive, including repeated writes.
 * @topic Baseline
 */
// void UPrimitiveComponent.SetLightmapType(ELightmapType Type);
// Inputs: Runner-owned UPrimitiveComponent, selectable false then true,
// ELightmapType::Default then ELightmapType::ForceSurface.
// Expected observations: SetbSelectable(false) is visible on GetbSelectable.
// SetbSelectable(true) restores selectable. SetLightmapType leaves the
// component valid with a non-negative bounds radius.
// Boundary/ownership: Selectable is an editor flag. Lightmap type is stored on
// the component; it does not allocate a lightmap. SetupOwner=Runner.

namespace TS_UPrimitiveComponent_MutationAndLifecycle_01
{
	bool Observe_SetbSelectable_Nominal(UPrimitiveComponent Primitive)
	{
		if (Primitive is null)
		{
			throw("TS_UPrimitiveComponent_MutationAndLifecycle_01 setup: required Primitive is null");
		}
		bool bInitial = Primitive.GetbSelectable();
		Primitive.SetbSelectable(false);
		bool bCleared = Primitive.GetbSelectable();
		Primitive.SetbSelectable(false);
		bool bRepeatedFalse = Primitive.GetbSelectable();
		Primitive.SetbSelectable(true);
		bool bSet = Primitive.GetbSelectable();
		Primitive.SetbSelectable(bInitial);
		return !bCleared && !bRepeatedFalse && bSet;
	}

	bool Observe_SetLightmapType_Nominal(UPrimitiveComponent Primitive)
	{
		if (Primitive is null)
		{
			throw("TS_UPrimitiveComponent_MutationAndLifecycle_01 setup: required Primitive is null");
		}
		Primitive.SetLightmapType(ELightmapType::Default);
		Primitive.SetLightmapType(ELightmapType::ForceSurface);
		Primitive.SetLightmapType(ELightmapType::Default);
		return IsValid(Primitive) && Primitive.GetBoundsRadius() >= 0.0;
	}
}
/** @end */
