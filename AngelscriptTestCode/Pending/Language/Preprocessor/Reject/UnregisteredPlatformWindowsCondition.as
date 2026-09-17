/**
 * @version v1
 * @summary The legacy macro name PLATFORM_WINDOWS is not registered with this fork's preprocessor, so guarding code with it is rejected. This file is the illegal program itself; do not swap in a registered flag, since the.
 * @topic Language
 */
/**
 * @version root
 * @summary The legacy macro name PLATFORM_WINDOWS is not registered with this fork's preprocessor, so guarding code with it is rejected. This file is the illegal program itself; do not swap in a registered flag, since the.
 * @topic Negative
 */
/**
 * The rejected condition: PLATFORM_WINDOWS is not a registered flag, so the
 * condition never opens.
 *
 * @Covers Preprocessor.Conditionals
 * @Inputs the macro name PLATFORM_WINDOWS
 * @Return does not preprocess
 */
#if PLATFORM_WINDOWS
/**
 * The function guarded by the unregistered macro. It never runs, since the
 * condition itself is rejected.
 *
 * @Covers Preprocessor.Conditionals
 * @Inputs none
 * @Return 1, never reached
 */
int Entry()
{
	return 1;
}
#endif
/** @end */
