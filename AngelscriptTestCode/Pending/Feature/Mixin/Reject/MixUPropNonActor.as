/**
 * @version v1
 * @summary Applying a UPROPERTY mixin to a plain class is rejected. C++ compiles it as the module ASSyntaxMixUPropNonActor and expects the diagnostic to name the non-actor host.
 * @topic Feature
 */
/**
 * @version root
 * @summary Applying a UPROPERTY mixin to a plain class is rejected. C++ compiles it as the module ASSyntaxMixUPropNonActor and expects the diagnostic to name the non-actor host.
 * @topic Negative
 */
/**
 * A mixin that carries a UPROPERTY, which cannot land on a plain class.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixUPropNonActor
 * @Inputs mixin class UHealthMixinUPropN
 * @Return does not compile once applied to a non-actor
 */
mixin class UHealthMixinUPropN
{
	UPROPERTY()
	int Health = 100;
}

/**
 * The isolated failing program: a UPROPERTY mixin cannot be applied to a plain class.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixUPropNonActor
 * @Inputs class FMyPlainClass applying UHealthMixinUPropN
 * @Return does not compile
 */
class FMyPlainClass
{
	mixin UHealthMixinUPropN;
}
/** @end */
