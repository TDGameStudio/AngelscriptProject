/**
 * UWorld.GetNetMode as a compile-visible helper. C++ compiles the module and looks
 * up IsNetMode by name, so that name is part of the contract and is kept verbatim.
 * The observers cover a null world against Standalone and Client.
 *
 * @Theme Gameplay.Net
 * @Subject Net.WorldNetModeQueryIsVisible
 * @Harness Function
 * @Tag Gameplay.Net.WorldNetModeQueryIsVisible
 * @Namespace NetTest
 * @Provenance Theme: Gameplay.Net. Positive compile surface: UWorld.GetNetMode.
 * @Provenance C++: AngelscriptCoverageNetworkingTests.cpp::WorldNetModeQueryIsVisible
 * @Provenance Oracle: module compiles; IsNetMode exists.
 * @Provenance Extra: World null returns false. DefaultSafe.
 */

namespace NetTest
{
	/**
	 * Compare a world's net mode with a baseline enumerator.
	 *
	 * @Kind Observe
	 * @Covers Net.WorldNetModeQueryIsVisible
	 * @Inputs a world, which may be null, and a baseline net mode
	 * @Return false when World is null, otherwise whether GetNetMode equals BaselineMode
	 * @Param World the world to query
	 * @Param BaselineMode the enumerator to compare against
	 */
	UFUNCTION()
	bool IsNetMode(UWorld World, ENetMode BaselineMode)
	{
		if (World == null)
		{
			return false;
		}
		return World.GetNetMode() == BaselineMode;
	}

	/**
	 * Observe that a null world does not match Standalone.
	 *
	 * @Kind Observe
	 * @Covers Net.WorldNetModeQueryIsVisible
	 * @Inputs a null world and NM_Standalone
	 * @Return true when IsNetMode of null is false
	 * @Boundary null world
	 */
	UFUNCTION()
	bool NullWorld()
	{
		return IsNetMode(null, ENetMode::NM_Standalone) == false;
	}

	/**
	 * Observe that a null world does not match Client.
	 *
	 * @Kind Observe
	 * @Covers Net.WorldNetModeQueryIsVisible
	 * @Inputs a null world and NM_Client
	 * @Return true when IsNetMode of null is false
	 * @Boundary null world client
	 */
	UFUNCTION()
	bool NullClientBoundary()
	{
		return IsNetMode(null, ENetMode::NM_Client) == false;
	}
}
