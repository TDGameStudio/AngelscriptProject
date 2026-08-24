// Purpose: Observe FVector.AddBounded in-place cube clamp and FString.Append
// of a vector, including repeated append and Empty restoration.
// AS-facing API: void FVector.AddBounded(const FVector& V, float64 Radius = MAX_int16);
// Text.Append(Vector);
// Inputs: Seeded (0,0,0) plus (100,0,0) with Radius 10, default-radius add of
// (1,0,0), text "v:", vector (1,2,3), repeated append, Empty cleanup.
// Expected observations: Radius 10 clamps X to 10. Default radius keeps 1.
// First append grows length, second grows further, Empty restores 0. Vector
// is unchanged by Append.
// Boundary/ownership: AddBounded mutates the receiver then clamps to a
// symmetric cube. Append copies formatted text.

namespace TS_FVector_MutationAndLifecycle_01
{
	bool Observe_AddBounded_Nominal()
	{
		FVector Vector;
		Vector.AddBounded(FVector(100, 0, 0), 10.0);
		FVector DefaultRadius;
		DefaultRadius.AddBounded(FVector(1, 0, 0));
		return Vector.Equals(FVector(10, 0, 0)) && DefaultRadius.Equals(FVector(1, 0, 0));
	}

	bool Observe_Append_Nominal()
	{
		FString Text = "v:";
		FVector Vector(1, 2, 3);
		int Before = Text.Len();
		Text.Append(Vector);
		int AfterFirst = Text.Len();
		Text.Append(Vector);
		int AfterSecond = Text.Len();
		Text.Empty();
		return AfterFirst > Before && AfterSecond > AfterFirst && Text.IsEmpty() && Vector.X == 1.0;
	}
}
