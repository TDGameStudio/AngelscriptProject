// Theme: Definitions.Meta. Isolated compile-fail: Verbose/VeryVerbose are not AS logging helpers.
// C++: UnsupportedNativeLogMacrosAndVerbosityEnumsFailToCompile block 4 CompileAndExpectFailure.
// Expected diagnostic names Verbose.
// Isolate this failing program; do not replace with Print.
// DiagnosticOnly.

void TryNativeVerboseVerbosity()
{
	Verbose("Coverage verbose");
	VeryVerbose("Coverage very verbose");
}
