// Theme: Containers.TOptional. Isolated compile-fail: TOptional without template type.
// CSV Positive is wrong; C++ AssertFailsToCompile ASSyntaxCon_OptNoTemplate.
// Expected diagnostic: "TOptional without template type should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TOptional Opt;
}
