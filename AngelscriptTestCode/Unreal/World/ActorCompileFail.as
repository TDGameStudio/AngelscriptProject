/**
 * @version v1
 * @summary World actor forms that do not compile.
 * @topic Unreal
 * @topic World
 *
 * old-instigator-controller-alias-rejected
 * old-instigator-pawn-alias-rejected
 * remote-role-property-unsupported
 * role-property-unsupported
 */
/**
 * @begin old-instigator-controller-alias-rejected
 * @summary The old GetActorInstigatorController alias is no longer bound, so this program is rejected. C++ compiles it as the module TestActorOldInstigatorControllerAliasRejected and expects the diagnostic to name.
 * @topic Negative
 */
UCLASS()
class ATestActorOldInstigatorControllerAliasRejected : AActor
{
	/**
	 * The isolated failing program: the GetActorInstigatorController alias has no
	 * matching signature.
	 *
	 * @Kind CompileReject
	 * @Covers Actor.OldInstigatorControllerAliasRejected
	 * @Inputs none
	 * @Return does not compile; "No matching signatures to 'ATestActorOldInstigatorControllerAliasRejected::GetActorInstigatorController()'"
	 */
	UFUNCTION()
	bool CheckOldControllerAlias()
	{
		return GetActorInstigatorController() == nullptr;
	}
}
/** @end */
/**
 * @begin old-instigator-pawn-alias-rejected
 * @summary The old GetActorInstigator alias is no longer bound, so this program is rejected. C++ compiles it as the module TestActorOldInstigatorPawnAliasRejected and expects the diagnostic to name GetActorInstigator. Its companion.
 * @topic Negative
 */
UCLASS()
class ATestActorOldInstigatorPawnAliasRejected : AActor
{
	/**
	 * The isolated failing program: the GetActorInstigator alias has no matching
	 * signature.
	 *
	 * @Kind CompileReject
	 * @Covers Actor.OldInstigatorPawnAliasRejected
	 * @Inputs none
	 * @Return does not compile; "No matching signatures to 'ATestActorOldInstigatorPawnAliasRejected::GetActorInstigator()'"
	 */
	UFUNCTION()
	bool CheckOldPawnAlias()
	{
		return GetActorInstigator() == nullptr;
	}
}
/** @end */
/**
 * @begin remote-role-property-unsupported
 * @summary Reading AActor.RemoteRole is not bound, so this program is rejected. C++ compiles it as the module ASCoverageNetworking_RemoteRolePropertyUnsupported and expects the diagnostic to name RemoteRole. Its companion isolates.
 * @topic Negative
 */
/**
 * The isolated failing program: AActor.RemoteRole has no matching signature.
 *
 * @Kind CompileReject
 * @Covers Actor.RemoteRolePropertyUnsupported
 * @Inputs an actor whose RemoteRole property is read
 * @Return does not compile; "AActor.RemoteRole should remain an explicit AS binding boundary"
 * @Param Actor the actor to read the remote role from
 */
bool ProbeRemoteRoleProperty(AActor Actor)
{
	return Actor.RemoteRole == ENetRole::ROLE_AutonomousProxy;
}
/** @end */
/**
 * @begin role-property-unsupported
 * @summary Reading AActor.Role is not bound, so this program is rejected. C++ compiles it as the module ASCoverageNetworking_RolePropertyUnsupported and expects the diagnostic to name Role. Its companion isolates RemoteRole.
 * @topic Negative
 */
/**
 * The isolated failing program: AActor.Role has no matching signature.
 *
 * @Kind CompileReject
 * @Covers Actor.RolePropertyUnsupported
 * @Inputs an actor whose Role property is read
 * @Return does not compile; "AActor.Role should remain an explicit AS binding boundary"
 * @Param Actor the actor to read the role from
 */
bool ProbeRoleProperty(AActor Actor)
{
	return Actor.Role == ENetRole::ROLE_Authority;
}
/** @end */
