// Purpose: Observe FVector3f.IsUnit for unit, scaled, and zero receivers.
// AS-facing API: bool Vector.IsUnit(float32 LengthSquaredTolerance = __KINDA_SMALL_NUMBER_flt) const;
// Inputs: Unit X, (2,0,0), zero, omitted default, explicit wide tolerance.
// Expected observations: Unit X is a unit vector. (2,0,0) is not. Zero is
// not. Wide tolerance still reports the true unit vector as unit.
// Boundary/ownership: Query does not mutate. Default tolerance is
// __KINDA_SMALL_NUMBER_flt.

namespace TS_FVector3f_Queries_03
{
	bool Observe_IsUnit_Nominal()
	{
		bool bUnit = FVector3f(1.0f, 0.0f, 0.0f).IsUnit();
		bool bScaled = FVector3f(2.0f, 0.0f, 0.0f).IsUnit();
		bool bZero = FVector3f(0.0f, 0.0f, 0.0f).IsUnit();
		bool bWide = FVector3f(1.0f, 0.0f, 0.0f).IsUnit(1.0f);
		return bUnit && !bScaled && !bZero && bWide;
	}
}
