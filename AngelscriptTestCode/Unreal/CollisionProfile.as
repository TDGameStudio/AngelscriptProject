/**
 * @version v1
 * @summary CollisionProfile host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic CollisionProfile
 *
 * ownership-bind-time-constants
 */
/**
 * @begin ownership-bind-time-constants
 * @summary Ownership: bind-time constants.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Ownership: bind-time constants.
 * @covers CollisionProfile.ownership-bind-time-constants
 * @inputs CollisionProfile values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	FName BlockAll = CollisionProfile::BlockAll;
	FName OverlapAll = CollisionProfile::OverlapAll;
	FName Pawn = CollisionProfile::Pawn;
	FName Camera = CollisionProfile::Camera;
	FName Trigger = CollisionProfile::Trigger;
	return BlockAll == n"BlockAll" &&
		BlockAll != NAME_None &&
		OverlapAll != NAME_None &&
		OverlapAll != BlockAll &&
		Pawn != NAME_None &&
		Pawn != BlockAll &&
		Camera != NAME_None &&
		Camera != Pawn &&
		Trigger != NAME_None &&
		Trigger != Camera;
}
/** @end */
