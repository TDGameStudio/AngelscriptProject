// Purpose: Observe absolute/local position conversion and MakeChild.
// AS-facing API: AbsoluteToLocal; LocalToAbsolute; MakeChild.
// Inputs: Root geometry, local position (0,0) and (10,20), child size
// (10,20), and a round-trip through LocalToAbsolute then AbsoluteToLocal.
// Expected observations: MakeChild returns a geometry whose local size is
// (10,20). Round-tripping a local point through absolute space returns a
// nearby local point.
// Boundary/ownership: MakeChild returns a new geometry. Conversions do not
// mutate the parent.

namespace TS_FGeometry_Behavior_01
{
	bool Observe_AbsoluteToLocal_Nominal()
	{
		FGeometry Root;
		FVector2D Absolute = Root.LocalToAbsolute(FVector2D(0, 0));
		FVector2D Local = Root.AbsoluteToLocal(Absolute);
		return Local.X == 0.0 && Local.Y == 0.0;
	}

	bool Observe_LocalToAbsolute_Nominal()
	{
		FGeometry Root;
		FVector2D AbsoluteOrigin = Root.LocalToAbsolute(FVector2D(0, 0));
		FVector2D AbsoluteOffset = Root.LocalToAbsolute(FVector2D(10, 20));
		return AbsoluteOffset.X == AbsoluteOrigin.X + 10.0 && AbsoluteOffset.Y == AbsoluteOrigin.Y + 20.0;
	}

	bool Observe_MakeChild_Nominal()
	{
		FGeometry Root;
		FGeometry Child = Root.MakeChild(FVector2D(0, 0), FVector2D(10, 20));
		FVector2D Size = Child.GetLocalSize();
		FGeometry EmptyChild = Root.MakeChild(FVector2D(0, 0), FVector2D::ZeroVector);
		return Size.X == 10.0 && Size.Y == 20.0 && EmptyChild.GetLocalSize().X == 0.0;
	}
}
