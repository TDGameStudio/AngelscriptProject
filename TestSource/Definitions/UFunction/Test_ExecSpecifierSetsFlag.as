// Theme: Definitions.UFunction. Positive Exec specifier compiles and is callable.
// C++: AngelscriptCompilerUFunctionSpecifierMatrixTests.cpp::ExecSpecifierSetsFlag
// Oracle: ConsoleCommand exists; C++ checks FUNC_Exec.
// Extra: nullptr handle is the empty vector; a second call remains a no-op.
// DefaultSafe.

UCLASS()
class UExecTestObj : UObject
{
	UFUNCTION(Exec)
	void ConsoleCommand()
	{
	}
}

int Observe_ConsoleCommand_EmptyCall(UExecTestObj Object)
{
	Object.ConsoleCommand();
	return 1;
}

bool Observe_ConsoleCommand_NullDefault()
{
	UExecTestObj Object = nullptr;
	return Object == nullptr;
}

int Observe_ConsoleCommand_RepeatCall(UExecTestObj Object)
{
	Object.ConsoleCommand();
	Object.ConsoleCommand();
	return 1;
}
