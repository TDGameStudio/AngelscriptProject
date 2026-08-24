// Theme: Language.ControlFlow.Switch. Isolated compile-fail from SwitchUnsupportedTypes.
// C++: AngelscriptCoverageConditionalTests.cpp::SwitchUnsupportedTypes
// sha256=558f222b278210ca8e5cea1c1d4891fb615b57e47f8aead55af76283914ecf4c; lines 753-764.
// Oracle: compile fails — switch expressions must be integral numbers (FName is rejected).
// DiagnosticOnly. Source owns the isolated failing program.

int SwitchFName(FName Name)
{
	switch (Name)
	{
		case n"Alpha":
			return 1;
		default:
			return 0;
	}
}
