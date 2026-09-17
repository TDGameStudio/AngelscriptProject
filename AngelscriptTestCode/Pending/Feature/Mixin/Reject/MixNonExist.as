/**
 * @version v1
 * @summary Applying a mixin type that does not exist is rejected. C++ compiles it as the module ASSyntaxMixNonExist and expects the diagnostic to name the missing mixin.
 * @topic Feature
 */
/**
 * @version root
 * @summary Applying a mixin type that does not exist is rejected. C++ compiles it as the module ASSyntaxMixNonExist and expects the diagnostic to name the missing mixin.
 * @topic Negative
 */
/**
 * The isolated failing program: the applied mixin type is never declared.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixNonExist
 * @Inputs class AMixNonExistActor applying UNonExistentMixin
 * @Return does not compile
 */
class AMixNonExistActor : AActor
{
	mixin UNonExistentMixin;
}
/** @end */
