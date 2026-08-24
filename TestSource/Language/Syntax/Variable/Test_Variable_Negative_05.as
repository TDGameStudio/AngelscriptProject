// Theme: Language.Syntax.Variable. NegativeDiagnostic: identifier starting with a digit.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Variable_Negative block 5 AssertFailsToCompile.
// sha256=ca11a4a38b705ecaad31be299a29ba1671ae5fd1e84af2089d1691ef454ba907; lines 598-600.
// Expected diagnostic: "Name starting with number". Isolate this failing program.
// DiagnosticOnly.

void Test()
{
	int 123abc = 0;
}
