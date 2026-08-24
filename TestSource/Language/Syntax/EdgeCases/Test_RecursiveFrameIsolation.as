// Theme: Language.Syntax.EdgeCases. Positive compile of nested throw frames.
// C++: AngelscriptExecutionNestedCallTests.cpp::ExceptionCallstackInspection
// sha256=fb1470ff1bcaac379ac6204bf48e2d1a558c37c7a5a8686ce388266779f4e6ea; lines 65-86.
// Oracle: Entry() throws "ContextCallstackFailure" with frames FailInner, TriggerFailure, Entry.
// Extra: FailInner(0) and FailInner(-1) do not throw (Inner <= 0).
// DefaultSafe. throw string is the exception payload; locals Inner/Local isolate frames.

void FailInner(int Value)
{
	int Inner = Value * 2;
	if (Inner > 0)
	{
		throw("ContextCallstackFailure");
	}
}

void TriggerFailure(int Seed)
{
	int Local = Seed + 1;
	FailInner(Local);
}

int Entry()
{
	TriggerFailure(20);
	return 0;
}

int Observe_FailInner_NonPositiveBoundary()
{
	FailInner(0);
	FailInner(-1);
	return 1;
}
