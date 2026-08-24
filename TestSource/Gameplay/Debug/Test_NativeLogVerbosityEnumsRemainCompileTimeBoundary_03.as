// Theme: Gameplay.Debug. Isolated compile-fail: Verbose/VeryVerbose are not AS helpers.
// C++: AngelscriptCoverageDebugTests.cpp::NativeLogVerbosityEnumsRemainCompileTimeBoundary
// CompileAndExpectFailure fragment Verbose.
// CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop Verbose.

void TryVerboseVerbosity()
{
	Verbose("Coverage verbose");
	VeryVerbose("Coverage very verbose");
}
