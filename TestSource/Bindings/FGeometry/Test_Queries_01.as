// Purpose: Observe FGeometry local and absolute size queries.
// AS-facing API: FVector2D FGeometry.GetLocalSize() const;
// FVector2D FGeometry.GetAbsoluteSize() const;
// Inputs: A default FGeometry as the empty layout, plus a child created at
// (0,0) with size (10,20) from MakeChild.
// Expected observations: Child local size matches (10,20). Absolute size is
// non-negative. Default geometry sizes are consumed.
// Boundary/ownership: Sizes are in Slate units. Queries do not mutate the
// geometry.

namespace TS_FGeometry_Queries_01
{
	bool Observe_GetLocalSize_Nominal()
	{
		FGeometry Root;
		FGeometry Child = Root.MakeChild(FVector2D(0, 0), FVector2D(10, 20));
		FVector2D Local = Child.GetLocalSize();
		FVector2D RootLocal = Root.GetLocalSize();
		return Local.X == 10.0 && Local.Y == 20.0 && RootLocal.X >= 0.0;
	}

	bool Observe_GetAbsoluteSize_Nominal()
	{
		FGeometry Root;
		FGeometry Child = Root.MakeChild(FVector2D(0, 0), FVector2D(10, 20));
		FVector2D Absolute = Child.GetAbsoluteSize();
		FVector2D RootAbsolute = Root.GetAbsoluteSize();
		return Absolute.X >= 0.0 && Absolute.Y >= 0.0 && RootAbsolute.X >= 0.0;
	}
}
