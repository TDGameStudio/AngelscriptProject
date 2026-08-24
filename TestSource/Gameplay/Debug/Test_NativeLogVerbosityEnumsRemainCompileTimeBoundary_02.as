// Theme: Gameplay.Debug. Isolated compile-fail: Fatal is native crash behavior.
// C++: AngelscriptCoverageDebugTests.cpp::NativeLogVerbosityEnumsRemainCompileTimeBoundary
// CompileAndExpectFailure fragment Fatal.
// CSV Positive; C++ does not compile. DiagnosticOnly. Do not drop Fatal.

void TryFatalVerbosity()
{
	Fatal("Coverage fatal");
}
