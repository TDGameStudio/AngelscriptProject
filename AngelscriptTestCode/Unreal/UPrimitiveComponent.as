/**
 * @version v1
 * @summary UPrimitiveComponent host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic UPrimitiveComponent
 *
 * setb-selectable
 * set-lightmap-type
 * get-bounding-box-extents
 * get-bounds-origin
 * get-bounds-extent
 * get-bounds-radius
 * getb-selectable
 */
/**
 * @begin setb-selectable
 * @summary Expected
 * @topic Unreal
 */
/**
 * @function ObserveSetbSelectableNominal
 * @summary Expected
 * @covers UPrimitiveComponent.setb-selectable
 * @inputs UPrimitiveComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

 observations: SetbSelectable(false) is visible on GetbSelectable.
// SetbSelectable(true) restores selectable. SetLightmapType leaves the
// component valid with a non-negative bounds radius.
// Boundary/ownership: Selectable is an editor flag. Lightmap type is stored on
// the component; it does not allocate a lightmap. SetupOwner=Runner.
bool ObserveSetbSelectableNominal(UPrimitiveComponent Primitive)
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
/** @end */
/**
 * @begin set-lightmap-type
 * @summary the component; it does not allocate a lightmap.
 * @topic Unreal
 */
/**
 * @function ObserveSetLightmapTypeNominal
 * @summary the component; it does not allocate a lightmap.
 * @covers UPrimitiveComponent.set-lightmap-type
 * @inputs UPrimitiveComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveSetLightmapTypeNominal(UPrimitiveComponent Primitive)
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
/** @end */
/**
 * @begin get-bounding-box-extents
 * @summary Expected.
 * @topic Unreal
 */
/**
 * @function ObserveGetBoundingBoxExtentsNominal
 * @summary Expected.
 * @covers UPrimitiveComponent.get-bounding-box-extents
 * @inputs UPrimitiveComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected. Radius is >= 0. GetbSelectable is false

 after SetbSelectable(false)
// and true after SetbSelectable(true).
// Boundary/ownership: Bounds values are copies. Selectable is an editor flag
// on the component. SetupOwner=Runner.
bool ObserveGetBoundingBoxExtentsNominal(UPrimitiveComponent Primitive)
{
	if (Primitive is null)
	{
		throw("TS_UPrimitiveComponent_Queries_01 setup: required Primitive is null");
	}
	FVector Extents = Primitive.GetBoundingBoxExtents();
	return Extents.X >= 0.0 && Extents.Y >= 0.0 && Extents.Z >= 0.0;
}
/** @end */
/**
 * @begin get-bounds-origin
 * @summary on the component.
 * @topic Unreal
 */
/**
 * @function ObserveGetBoundsOriginNominal
 * @summary on the component.
 * @covers UPrimitiveComponent.get-bounds-origin
 * @inputs UPrimitiveComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected. Radius is >= 0. GetbSelectable is false

bool ObserveGetBoundsOriginNominal(UPrimitiveComponent Primitive, const FVector& Expected)
{
	if (Primitive is null)
	{
		throw("TS_UPrimitiveComponent_Queries_01 setup: required Primitive is null");
	}
	return Primitive.GetBoundsOrigin().Equals(Expected);
}
/** @end */
/**
 * @begin get-bounds-extent
 * @summary on the component.
 * @topic Unreal
 */
/**
 * @function ObserveGetBoundsExtentNominal
 * @summary on the component.
 * @covers UPrimitiveComponent.get-bounds-extent
 * @inputs UPrimitiveComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected. Radius is >= 0. GetbSelectable is false

bool ObserveGetBoundsExtentNominal(UPrimitiveComponent Primitive)
{
	if (Primitive is null)
	{
		throw("TS_UPrimitiveComponent_Queries_01 setup: required Primitive is null");
	}
	FVector Extent = Primitive.GetBoundsExtent();
	return Extent.X >= 0.0 && Extent.Y >= 0.0 && Extent.Z >= 0.0;
}
/** @end */
/**
 * @begin get-bounds-radius
 * @summary on the component.
 * @topic Unreal
 */
/**
 * @function ObserveGetBoundsRadiusNominal
 * @summary on the component.
 * @covers UPrimitiveComponent.get-bounds-radius
 * @inputs UPrimitiveComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected. Radius is >= 0. GetbSelectable is false

bool ObserveGetBoundsRadiusNominal(UPrimitiveComponent Primitive)
{
	if (Primitive is null)
	{
		throw("TS_UPrimitiveComponent_Queries_01 setup: required Primitive is null");
	}
	return Primitive.GetBoundsRadius() >= 0.0;
}
/** @end */
/**
 * @begin getb-selectable
 * @summary on the component.
 * @topic Unreal
 */
/**
 * @function ObserveGetbSelectableNominal
 * @summary on the component.
 * @covers UPrimitiveComponent.getb-selectable
 * @inputs UPrimitiveComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected. Radius is >= 0. GetbSelectable is false

bool ObserveGetbSelectableNominal(UPrimitiveComponent Primitive)
{
	if (Primitive is null)
	{
		throw("TS_UPrimitiveComponent_Queries_01 setup: required Primitive is null");
	}
	bool bInitial = Primitive.GetbSelectable();
	Primitive.SetbSelectable(false);
	bool bCleared = Primitive.GetbSelectable();
	Primitive.SetbSelectable(true);
	bool bSet = Primitive.GetbSelectable();
	Primitive.SetbSelectable(bInitial);
	return !bCleared && bSet;
}
/** @end */
