// Theme: Language.Syntax.EdgeCases. Positive parameterless UPlayerInput mapping getters.
// C++: AngelscriptInputFunctionLibraryTests.cpp::ParameterlessMappingGettersDispatchWithNativeParity
// sha256=a88d2cbb0e53ac858c00bb1ad6a94f0fb63b27d3b8e3bf626bd28a64bde14649; lines 30-40.
// Oracle: GetActionMappingCount/GetAxisMappingCount match native GetEngineDefined*Mappings().Num().
// Extra: counts are non-negative; getters do not require a live player besides the UPlayerInput arg.
// DefaultSafe. PlayerInput owns the mapping tables.

int GetActionMappingCount(UPlayerInput PlayerInput)
{
	return PlayerInput.GetEngineDefinedActionMappings().Num();
}

int GetAxisMappingCount(UPlayerInput PlayerInput)
{
	return PlayerInput.GetEngineDefinedAxisMappings().Num();
}

int Observe_ActionMappingCount_NonNegative(UPlayerInput PlayerInput)
{
	int Count = GetActionMappingCount(PlayerInput);
	return Count >= 0 ? Count : -1;
}

int Observe_AxisMappingCount_NonNegative(UPlayerInput PlayerInput)
{
	int Count = GetAxisMappingCount(PlayerInput);
	return Count >= 0 ? Count : -1;
}
