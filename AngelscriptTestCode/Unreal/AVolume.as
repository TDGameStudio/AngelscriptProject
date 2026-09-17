/**
 * @version v1
 * @summary AVolume host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic AVolume
 *
 * encompasses-point
 * set-brush-color
 * get-bounds
 */
/**
 * @begin encompasses-point
 * @summary CleanupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveEncompassesPointNominal
 * @summary CleanupOwner=Runner.
 * @covers AVolume.encompasses-point
 * @inputs AVolume values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEncompassesPointNominal(AVolume Volume, const FVector& Point, bool bExpectInside, float32& OutDistance)
{
	if (Volume is null)
	{
		throw("TS_AVolume_Behavior_01 setup: required Volume is null");
	}
	bool bBare = Volume.EncompassesPoint(Point);
	bool bRadius = Volume.EncompassesPoint(Point, 50.0);
	float32 Distance = -1.0;
	bool bWithDistance = Volume.EncompassesPoint(Point, 0.0, Distance);
	OutDistance = Distance;
	if (bExpectInside)
	{
		return bBare && bRadius && bWithDistance;
	}
	return !bBare && !bRadius && !bWithDistance && Distance >= 0.0;
}
/** @end */
/**
 * @begin set-brush-color
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveSetBrushColorNominal
 * @summary SetupOwner=Runner.
 * @covers AVolume.set-brush-color
 * @inputs AVolume values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetBrushColorNominal(AVolume Volume)
{
	if (Volume is null)
	{
		throw("TS_AVolume_MutationAndLifecycle_01 setup: required Volume is null");
	}
	FLinearColor Red(1.0, 0.0, 0.0, 1.0);
	Volume.SetBrushColor(Red);
	FLinearColor Green(0.0, 1.0, 0.0, 1.0);
	Volume.SetBrushColor(Green);
	return Volume.IsActorInitialized();
}
/** @end */
/**
 * @begin get-bounds
 * @summary CleanupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveGetBoundsNominal
 * @summary CleanupOwner=Runner.
 * @covers AVolume.get-bounds
 * @inputs AVolume values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetBoundsNominal(AVolume Volume)
{
	if (Volume is null)
	{
		throw("TS_AVolume_Queries_01 setup: required Volume is null");
	}
	FBoxSphereBounds Bounds = Volume.GetBounds();
	return Bounds.Origin.Equals(Volume.GetActorLocation()) && Bounds.SphereRadius >= 0.0;
}
/** @end */
