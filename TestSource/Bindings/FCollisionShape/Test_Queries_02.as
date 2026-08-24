// Purpose: Observe capsule half-height and the minimum nonzero dimension
// helpers.
// AS-facing API: float32 Shape.GetCapsuleHalfHeight() const;
// float32 FCollisionShape::MinBoxExtent(); float32 FCollisionShape::MinSphereRadius();
// float32 FCollisionShape::MinCapsuleRadius();
// float32 FCollisionShape::MinCapsuleAxisHalfHeight();
// Inputs: Capsule radius 10 half-height 20, default line, and the Min*
// helpers compared with KINDA_SMALL_NUMBER and 0.
// Expected observations: GetCapsuleHalfHeight is 20. Each Min* helper is
// greater than 0 and is KINDA_SMALL_NUMBER when that is the engine value.
// Boundary/ownership: Min* helpers are shared engine constants. They do not
// mutate a shape.

namespace TS_FCollisionShape_Queries_02
{
	bool Observe_GetCapsuleHalfHeight_Nominal()
	{
		FCollisionShape Capsule;
		Capsule.SetCapsule(10.0, 20.0);
		float32 HalfHeight = Capsule.GetCapsuleHalfHeight();
		FCollisionShape Line;
		float32 LineHalfHeight = Line.GetCapsuleHalfHeight();
		return HalfHeight == 20.0 && LineHalfHeight == 0.0;
	}

	bool Observe_MinBoxExtent_Nominal()
	{
		float32 MinExtent = FCollisionShape::MinBoxExtent();
		return MinExtent > 0.0 && MinExtent == KINDA_SMALL_NUMBER;
	}

	bool Observe_MinSphereRadius_Nominal()
	{
		float32 MinRadius = FCollisionShape::MinSphereRadius();
		return MinRadius > 0.0 && MinRadius == KINDA_SMALL_NUMBER;
	}

	bool Observe_MinCapsuleRadius_Nominal()
	{
		float32 MinRadius = FCollisionShape::MinCapsuleRadius();
		return MinRadius > 0.0 && MinRadius == KINDA_SMALL_NUMBER;
	}

	bool Observe_MinCapsuleAxisHalfHeight_Nominal()
	{
		float32 MinAxis = FCollisionShape::MinCapsuleAxisHalfHeight();
		return MinAxis > 0.0 && MinAxis == KINDA_SMALL_NUMBER;
	}
}
