// Theme: Language.Const. Isolated compile-fail from ConstViolationNegativeCompile.
// C++: AngelscriptCoverageConstTests.cpp::ConstViolationNegativeCompile
// sha256=7463a6b1118813055ad5949ca8524d13cdd4cc314eaa3c09662a3357219a265b; lines 245-250.
// Oracle: compile fails — modifying a const value parameter (Value = 2).
// DiagnosticOnly. Source owns the isolated failing program.

void Test(const int Value)
{
	Value = 2;
}
