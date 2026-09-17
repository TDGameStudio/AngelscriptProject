/**
 * @version v1
 * @summary Reading AActor.RemoteRole is not bound, so this program is rejected. C++ compiles it as the module ASCoverageNetworking_RemoteRolePropertyUnsupported and expects the diagnostic to name RemoteRole. Its companion isolates.
 * @topic World
 */
/**
 * @version root
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
