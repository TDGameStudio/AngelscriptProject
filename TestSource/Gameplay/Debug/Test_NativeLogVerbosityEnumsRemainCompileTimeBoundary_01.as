// Theme: Gameplay.Debug. Isolated compile-fail: native ELogVerbosity is not script-facing.
// C++: AngelscriptCoverageDebugTests.cpp::NativeLogVerbosityEnumsRemainCompileTimeBoundary
// CompileAndExpectFailure fragment ELogVerbosity.
// CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop ELogVerbosity.

int TryNativeVerbosityEnum()
{
	ELogVerbosity Value = ELogVerbosity::VeryVerbose;
	return int(Value);
}
