// Theme: Language.ControlFlow.Switch. NegativeDiagnostic: case label outside switch.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Switch_Negative block 4
// sha256=3f55092e724222915be2f093e4d2dedea600f146a876821cc6cc020d740d98f1; lines 344-346.
// Expected compile failure: "Case label outside switch".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	case 1:
		int X = 0;
}
