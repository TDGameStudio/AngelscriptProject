/**
 * Reading AActor.Role is not bound, so this program is rejected. C++ compiles it as
 * the module ASCoverageNetworking_RolePropertyUnsupported and expects the diagnostic
 * to name Role. Its companion isolates RemoteRole.
 *
 * @Theme World.Actor
 * @Subject Actor.RolePropertyUnsupported
 * @Harness CompileReject
 * @Tag World.Actor.RolePropertyUnsupported
 * @Provenance Theme: World.Actor. Isolated compile-fail: unbound AActor.Role property access.
 * @Provenance C++: AngelscriptCoverageNetworkingTests.cpp::ActorNetworkRolePropertiesUnsupported
 * @Provenance CompileAndExpectFailure, diagnostic contains "Role".
 * @Provenance DiagnosticOnly. Do not add extra declarations that would compile this away.
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
