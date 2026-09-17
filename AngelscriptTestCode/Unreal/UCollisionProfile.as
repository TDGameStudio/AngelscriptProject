/**
 * @version v1
 * @summary UCollisionProfile host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic UCollisionProfile
 *
 * convert-to-collision-channel
 * convert-to-object-type
 * convert-to-trace-type
 */
/**
 * @begin convert-to-collision-channel
 * @summary Expected
 * @topic Unreal
 */
/**
 * @function ObserveConvertToCollisionChannelNominal
 * @summary Expected
 * @covers UCollisionProfile.convert-to-collision-channel
 * @inputs UCollisionProfile values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

 observations: ConvertToObjectType(WorldStatic) round-trips through
// ConvertToCollisionChannel(false, Index). ConvertToTraceType(Visibility)
// round-trips through ConvertToCollisionChannel(true, Index). Camera and
// WorldDynamic remain distinct from those sources.
// Boundary/ownership: Enumerator names come from the active profile, not ECC_
// prefixes. The profile singleton owns the mapping. Invalid Index is the
// expected-failure path.
bool ObserveConvertToCollisionChannelNominal()
{
	EObjectTypeQuery WorldStaticObject = UCollisionProfile::ConvertToObjectType(ECollisionChannel::WorldStatic);
	ECollisionChannel FromObject = UCollisionProfile::ConvertToCollisionChannel(false, int32(WorldStaticObject));
	ETraceTypeQuery VisibilityTrace = UCollisionProfile::ConvertToTraceType(ECollisionChannel::Visibility);
	ECollisionChannel FromTrace = UCollisionProfile::ConvertToCollisionChannel(true, int32(VisibilityTrace));
	ECollisionChannel ZeroIndexObject = UCollisionProfile::ConvertToCollisionChannel(false, 0);
	return FromObject == ECollisionChannel::WorldStatic &&
		FromTrace == ECollisionChannel::Visibility &&
		ZeroIndexObject == ECollisionChannel::WorldStatic;
}
/** @end */
/**
 * @begin convert-to-object-type
 * @summary expected-failure path.
 * @topic Unreal
 */
/**
 * @function ObserveConvertToObjectTypeNominal
 * @summary expected-failure path.
 * @covers UCollisionProfile.convert-to-object-type
 * @inputs UCollisionProfile values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveConvertToObjectTypeNominal()
{
	EObjectTypeQuery WorldStatic = UCollisionProfile::ConvertToObjectType(ECollisionChannel::WorldStatic);
	EObjectTypeQuery WorldDynamic = UCollisionProfile::ConvertToObjectType(ECollisionChannel::WorldDynamic);
	return WorldStatic != WorldDynamic && WorldStatic == EObjectTypeQuery::WorldStatic;
}
/** @end */
/**
 * @begin convert-to-trace-type
 * @summary expected-failure path.
 * @topic Unreal
 */
/**
 * @function ObserveConvertToTraceTypeNominal
 * @summary expected-failure path.
 * @covers UCollisionProfile.convert-to-trace-type
 * @inputs UCollisionProfile values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveConvertToTraceTypeNominal()
{
	ETraceTypeQuery Visibility = UCollisionProfile::ConvertToTraceType(ECollisionChannel::Visibility);
	ETraceTypeQuery Camera = UCollisionProfile::ConvertToTraceType(ECollisionChannel::Camera);
	return Visibility != Camera && Visibility == ETraceTypeQuery::Visibility;
}
/** @end */
