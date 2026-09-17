/**
 * @version v1
 * @summary Observe FSphere equality, inside tests, and volume.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FSphere equality, inside tests, and volume.
 * @topic Baseline
 */
// exterior (5,0,0), zero sphere, default-omitted KINDA_SMALL_NUMBER.
// Expected observations: Matching copies Equals true. Radius 2 is inside
// radius 3; the reverse is false. Interior point is inside; exterior is not.
// Radius 1 volume is between 4 and 5. Zero volume is 0.
// Boundary/ownership: Queries do not mutate the sphere. Radius is Sphere.W.

namespace TS_FSphere_Queries_01
{
	bool Observe_Equals_Nominal()
	{
		FSphere Left(FVector::ZeroVector, 2.0);
		FSphere Right(FVector::ZeroVector, 2.0);
		FSphere Different(FVector::ZeroVector, 3.0);
		return Left.Equals(Right) && Left.Equals(Right, KINDA_SMALL_NUMBER) && !Left.Equals(Different);
	}

	bool Observe_IsInside_Nominal()
	{
		FSphere Inner(FVector::ZeroVector, 2.0);
		FSphere Outer(FVector::ZeroVector, 3.0);
		return Inner.IsInside(Outer) && !Outer.IsInside(Inner) && Inner.IsInside(Outer, KINDA_SMALL_NUMBER) && Inner.IsInside(FVector(1.0, 0.0, 0.0)) && !Inner.IsInside(FVector(5.0, 0.0, 0.0)) && Inner.IsInside(FVector::ZeroVector, KINDA_SMALL_NUMBER);
	}

	bool Observe_GetVolume_Nominal()
	{
		FSphere Unit(FVector::ZeroVector, 1.0);
		FSphere Zero;
		float32 UnitVolume = Unit.GetVolume();
		float32 ZeroVolume = Zero.GetVolume();
		return UnitVolume > 4.0 && UnitVolume < 5.0 && ZeroVolume == 0.0;
	}
}
/** @end */
