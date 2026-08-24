// Theme: Containers.TOptional. Isolated compile-fail: assign FString onto TOptional<int>.
// CSV Positive is wrong; C++ AssertFailsToCompile ASSyntaxCon_OptWrongType.
// Expected diagnostic: "Assigning wrong type to TOptional should fail".
// Isolate the failing program. DiagnosticOnly.

void Test()
{
	TOptional<int> Opt;
	Opt = "hello";
}
