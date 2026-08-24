// Theme: World.Actor. Isolated compile-fail: unbound AActor.RemoteRole property access.
// C++: AngelscriptCoverageNetworkingTests.cpp::ActorNetworkRolePropertiesUnsupported
// CompileAndExpectFailure, diagnostic contains "RemoteRole".
// DiagnosticOnly. Do not add extra declarations that would compile this away.

bool ProbeRemoteRoleProperty(AActor Actor)
{
	return Actor.RemoteRole == ENetRole::ROLE_AutonomousProxy;
}
