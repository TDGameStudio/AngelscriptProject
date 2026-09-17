/**
 * @version v1
 * @summary Circular mixin references are rejected. C++ compiles it as the module ASSyntaxMixCircular and expects the diagnostic to name the cycle.
 * @topic Feature
 */
/**
 * @version root
 * @summary Circular mixin references are rejected. C++ compiles it as the module ASSyntaxMixCircular and expects the diagnostic to name the cycle.
 * @topic Negative
 */
/**
 * The isolated failing program: UMixinA applies UMixinB.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixCircular
 * @Inputs mixin class UMixinA applying UMixinB
 * @Return does not compile once the cycle closes
 */
mixin class UMixinA
{
	mixin UMixinB;
}

/**
 * The isolated failing program: UMixinB applies UMixinA, closing the cycle.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixCircular
 * @Inputs mixin class UMixinB applying UMixinA
 * @Return does not compile
 */
mixin class UMixinB
{
	mixin UMixinA;
}
/** @end */
