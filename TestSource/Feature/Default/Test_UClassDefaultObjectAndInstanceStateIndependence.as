// Theme: Feature.Default. Positive UObject CDO defaults and instance independence.
// C++: AngelscriptCoverageUClassTests.cpp::UClassDefaultObjectAndInstanceStateIndependence
// VerifyByPath Counter==12 Label=="Seed" on the first instance. Keep Counter/Label.
// Extra: empty handle is null; mutating First does not write Second.
// DefaultSafe.

UCLASS(BlueprintType)
class UCoverageUClassDefaultObjectProbe : UObject
{
	UPROPERTY()
	int Counter = 12;

	UPROPERTY()
	FString Label = "Seed";
}

bool Observe_DefaultObjectProbe_EmptyDefaultIsNull()
{
	UCoverageUClassDefaultObjectProbe Obj;
	return Obj == nullptr;
}

int Observe_DefaultObjectProbe_CounterNominal(UCoverageUClassDefaultObjectProbe Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-FEAT-0118 setup: required UCoverageUClassDefaultObjectProbe is null");
	}
	return Obj.Counter;
}

FString Observe_DefaultObjectProbe_LabelNominal(UCoverageUClassDefaultObjectProbe Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-FEAT-0118 setup: required UCoverageUClassDefaultObjectProbe is null");
	}
	return Obj.Label;
}

bool Observe_DefaultObjectProbe_CopyIndependent(
	UCoverageUClassDefaultObjectProbe First,
	UCoverageUClassDefaultObjectProbe Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0118 setup: required UCoverageUClassDefaultObjectProbe pair is null");
	}
	First.Counter = 0;
	First.Label = "";
	return Second.Counter == 12 && Second.Label == "Seed";
}
