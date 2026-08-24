// Theme: Feature.Default. CSV NegativeDiagnostic. C++ CompileSafetyScript(..., bExpectedCompile=true)
// so an ordinary UFUNCTION may call unsafe_during_construction.
// C++: AngelscriptDefaultStatementSafetyTests.cpp::UnsafeDuringConstructionRejectsDefaultAndConstructor
// Oracle: Entry() returns 7. Extra: Value default 0; UnsafeValue()==7. Keep Value/Entry.
// DefaultSafe.

UCLASS()
class UUnsafeOrdinaryTarget : UObject
{
	UPROPERTY()
	int Value = 0;

	int UnsafeValue() unsafe_during_construction
	{
		return 7;
	}

	UFUNCTION()
	int Entry()
	{
		return UnsafeValue();
	}
}

bool Observe_UnsafeOrdinary_EmptyDefaultIsNull()
{
	UUnsafeOrdinaryTarget Target;
	return Target == nullptr;
}

int Observe_UnsafeOrdinary_ValueDefaultZero(UUnsafeOrdinaryTarget Target)
{
	if (Target == nullptr)
	{
		throw("TS-FEAT-0242 setup: required UUnsafeOrdinaryTarget is null");
	}
	return Target.Value;
}

int Observe_UnsafeOrdinary_EntryNominal(UUnsafeOrdinaryTarget Target)
{
	if (Target == nullptr)
	{
		throw("TS-FEAT-0242 setup: required UUnsafeOrdinaryTarget is null");
	}
	return Target.Entry();
}

int Observe_UnsafeOrdinary_UnsafeValueDirect(UUnsafeOrdinaryTarget Target)
{
	if (Target == nullptr)
	{
		throw("TS-FEAT-0242 setup: required UUnsafeOrdinaryTarget is null");
	}
	return Target.UnsafeValue();
}
