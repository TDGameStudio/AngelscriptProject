/**
 * @version v1
 * @summary WITH_EDITOR is not a valid AngelScript preprocessor condition, so this program is rejected. Isolate the failing construct; do not rewrite as #if EDITOR.
 * @topic Definitions
 */
/**
 * @version root
 * @summary WITH_EDITOR is not a valid AngelScript preprocessor condition, so this program is rejected. Isolate the failing construct; do not rewrite as #if EDITOR.
 * @topic Negative
 */
/**
 * The rejected condition: WITH_EDITOR is not a registered flag.
 *
 * @Kind CompileReject
 * @Covers Meta.WithEditorMacroNameRejected
 * @Inputs the macro name WITH_EDITOR
 * @Return does not preprocess; "Invalid preprocessor condition: WITH_EDITOR"
 */
#if WITH_EDITOR
/**
 * The function guarded by the unregistered macro. It never runs, since the
 * condition itself is rejected.
 *
 * @Kind CompileReject
 * @Covers Meta.WithEditorMacroNameRejected
 * @Inputs none
 * @Return 1, never reached
 */
int EditorOnlyValue()
{
	return 1;
}
#endif
/** @end */
