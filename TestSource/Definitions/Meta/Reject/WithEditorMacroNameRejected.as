/**
 * WITH_EDITOR is not a valid AngelScript preprocessor condition, so this program
 * is rejected. Isolate the failing construct; do not rewrite as #if EDITOR.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.WithEditorMacroNameRejected
 * @Harness CompileReject
 * @Tag Definitions.Meta.WithEditorMacroNameRejected
 * @Provenance Theme: Definitions.Meta. Isolated compile-fail: WITH_EDITOR is not a valid AS preprocessor condition.
 * @Provenance C++: WithEditorMacroNameRejected CompileAndExpectFailure.
 * @Provenance Expected diagnostic: "Invalid preprocessor condition: WITH_EDITOR".
 * @Provenance Isolate this failing program; do not rewrite as #if EDITOR.
 * @Provenance DiagnosticOnly.
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
