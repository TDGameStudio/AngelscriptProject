/**
 * @version v1
 * @summary Applying a non-mixin class as a mixin is rejected. C++ compiles it as the module ASSyntaxMixNonMixin and expects the diagnostic to name the ordinary class used as a mixin.
 * @topic Feature
 */
/**
 * @version root
 * @summary Applying a non-mixin class as a mixin is rejected. C++ compiles it as the module ASSyntaxMixNonMixin and expects the diagnostic to name the ordinary class used as a mixin.
 * @topic Negative
 */
/**
 * An ordinary actor class, not a mixin.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixNonMixin
 * @Inputs class ABaseMixN
 * @Return does not compile once used as a mixin
 */
class ABaseMixN : AActor
{
}

/**
 * The isolated failing program: only mixin classes can be applied with mixin.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixNonMixin
 * @Inputs class AChildMixN applying ABaseMixN
 * @Return does not compile
 */
class AChildMixN : AActor
{
	mixin ABaseMixN;
}
/** @end */
