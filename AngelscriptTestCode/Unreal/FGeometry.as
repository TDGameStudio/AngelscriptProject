/**
 * @version v1
 * @summary FGeometry host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FGeometry
 *
 * absolute-to-local
 * local-to-absolute
 * make-child
 * get-local-size
 * get-absolute-size
 */
/**
 * @begin absolute-to-local
 * @summary mutate the parent.
 * @topic Unreal
 */
/**
 * @function ObserveAbsoluteToLocalNominal
 * @summary mutate the parent.
 * @covers FGeometry.absolute-to-local
 * @inputs FGeometry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAbsoluteToLocalNominal()
{
	FGeometry Root;
	FVector2D Absolute = Root.LocalToAbsolute(FVector2D(0, 0));
	FVector2D Local = Root.AbsoluteToLocal(Absolute);
	return Local.X == 0.0 && Local.Y == 0.0;
}
/** @end */
/**
 * @begin local-to-absolute
 * @summary mutate the parent.
 * @topic Unreal
 */
/**
 * @function ObserveLocalToAbsoluteNominal
 * @summary mutate the parent.
 * @covers FGeometry.local-to-absolute
 * @inputs FGeometry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLocalToAbsoluteNominal()
{
	FGeometry Root;
	FVector2D AbsoluteOrigin = Root.LocalToAbsolute(FVector2D(0, 0));
	FVector2D AbsoluteOffset = Root.LocalToAbsolute(FVector2D(10, 20));
	return AbsoluteOffset.X == AbsoluteOrigin.X + 10.0 && AbsoluteOffset.Y == AbsoluteOrigin.Y + 20.0;
}
/** @end */
/**
 * @begin make-child
 * @summary mutate the parent.
 * @topic Unreal
 */
/**
 * @function ObserveMakeChildNominal
 * @summary mutate the parent.
 * @covers FGeometry.make-child
 * @inputs FGeometry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMakeChildNominal()
{
	FGeometry Root;
	FGeometry Child = Root.MakeChild(FVector2D(0, 0), FVector2D(10, 20));
	FVector2D Size = Child.GetLocalSize();
	FGeometry EmptyChild = Root.MakeChild(FVector2D(0, 0), FVector2D::ZeroVector);
	return Size.X == 10.0 && Size.Y == 20.0 && EmptyChild.GetLocalSize().X == 0.0;
}
/** @end */
/**
 * @begin get-local-size
 * @summary (0,0)
 * @topic Unreal
 */
/**
 * @function ObserveGetLocalSizeNominal
 * @summary (0,0)
 * @covers FGeometry.get-local-size
 * @inputs FGeometry values exercised by this observe
 * @return true when the observe comparison holds
 */
// (0,0)

 with size (10,20) from MakeChild.
// Expected observations: Child local size matches (10,20). Absolute size is
// non-negative. Default geometry sizes are consumed.
// Boundary/ownership: Sizes are in Slate units. Queries do not mutate the
// geometry.
bool ObserveGetLocalSizeNominal()
{
	FGeometry Root;
	FGeometry Child = Root.MakeChild(FVector2D(0, 0), FVector2D(10, 20));
	FVector2D Local = Child.GetLocalSize();
	FVector2D RootLocal = Root.GetLocalSize();
	return Local.X == 10.0 && Local.Y == 20.0 && RootLocal.X >= 0.0;
}
/** @end */
/**
 * @begin get-absolute-size
 * @summary geometry.
 * @topic Unreal
 */
/**
 * @function ObserveGetAbsoluteSizeNominal
 * @summary geometry.
 * @covers FGeometry.get-absolute-size
 * @inputs FGeometry values exercised by this observe
 * @return true when the observe comparison holds
 */
// (0,0)

bool ObserveGetAbsoluteSizeNominal()
{
	FGeometry Root;
	FGeometry Child = Root.MakeChild(FVector2D(0, 0), FVector2D(10, 20));
	FVector2D Absolute = Child.GetAbsoluteSize();
	FVector2D RootAbsolute = Root.GetAbsoluteSize();
	return Absolute.X >= 0.0 && Absolute.Y >= 0.0 && RootAbsolute.X >= 0.0;
}
/** @end */
