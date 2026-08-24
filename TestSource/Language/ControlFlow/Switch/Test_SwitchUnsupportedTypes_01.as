// Theme: Language.ControlFlow.Switch. Isolated compile-fail from SwitchUnsupportedTypes.
// C++: AngelscriptCoverageConditionalTests.cpp::SwitchUnsupportedTypes
// sha256=f5aafffc859c2f34529e5fafb0e241baf376999400c16f8489c70620e2f14b18; lines 732-744.
// Oracle: compile fails — switch expressions must be integral numbers (bool is rejected).
// DiagnosticOnly. Source owns the isolated failing program.

int SwitchBool(bool Value)
{
	switch (Value)
	{
		case true:
			return 1;
		case false:
			return 0;
	}
	return -1;
}
