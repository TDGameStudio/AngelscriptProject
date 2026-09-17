/**
 * @version v1
 * @summary ConfigEnums host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic ConfigEnums
 *
 * ownership-enum-values
 * ConfigEnums-ConstructionAndAssignment_01-ownership-enum-values
 * ownership-enum-values-active
 */
/**
 * @begin ownership-enum-values
 * @summary Ownership: enum values.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Ownership: enum values.
 * @covers ConfigEnums.ownership-enum-values
 * @inputs ConfigEnums values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	ETraceTypeQuery Visibility = ETraceTypeQuery::Visibility;
	ETraceTypeQuery Camera = ETraceTypeQuery::Camera;
	ETraceTypeQuery Copied = Visibility;
	bool bCopyIndependentAndEqual = Copied == Visibility;
	Copied = Camera;
	bool bAssignmentReplacesValue = Copied == Camera && Visibility == ETraceTypeQuery::Visibility;
	return bCopyIndependentAndEqual && bAssignmentReplacesValue && Visibility != Camera;
}
/** @end */
/**
 * @begin ConfigEnums-ConstructionAndAssignment_01-ownership-enum-values
 * @summary Ownership: enum values.
 * @topic Unreal
 */
/**
 * @function ObserveSurface002Nominal
 * @summary Ownership: enum values.
 * @covers ConfigEnums.ownership-enum-values
 * @inputs ConfigEnums values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface002Nominal()
{
	ECollisionChannel WorldStaticChannel = ECollisionChannel::WorldStatic;
	ECollisionChannel Copied = WorldStaticChannel;
	bool bCopiedChannelEqualsSource = Copied == WorldStaticChannel;
	Copied = ECollisionChannel::WorldDynamic;
	bool bAssignedChannelDiffers = Copied != WorldStaticChannel;
	return bCopiedChannelEqualsSource && bAssignedChannelDiffers;
}
/** @end */
/**
 * @begin ownership-enum-values-active
 * @summary Ownership: enum values from the active profile plus fixed channels.
 * @topic Unreal
 */
/**
 * @function ObserveSurface003Nominal
 * @summary Ownership: enum values from the active profile plus fixed channels.
 * @covers ConfigEnums.ownership-enum-values-active
 * @inputs ConfigEnums values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface003Nominal()
{
	EObjectTypeQuery WorldStatic = EObjectTypeQuery::WorldStatic;
	EObjectTypeQuery WorldDynamic = EObjectTypeQuery::WorldDynamic;
	EObjectTypeQuery PhysicsBody = EObjectTypeQuery::PhysicsBody;
	EObjectTypeQuery Copied = WorldStatic;
	bool bCopyEqualsWorldStatic = Copied == WorldStatic;
	Copied = PhysicsBody;
	bool bAssignmentSelectsPhysicsBody = Copied == PhysicsBody && WorldStatic != WorldDynamic;
	return bCopyEqualsWorldStatic && bAssignmentSelectsPhysicsBody;
}
/** @end */
