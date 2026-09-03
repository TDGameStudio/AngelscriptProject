/**
 * The engine-defined mapping getters take no arguments on this fork, so calling
 * them with one is rejected. This file is the illegal program itself; do not
 * strip the arguments, since passing them is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.LegacyMappingGetterArguments
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.LegacyMappingGetterArguments
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs mapping getters called with an FName argument
 * @Return does not compile; diagnostic names both getter functions
 * @Provenance C++: AngelscriptInputFunctionLibraryTests.cpp::LegacyMappingGetterArgumentsDoNotCompile
 * @Provenance CompileAndExpectFailure for argument-taking mapping getters.
 * @Provenance sha256=baf232dcfd1d565198cefa95647bed0addc9f433221b638401a80d1969a9091d; lines 65-71.
 * @Provenance Expected diagnostic contains "GetEngineDefinedActionMappings" and "GetEngineDefinedAxisMappings".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * Attempts both mapping getters with an argument.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs a player input instance
 * @Return does not compile in this file
 * @Param PlayerInput the player input to query
 */
void UseLegacyMappingArguments(UPlayerInput PlayerInput)
{
	PlayerInput.GetEngineDefinedActionMappings(n"LegacyAction");
	PlayerInput.GetEngineDefinedAxisMappings(n"LegacyAxis");
}
