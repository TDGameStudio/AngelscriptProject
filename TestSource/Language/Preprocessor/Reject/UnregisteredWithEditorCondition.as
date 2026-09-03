/**
 * The legacy macro name WITH_EDITOR is not registered with this fork's
 * preprocessor, so guarding code with it is rejected even though the
 * engine-specific EDITOR flag exists. This file is the illegal program itself;
 * do not swap in EDITOR, since the unregistered name is the point.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.UnregisteredWithEditorCondition
 * @Harness CompileReject
 * @Tag Language.Preprocessor.UnregisteredWithEditorCondition
 * @Kind CompileReject
 * @Covers Preprocessor.Conditionals
 * @Inputs #if WITH_EDITOR around a function definition
 * @Return does not preprocess; diagnostic "Invalid preprocessor condition: WITH_EDITOR"
 * @Provenance C++: AngelscriptCoveragePreprocessorTests.cpp::UnregisteredLegacyMacroNamesReportDiagnostics
 * @Provenance AssertPreprocessFailed; lines 280-287;
 * @Provenance sha256=7b42855cebe53b9f06070fb30b2442c4feca07682204819ae4671e58c3d802e3.
 * @Provenance Expected diagnostic: "Invalid preprocessor condition: WITH_EDITOR" (count 1).
 * @Provenance Do not replace WITH_EDITOR with EDITOR.
 * @Provenance DiagnosticOnly.
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
