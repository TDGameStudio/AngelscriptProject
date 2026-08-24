// Theme: Gameplay.Debug. Callstack frames plus throw exception path.
// C++: AngelscriptCoverageDebugTests.cpp::CallstackAndThrowBindings
// CSV NegativeDiagnostic; C++ compiles. ExecuteAndExpectInt EntryCallstack == 1.
// ThrowEntry raises CoverageThrowMessage. Extra: empty stack / missing needle are false.
// DefaultSafe.

bool StackContains(const TArray<FString>& Stack, const FString& Needle)
{
	for (int Index = 0; Index < Stack.Num(); ++Index)
	{
		if (Stack[Index].Contains(Needle))
		{
			return true;
		}
	}
	return false;
}

int ProbeCallstack()
{
	TArray<FString> Stack = GetAngelscriptCallstack();
	FString Formatted = FormatAngelscriptCallstack();
	if (Stack.Num() < 3)
	{
		return 0;
	}
	if (!StackContains(Stack, "ProbeCallstack"))
	{
		return 0;
	}
	if (!StackContains(Stack, "EntryCallstack"))
	{
		return 0;
	}
	if (!Formatted.Contains("ProbeCallstack"))
	{
		return 0;
	}
	if (!Formatted.Contains("EntryCallstack"))
	{
		return 0;
	}
	return 1;
}

int EntryCallstack()
{
	return ProbeCallstack();
}

void ThrowLeaf()
{
	throw("CoverageThrowMessage");
}

int ThrowEntry()
{
	ThrowLeaf();
	return 0;
}

bool Observe_EntryCallstack_Nominal()
{
	return EntryCallstack() == 1;
}

bool Observe_StackContains_EmptyDefault()
{
	TArray<FString> Empty;
	return StackContains(Empty, "ProbeCallstack") == false;
}

bool Observe_StackContains_MissingNeedle()
{
	TArray<FString> Stack;
	Stack.Add("OtherFrame");
	return StackContains(Stack, "ProbeCallstack") == false;
}
