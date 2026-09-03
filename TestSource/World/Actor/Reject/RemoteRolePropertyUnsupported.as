/**
 * Reading AActor.RemoteRole is not bound, so this program is rejected. C++ compiles
 * it as the module ASCoverageNetworking_RemoteRolePropertyUnsupported and expects the
 * diagnostic to name RemoteRole. Its companion isolates Role.
 *
 * @Theme World.Actor
 * @Subject Actor.RemoteRolePropertyUnsupported
 * @Harness CompileReject
 * @Tag World.Actor.RemoteRolePropertyUnsupported
 * @Provenance Theme: World.Actor. Isolated compile-fail: unbound AActor.RemoteRole property access.
 * @Provenance C++: AngelscriptCoverageNetworkingTests.cpp::ActorNetworkRolePropertiesUnsupported
 * @Provenance CompileAndExpectFailure, diagnostic contains "RemoteRole".
 * @Provenance DiagnosticOnly. Do not add extra declarations that would compile this away.
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
