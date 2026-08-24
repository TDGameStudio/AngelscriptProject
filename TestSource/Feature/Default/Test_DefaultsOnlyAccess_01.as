// Theme: Feature.Default. Positive defaults-only method used from a default statement.
// C++: AngelscriptDefaultStatementSafetyTests.cpp::DefaultsOnlyAccess CompileSafetyScript true.
// Oracle: CDO/instance Value==7 after default Value = BuildDefaultValue().
// Extra: empty handle is null; mutating First does not write Second. Keep Value.
// DefaultSafe.

UCLASS()
class UDefaultsOnlyOkTarget : UObject
{
	UPROPERTY()
	int Value = 0;

	int BuildDefaultValue() defaults
	{
		Value = 7;
		return Value;
	}

	default Value = BuildDefaultValue();
}

bool Observe_DefaultsOnlyOk_EmptyDefaultIsNull()
{
	UDefaultsOnlyOkTarget Target;
	return Target == nullptr;
}

int Observe_DefaultsOnlyOk_ValueAfterDefault(UDefaultsOnlyOkTarget Target)
{
	if (Target == nullptr)
	{
		throw("TS-FEAT-0243 setup: required UDefaultsOnlyOkTarget is null");
	}
	return Target.Value;
}

bool Observe_DefaultsOnlyOk_CopyIndependent(
	UDefaultsOnlyOkTarget First,
	UDefaultsOnlyOkTarget Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0243 setup: required UDefaultsOnlyOkTarget pair is null");
	}
	First.Value = 0;
	return Second.Value == 7;
}
