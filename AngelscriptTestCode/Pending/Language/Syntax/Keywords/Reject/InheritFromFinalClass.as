/**
 * @version v1
 * @summary Deriving from a class marked final is rejected. C++ currently wraps this AssertFailsToCompile in #if 0 because the structural validation is absent, but the case remains a reject by intent.
 * @topic Language
 */
/**
 * @version root
 * @summary Deriving from a class marked final is rejected. C++ currently wraps this AssertFailsToCompile in #if 0 because the structural validation is absent, but the case remains a reject by intent.
 * @topic Negative
 */
/**
 * A final class, which cannot be used as a base.
 *
 * @Covers Syntax.Keywords
 * @Inputs none
 * @Return does not compile once derived from
 */
class AFinalActorInhN : AActor final
{
}

/**
 * Attempt to derive from the final class above.
 *
 * @Covers Syntax.Keywords
 * @Inputs AFinalActorInhN as a base
 * @Return does not compile
 */
class AChildActorInhN : AFinalActorInhN
{
}
/** @end */
