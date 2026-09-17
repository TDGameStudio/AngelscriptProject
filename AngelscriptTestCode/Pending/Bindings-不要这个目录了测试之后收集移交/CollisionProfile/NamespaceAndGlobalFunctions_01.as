/**
 * @version v1
 * @summary Observe CollisionProfile::<ProfileIdentifier> constants generated from UCollisionProfile, including identifier sanitization.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe CollisionProfile::<ProfileIdentifier> constants generated from UCollisionProfile, including identifier sanitization.
 * @topic Baseline
 */
// and Trigger, compared with NAME_None and n"BlockAll".
// Expected observations: Each constant is a non-none FName. BlockAll equals
// n"BlockAll". Sibling identifiers are distinct. Invalid identifier
// characters would have become underscores at bind time.
// Boundary/ownership: These are shared bind-time constants. Script does not
// own the collision-profile configuration.

namespace TS_CollisionProfile_NamespaceAndGlobalFunctions_01
{
	// const FName CollisionProfile::<ProfileIdentifier> publishes interned profile names.
	// Inputs: BlockAll, OverlapAll, Pawn, Camera, Trigger vs NAME_None and n"BlockAll".
	// Oracle: BlockAll equals n"BlockAll"; siblings are distinct and not none.
	// Ownership: bind-time constants; script does not own the profile config.
	bool Observe_Surface001_Nominal()
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
}
/** @end */
