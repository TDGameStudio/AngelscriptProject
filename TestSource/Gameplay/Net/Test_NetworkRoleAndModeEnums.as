// Theme: Gameplay.Net. Value oracle: ENetRole and ENetMode enum sums and ordering.
// C++: AngelscriptCoverageNetworkingTests.cpp::NetworkRoleAndModeEnums
// ExpectedRoleSum ROLE_None+SimulatedProxy+AutonomousProxy+Authority == 6.
// AuthorityRoleComparison true. ExpectedModeSum NM_Standalone+DedicatedServer+ListenServer+Client == 6.
// NetworkModeComparisons true.
// Extra: ROLE_None == 0 empty; NM_Standalone == 0 empty. DefaultSafe.

int NetworkRoleEnumValues()
{
	return int(ENetRole::ROLE_None)
		+ int(ENetRole::ROLE_SimulatedProxy)
		+ int(ENetRole::ROLE_AutonomousProxy)
		+ int(ENetRole::ROLE_Authority);
}

bool AuthorityRoleComparison()
{
	return int(ENetRole::ROLE_Authority) > int(ENetRole::ROLE_AutonomousProxy)
		&& int(ENetRole::ROLE_AutonomousProxy) > int(ENetRole::ROLE_SimulatedProxy)
		&& int(ENetRole::ROLE_SimulatedProxy) > int(ENetRole::ROLE_None);
}

int NetworkModeEnumValues()
{
	return int(ENetMode::NM_Standalone)
		+ int(ENetMode::NM_DedicatedServer)
		+ int(ENetMode::NM_ListenServer)
		+ int(ENetMode::NM_Client);
}

bool NetworkModeComparisons()
{
	return ENetMode::NM_Client != ENetMode::NM_Standalone
		&& ENetMode::NM_DedicatedServer != ENetMode::NM_ListenServer;
}

bool Observe_NetworkRoleEnumValues_Nominal()
{
	return NetworkRoleEnumValues() == 6;
}

bool Observe_AuthorityRoleComparison_Nominal()
{
	return AuthorityRoleComparison() == true;
}

bool Observe_NetworkModeEnumValues_Nominal()
{
	return NetworkModeEnumValues() == 6;
}

bool Observe_NetworkModeComparisons_Nominal()
{
	return NetworkModeComparisons() == true;
}

bool Observe_NetworkRole_NoneEmpty()
{
	return int(ENetRole::ROLE_None) == 0;
}

bool Observe_NetworkMode_StandaloneEmpty()
{
	return int(ENetMode::NM_Standalone) == 0;
}
