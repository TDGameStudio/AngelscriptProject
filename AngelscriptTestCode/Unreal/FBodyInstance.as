/**
 * @version v1
 * @summary FBodyInstance host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FBodyInstance
 *
 * weld
 * un-weld
 * set-use-ccd
 * get-body-setup
 */
/**
 * @begin weld
 * @summary physics typically report Weld false.
 * @topic Unreal
 */
/**
 * @function ObserveWeldNominal
 * @summary physics typically report Weld false.
 * @covers FBodyInstance.weld
 * @inputs FBodyInstance values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveWeldNominal()
{
	FBodyInstance Body;
	FBodyInstance TheirBody;
	FTransform TheirTM;
	bool bWelded = Body.Weld(TheirBody, TheirTM);
	FTransform Offset(FRotator::ZeroRotator, FVector(10.0, 0.0, 0.0), FVector::OneVector);
	bool bOffsetWelded = Body.Weld(TheirBody, Offset);
	return !bWelded && !bOffsetWelded;
}
/** @end */
/**
 * @begin un-weld
 * @summary physics typically report Weld false.
 * @topic Unreal
 */
/**
 * @function ObserveUnWeldNominal
 * @summary physics typically report Weld false.
 * @covers FBodyInstance.un-weld
 * @inputs FBodyInstance values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveUnWeldNominal()
{
	FBodyInstance Body;
	FBodyInstance TheirBody;
	FTransform TheirTM;
	bool bWelded = Body.Weld(TheirBody, TheirTM);
	Body.UnWeld(TheirBody);
	Body.UnWeld(TheirBody);
	return !bWelded;
}
/** @end */
/**
 * @begin set-use-ccd
 * @summary Expected
 * @topic Unreal
 */
/**
 * @function ObserveSetUseCCDNominal
 * @summary Expected
 * @covers FBodyInstance.set-use-ccd
 * @inputs FBodyInstance values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

 observations: SetUseCCD(true) then SetUseCCD(false) complete on
// a default body that has no live physics handle. GetBodySetup stays null.
// Boundary/ownership: CCD is stored on this body instance. There is no live
// physics world required for the bind call.
bool ObserveSetUseCCDNominal()
{
	FBodyInstance Body;
	UBodySetup Before = Body.GetBodySetup();
	Body.SetUseCCD(true);
	Body.SetUseCCD(false);
	UBodySetup After = Body.GetBodySetup();
	return Before is null && After is null;
}
/** @end */
/**
 * @begin get-body-setup
 * @summary collision geometry asset is attached.
 * @topic Unreal
 */
/**
 * @function ObserveGetBodySetupNominal
 * @summary collision geometry asset is attached.
 * @covers FBodyInstance.get-body-setup
 * @inputs FBodyInstance values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetBodySetupNominal(bool bExpectBoxSetup)
{
	FBodyInstance Body;
	UBodySetup DefaultSetup = Body.GetBodySetup();
	UBoxComponent BoxCdo = TSubclassOf<UBoxComponent>(UBoxComponent::StaticClass()).GetDefaultObject();
	if (BoxCdo is null)
	{
		throw("TS_FBodyInstance_Queries_01 setup: required BoxCdo is null");
	}
	UBodySetup BoxSetup = BoxCdo.BodyInstance.GetBodySetup();
	if (bExpectBoxSetup)
	{
		return DefaultSetup is null && BoxSetup != nullptr;
	}
	return DefaultSetup is null && BoxSetup is null;
}
/** @end */
