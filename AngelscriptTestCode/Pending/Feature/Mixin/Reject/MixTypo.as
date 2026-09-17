/**
 * @version v1
 * @summary A mixin keyword typo `mixn` is rejected. C++ compiles it as the module ASSyntaxMixTypo and expects the diagnostic to name the unknown keyword.
 * @topic Feature
 */
/**
 * @version root
 * @summary A mixin keyword typo `mixn` is rejected. C++ compiles it as the module ASSyntaxMixTypo and expects the diagnostic to name the unknown keyword.
 * @topic Negative
 */
/**
 * The isolated failing program: mixn is not the mixin keyword.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixTypo
 * @Inputs mixn class UBadMixin
 * @Return does not compile
 */
mixn class UBadMixin
{
	int X = 0;
}
/** @end */
