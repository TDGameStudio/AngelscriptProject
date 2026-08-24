// Theme: Feature.Delegates. Positive compile-events compatibility carrier.
// C++: AngelscriptCompilerEventsTests.cpp::ExistingCompileDelegatesRemainCompatible
// Oracle: module compiles; UCompilationEventsDelegates.Entry()==13.
// Extra: empty object is null. DefaultSafe.

UCLASS()
class UCompilationEventsDelegates : UObject
{
	UFUNCTION()
	int Entry()
	{
		return 13;
	}
}

bool Observe_CompileEvents_EmptyDefaultIsNull()
{
	UCompilationEventsDelegates Obj;
	return Obj == nullptr;
}

int Observe_CompileEvents_Entry(UCompilationEventsDelegates Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-FEAT-0008 setup: required UCompilationEventsDelegates is null");
	}
	return Obj.Entry();
}
