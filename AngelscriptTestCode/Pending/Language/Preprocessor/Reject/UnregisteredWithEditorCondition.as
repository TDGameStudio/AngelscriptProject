/**
 * @version v1
 * @summary The legacy macro name WITH_EDITOR is not registered with this fork's preprocessor, so guarding code with it is rejected even though the engine-specific EDITOR flag exists. This file is the illegal program itself; do not.
 * @topic Language
 */
/**
 * @version root
 * @summary The legacy macro name WITH_EDITOR is not registered with this fork's preprocessor, so guarding code with it is rejected even though the engine-specific EDITOR flag exists. This file is the illegal program itself; do not.
 * @topic Negative
 */
/**
 * The rejected condition: WITH_EDITOR is not a registered flag, so the
 * condition never opens.
 *
 * @Covers Preprocessor.Conditionals
 * @Inputs the macro name WITH_EDITOR
 * @Return does not preprocess
 */
#if WITH_EDITOR
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
