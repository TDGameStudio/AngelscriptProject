/**
 * ENetRole and ENetMode enum values and ordering. C++ executes each entrypoint and
 * compares the sums and comparisons with the native enumerators, so those names are
 * part of the contract and are kept verbatim. The observers cover ROLE_None and
 * NM_Standalone as the empty/zero values.
 *
 * @Theme Gameplay.Net
 * @Subject Net.NetworkRoleAndModeEnums
 * @Harness Function
 * @Tag Gameplay.Net.NetworkRoleAndModeEnums
 * @Namespace NetTest
 * @Provenance Theme: Gameplay.Net. Value oracle: ENetRole and ENetMode enum sums and ordering.
 * @Provenance C++: AngelscriptCoverageNetworkingTests.cpp::NetworkRoleAndModeEnums
 * @Provenance ExpectedRoleSum ROLE_None+SimulatedProxy+AutonomousProxy+Authority == 6.
 * @Provenance AuthorityRoleComparison true. ExpectedModeSum NM_Standalone+DedicatedServer+ListenServer+Client == 6.
 * @Provenance NetworkModeComparisons true.
 * @Provenance Extra: ROLE_None == 0 empty; NM_Standalone == 0 empty. DefaultSafe.
 */

namespace NetTest
{
	/**
	 * Sum the four ENetRole enumerators.
	 *
	 * @Kind Observe
	 * @Covers Net.NetworkRoleAndModeEnums
	 * @Inputs none
	 * @Return ROLE_None + SimulatedProxy + AutonomousProxy + Authority
	 */
	UFUNCTION()
	int NetworkRoleEnumValues()
	{
		return int(ENetRole::ROLE_None)
			+ int(ENetRole::ROLE_SimulatedProxy)
			+ int(ENetRole::ROLE_AutonomousProxy)
			+ int(ENetRole::ROLE_Authority);
	}

	/**
	 * Compare ENetRole authority ordering from Authority down to None.
	 *
	 * @Kind Observe
	 * @Covers Net.NetworkRoleAndModeEnums
	 * @Inputs none
	 * @Return true when Authority > AutonomousProxy > SimulatedProxy > None
	 */
	UFUNCTION()
	bool AuthorityRoleComparison()
	{
		if (int(ENetRole::ROLE_Authority) <= int(ENetRole::ROLE_AutonomousProxy))
		{
			return false;
		}
		if (int(ENetRole::ROLE_AutonomousProxy) <= int(ENetRole::ROLE_SimulatedProxy))
		{
			return false;
		}
		return int(ENetRole::ROLE_SimulatedProxy) > int(ENetRole::ROLE_None);
	}

	/**
	 * Sum the four ENetMode enumerators.
	 *
	 * @Kind Observe
	 * @Covers Net.NetworkRoleAndModeEnums
	 * @Inputs none
	 * @Return NM_Standalone + DedicatedServer + ListenServer + Client
	 */
	UFUNCTION()
	int NetworkModeEnumValues()
	{
		return int(ENetMode::NM_Standalone)
			+ int(ENetMode::NM_DedicatedServer)
			+ int(ENetMode::NM_ListenServer)
			+ int(ENetMode::NM_Client);
	}

	/**
	 * Compare distinct ENetMode values.
	 *
	 * @Kind Observe
	 * @Covers Net.NetworkRoleAndModeEnums
	 * @Inputs none
	 * @Return true when Client differs from Standalone and DedicatedServer differs from ListenServer
	 */
	UFUNCTION()
	bool NetworkModeComparisons()
	{
		if (ENetMode::NM_Client == ENetMode::NM_Standalone)
		{
			return false;
		}
		return ENetMode::NM_DedicatedServer != ENetMode::NM_ListenServer;
	}

	/**
	 * Observe that the role enumerators sum to 6.
	 *
	 * @Kind Observe
	 * @Covers Net.NetworkRoleAndModeEnums
	 * @Inputs none
	 * @Return true when NetworkRoleEnumValues is 6
	 */
	UFUNCTION()
	bool RoleEnumValuesComplete()
	{
		return NetworkRoleEnumValues() == 6;
	}

	/**
	 * Observe that the authority ordering comparison holds.
	 *
	 * @Kind Observe
	 * @Covers Net.NetworkRoleAndModeEnums
	 * @Inputs none
	 * @Return true when AuthorityRoleComparison holds
	 */
	UFUNCTION()
	bool AuthorityRoleOrderHolds()
	{
		return AuthorityRoleComparison();
	}

	/**
	 * Observe that the mode enumerators sum to 6.
	 *
	 * @Kind Observe
	 * @Covers Net.NetworkRoleAndModeEnums
	 * @Inputs none
	 * @Return true when NetworkModeEnumValues is 6
	 */
	UFUNCTION()
	bool ModeEnumValuesComplete()
	{
		return NetworkModeEnumValues() == 6;
	}

	/**
	 * Observe that the mode comparisons hold.
	 *
	 * @Kind Observe
	 * @Covers Net.NetworkRoleAndModeEnums
	 * @Inputs none
	 * @Return true when NetworkModeComparisons holds
	 */
	UFUNCTION()
	bool ModeComparisonsHold()
	{
		return NetworkModeComparisons();
	}

	/**
	 * Observe that ROLE_None is the empty/zero enumerator.
	 *
	 * @Kind Observe
	 * @Covers Net.NetworkRoleAndModeEnums
	 * @Inputs none
	 * @Return true when ROLE_None is 0
	 * @Boundary empty role
	 */
	UFUNCTION()
	bool RoleNoneEmpty()
	{
		return int(ENetRole::ROLE_None) == 0;
	}

	/**
	 * Observe that NM_Standalone is the empty/zero enumerator.
	 *
	 * @Kind Observe
	 * @Covers Net.NetworkRoleAndModeEnums
	 * @Inputs none
	 * @Return true when NM_Standalone is 0
	 * @Boundary empty mode
	 */
	UFUNCTION()
	bool ModeStandaloneEmpty()
	{
		return int(ENetMode::NM_Standalone) == 0;
	}
}
