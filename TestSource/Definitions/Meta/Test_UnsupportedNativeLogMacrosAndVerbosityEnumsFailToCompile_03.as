// Theme: Definitions.Meta. Isolated compile-fail: Fatal() is native crash logging, not an AS helper.
// C++: UnsupportedNativeLogMacrosAndVerbosityEnumsFailToCompile block 3 CompileAndExpectFailure.
// Expected diagnostic names Fatal.
// Isolate this failing program; do not replace with PrintError.
// DiagnosticOnly.

void TryNativeFatalVerbosity()
{
	Fatal("Coverage fatal");
}
