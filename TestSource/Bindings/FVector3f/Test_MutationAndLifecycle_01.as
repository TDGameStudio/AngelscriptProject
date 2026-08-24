// Purpose: Observe FVector3f.AddBounded in-place cube clamp, including the
// default radius.
// AS-facing API: void Vector.AddBounded(const FVector3f& V, float32 Radius=MAX_int16) const;
// Inputs: Seeded (0,0,0) plus (100,0,0) with Radius 10, default-radius add of
// (1,0,0).
// Expected observations: Radius 10 clamps X to 10. Default radius keeps 1.
// Boundary/ownership: AddBounded mutates the receiver then clamps to a
// symmetric cube even though the bind table marks the method const.

namespace TS_FVector3f_MutationAndLifecycle_01
{
	bool Observe_AddBounded_Nominal()
	{
		FVector3f Vector;
		Vector.AddBounded(FVector3f(100.0f, 0.0f, 0.0f), 10.0f);
		FVector3f DefaultRadius;
		DefaultRadius.AddBounded(FVector3f(1.0f, 0.0f, 0.0f));
		return Vector.Equals(FVector3f(10.0f, 0.0f, 0.0f)) && DefaultRadius.Equals(FVector3f(1.0f, 0.0f, 0.0f));
	}
}
