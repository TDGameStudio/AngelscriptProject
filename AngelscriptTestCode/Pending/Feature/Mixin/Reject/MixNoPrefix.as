/**
 * @version v1
 * @summary A mixin class whose name has no U prefix is rejected. C++ compiles it as the module ASSyntaxMixNoPrefix and expects the diagnostic to name the missing prefix.
 * @topic Feature
 */
/**
 * @version root
 * @summary A mixin class whose name has no U prefix is rejected. C++ compiles it as the module ASSyntaxMixNoPrefix and expects the diagnostic to name the missing prefix.
 * @topic Negative
 */
/**
 * The isolated failing program: mixin class names must start with U.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixNoPrefix
 * @Inputs mixin class HealthMixin with Health = 100
 * @Return does not compile
 */
mixin class HealthMixin
{
	int Health = 100;
}
/** @end */
