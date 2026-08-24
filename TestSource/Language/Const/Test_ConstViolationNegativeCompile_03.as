// Theme: Language.Const. Isolated compile-fail from ConstViolationNegativeCompile.
// C++: AngelscriptCoverageConstTests.cpp::ConstViolationNegativeCompile
// sha256=6d38acd5f6855d5867e23f4ff3ae382c5c9aa076bb1cc88ada2a70bfb427f0f7; lines 258-268.
// Oracle: compile fails — mutating a member from a const method.
// DiagnosticOnly. Source owns the isolated failing program.

class ConstMutationProbe
{
	int Value = 0;

	void Mutate() const
	{
		Value = 2;
	}
}
