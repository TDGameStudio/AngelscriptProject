/**
 * @version v1
 * @summary The engine-defined mapping getters take no arguments on this fork, so calling them with one is rejected. This file is the illegal program itself; do not strip the arguments, since passing them is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary The engine-defined mapping getters take no arguments on this fork, so calling them with one is rejected. This file is the illegal program itself; do not strip the arguments, since passing them is the point.
 * @topic Negative
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
/** @end */
