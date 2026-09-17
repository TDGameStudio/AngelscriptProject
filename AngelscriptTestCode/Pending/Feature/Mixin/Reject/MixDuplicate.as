/**
 * @version v1
 * @summary Applying the same mixin twice to one class is rejected. C++ compiles it as the module ASSyntaxMixDuplicate and expects the diagnostic to name the duplicate application.
 * @topic Feature
 */
/**
 * @version root
 * @summary Applying the same mixin twice to one class is rejected. C++ compiles it as the module ASSyntaxMixDuplicate and expects the diagnostic to name the duplicate application.
 * @topic Negative
 */
/**
 * A mixin class applied twice on the actor below.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixDuplicate
 * @Inputs mixin class UHealthMixinDup
 * @Return does not compile once applied twice
 */
mixin class UHealthMixinDup
{
	int Health = 100;
}

/**
 * The isolated failing program: the same mixin cannot be applied twice.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixDuplicate
 * @Inputs class AMixDupActor applying UHealthMixinDup twice
 * @Return does not compile
 */
class AMixDupActor : AActor
{
	mixin UHealthMixinDup;
	mixin UHealthMixinDup;
}
/** @end */
