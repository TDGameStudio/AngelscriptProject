// Theme: Definitions.Meta. Isolated compile-fail: WITH_EDITOR is not a valid AS preprocessor condition.
// C++: WithEditorMacroNameRejected CompileAndExpectFailure.
// Expected diagnostic: "Invalid preprocessor condition: WITH_EDITOR".
// Isolate this failing program; do not rewrite as #if EDITOR.
// DiagnosticOnly.

#if WITH_EDITOR
int EditorOnlyValue()
{
	return 1;
}
#endif
