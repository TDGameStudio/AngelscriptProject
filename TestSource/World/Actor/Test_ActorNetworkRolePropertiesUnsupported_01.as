// Theme: World.Actor. Isolated compile-fail: unbound AActor.Role property access.
// C++: AngelscriptCoverageNetworkingTests.cpp::ActorNetworkRolePropertiesUnsupported
// CompileAndExpectFailure, diagnostic contains "Role".
// DiagnosticOnly. Do not add extra declarations that would compile this away.

bool ProbeRoleProperty(AActor Actor)
{
	return Actor.Role == ENetRole::ROLE_Authority;
}
