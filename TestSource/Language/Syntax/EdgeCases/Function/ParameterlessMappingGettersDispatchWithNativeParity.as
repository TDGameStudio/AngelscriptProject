/**
 * The parameterless UPlayerInput mapping getters: both return containers whose
 * sizes must match the native engine-defined mapping tables, without needing a
 * live player beyond the passed-in instance.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ParameterlessMappingGettersDispatchWithNativeParity
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.ParameterlessMappingGettersDispatchWithNativeParity
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptInputFunctionLibraryTests.cpp::ParameterlessMappingGettersDispatchWithNativeParity
 * @Provenance sha256=a88d2cbb0e53ac858c00bb1ad6a94f0fb63b27d3b8e3bf626bd28a64bde14649; lines 30-40.
 * @Provenance Oracle: GetActionMappingCount/GetAxisMappingCount match native GetEngineDefined*Mappings().Num().
 * @Provenance Extra: counts are non-negative; getters do not require a live player besides the UPlayerInput arg.
 * @Provenance DefaultSafe. PlayerInput owns the mapping tables.
 */

namespace SyntaxTest
{
	/**
	 * Counts the engine-defined action mappings.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a player input instance
	 * @Return the action mapping count
	 * @Param PlayerInput the instance to query
	 */
	int GetActionMappingCount(UPlayerInput PlayerInput)
	{
		return PlayerInput.GetEngineDefinedActionMappings().Num();
	}

	/**
	 * Counts the engine-defined axis mappings.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a player input instance
	 * @Return the axis mapping count
	 * @Param PlayerInput the instance to query
	 */
	int GetAxisMappingCount(UPlayerInput PlayerInput)
	{
		return PlayerInput.GetEngineDefinedAxisMappings().Num();
	}

	/**
	 * Observe that the action count is non-negative.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a player input instance
	 * @Return the count when non-negative, otherwise -1
	 * @Boundary non-negative count
	 * @Param PlayerInput the instance to query
	 */
	UFUNCTION()
	int ActionMappingCountNonNegative(UPlayerInput PlayerInput)
	{
		int Count = GetActionMappingCount(PlayerInput);
		return Count >= 0 ? Count : -1;
	}

	/**
	 * Observe that the axis count is non-negative.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a player input instance
	 * @Return the count when non-negative, otherwise -1
	 * @Boundary non-negative count
	 * @Param PlayerInput the instance to query
	 */
	UFUNCTION()
	int AxisMappingCountNonNegative(UPlayerInput PlayerInput)
	{
		int Count = GetAxisMappingCount(PlayerInput);
		return Count >= 0 ? Count : -1;
	}
}
