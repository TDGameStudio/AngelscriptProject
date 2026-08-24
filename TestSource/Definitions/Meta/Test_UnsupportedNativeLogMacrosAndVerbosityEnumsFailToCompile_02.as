// Theme: Definitions.Meta. Isolated compile-fail: ELogVerbosity is not script-facing.
// C++: UnsupportedNativeLogMacrosAndVerbosityEnumsFailToCompile block 2 CompileAndExpectFailure.
// Expected diagnostic names ELogVerbosity.
// Isolate this failing program; do not replace with Print/Warning helpers.
// DiagnosticOnly.

int TryNativeVerbosityEnum()
{
	ELogVerbosity Value = ELogVerbosity::VeryVerbose;
	return int(Value);
}
