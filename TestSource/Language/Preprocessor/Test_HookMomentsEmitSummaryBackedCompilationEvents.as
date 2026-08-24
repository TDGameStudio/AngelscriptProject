// Theme: Language.Preprocessor. Positive: class/property/function fixture for
// ProcessChunks and PostProcessCode compilation events.
// C++: AngelscriptPreprocessorCompilationEventsTests.cpp::HookMomentsEmitSummaryBackedCompilationEvents
// lines 53-66;
// sha256=224a5135d0ac5cb3b28e77d4ab05564452a86af3709e37a6c8d7f249aeaea6ed.
// Oracle: Entry() returns Value. Default Value is 0. Assigned Value writes back.
// Extra: default zero Value; non-zero assignment is the boundary.
// DefaultSafe. Keep UPROPERTY name Value.

UCLASS()
class UCompilationEventsHookMoments : UObject
{
	UPROPERTY()
	int Value;

	UFUNCTION()
	int Entry()
	{
		return Value;
	}
}

bool Observe_Entry_DefaultZero(UCompilationEventsHookMoments Carrier)
{
	if (Carrier is null)
	{
		throw("Test_HookMomentsEmitSummaryBackedCompilationEvents setup: required Carrier is null");
	}
	return Carrier.Entry() == 0;
}

bool Observe_Entry_AssignedBoundary(UCompilationEventsHookMoments Carrier)
{
	if (Carrier is null)
	{
		throw("Test_HookMomentsEmitSummaryBackedCompilationEvents setup: required Carrier is null");
	}
	Carrier.Value = 5;
	return Carrier.Entry() == 5;
}
