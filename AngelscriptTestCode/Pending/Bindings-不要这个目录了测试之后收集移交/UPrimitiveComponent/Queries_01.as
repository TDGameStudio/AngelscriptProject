/**
 * @version v1
 * @summary Observe primitive bounds queries and the editor-selectable flag on a runner-owned primitive.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe primitive bounds queries and the editor-selectable flag on a runner-owned primitive.
 * @topic Baseline
 */
// FVector UPrimitiveComponent.GetBoundsOrigin() const;
// FVector UPrimitiveComponent.GetBoundsExtent() const;
// float64 UPrimitiveComponent.GetBoundsRadius() const;
// bool UPrimitiveComponent.GetbSelectable() const;
// Inputs: Runner-owned UPrimitiveComponent, expected origin, and selectable
// true/false after mutation with restore of the initial flag.
// Expected observations: Extents and extent axes are >= 0. Origin equals
// Expected. Radius is >= 0. GetbSelectable is false after SetbSelectable(false)
// and true after SetbSelectable(true).
// Boundary/ownership: Bounds values are copies. Selectable is an editor flag
// on the component. SetupOwner=Runner.

namespace TS_UPrimitiveComponent_Queries_01
{
	bool Observe_GetBoundingBoxExtents_Nominal(UPrimitiveComponent Primitive)
	{
		if (Primitive is null)
		{
			throw("TS_UPrimitiveComponent_Queries_01 setup: required Primitive is null");
		}
		FVector Extents = Primitive.GetBoundingBoxExtents();
		return Extents.X >= 0.0 && Extents.Y >= 0.0 && Extents.Z >= 0.0;
	}

	bool Observe_GetBoundsOrigin_Nominal(UPrimitiveComponent Primitive, const FVector& Expected)
	{
		if (Primitive is null)
		{
			throw("TS_UPrimitiveComponent_Queries_01 setup: required Primitive is null");
		}
		return Primitive.GetBoundsOrigin().Equals(Expected);
	}

	bool Observe_GetBoundsExtent_Nominal(UPrimitiveComponent Primitive)
	{
		if (Primitive is null)
		{
			throw("TS_UPrimitiveComponent_Queries_01 setup: required Primitive is null");
		}
		FVector Extent = Primitive.GetBoundsExtent();
		return Extent.X >= 0.0 && Extent.Y >= 0.0 && Extent.Z >= 0.0;
	}

	bool Observe_GetBoundsRadius_Nominal(UPrimitiveComponent Primitive)
	{
		if (Primitive is null)
		{
			throw("TS_UPrimitiveComponent_Queries_01 setup: required Primitive is null");
		}
		return Primitive.GetBoundsRadius() >= 0.0;
	}

	bool Observe_GetbSelectable_Nominal(UPrimitiveComponent Primitive)
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
}
/** @end */
