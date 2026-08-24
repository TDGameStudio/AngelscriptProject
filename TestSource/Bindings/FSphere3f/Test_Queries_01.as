// Purpose: Observe FSphere3f equality, sphere-in-sphere containment, and
// volume.
// AS-facing API: Equals; IsInside(other sphere); GetVolume.
// Inputs: Origin radius 2, matching copy, radius 3, zero sphere, and
// KINDA_SMALL_NUMBER.
// Expected observations: Matching copies Equals true. Radius 2 is inside
// radius 3; the reverse is false. Radius 1 volume is between 4 and 5. Zero
// volume is 0.
// Boundary/ownership: Queries do not mutate the sphere. Radius is Sphere.W.
// Point-in-sphere IsInside is not published on FSphere3f.

namespace TS_FSphere3f_Queries_01
{
	bool Observe_Equals_Nominal()
	{
		FSphere3f Left(FVector3f::ZeroVector, 2.0);
		FSphere3f Right(FVector3f::ZeroVector, 2.0);
		FSphere3f Different(FVector3f::ZeroVector, 3.0);
		return Left.Equals(Right) && Left.Equals(Right, KINDA_SMALL_NUMBER) && !Left.Equals(Different);
	}

	bool Observe_IsInside_Nominal()
	{
		FSphere3f Inner(FVector3f::ZeroVector, 2.0);
		FSphere3f Outer(FVector3f::ZeroVector, 3.0);
		return Inner.IsInside(Outer) && !Outer.IsInside(Inner) && Inner.IsInside(Outer, KINDA_SMALL_NUMBER);
	}

	bool Observe_GetVolume_Nominal()
	{
		FSphere3f Unit(FVector3f::ZeroVector, 1.0);
		FSphere3f Zero;
		float32 UnitVolume = Unit.GetVolume();
		float32 ZeroVolume = Zero.GetVolume();
		return UnitVolume > 4.0 && UnitVolume < 5.0 && ZeroVolume == 0.0;
	}
}
