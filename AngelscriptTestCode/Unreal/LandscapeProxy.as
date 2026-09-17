/**
 * @version v1
 * @summary LandscapeProxy host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic LandscapeProxy
 *
 * get-height-at-location
 */
/**
 * @begin get-height-at-location
 * @summary landscape does not transfer ownership.
 * @topic Unreal
 */
/**
 * @function ObserveGetHeightAtLocationNominal
 * @summary landscape does not transfer ownership.
 * @covers LandscapeProxy.get-height-at-location
 * @inputs LandscapeProxy values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetHeightAtLocationNominal(ALandscapeProxy Landscape, const FVector& Location, bool bExpectSample)
{
	if (Landscape is null)
	{
		throw("TS_LandscapeProxy_Queries_01 setup: required Landscape is null");
	}
	float32 Height = -1.0;
	bool bSampled = Landscape.GetHeightAtLocation(Location, Height);
	if (bExpectSample)
	{
		return bSampled;
	}
	return !bSampled && Height == -1.0;
}
/** @end */
