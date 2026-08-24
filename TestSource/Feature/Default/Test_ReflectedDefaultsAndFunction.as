// Theme: Feature.Default. Positive UObject reflected defaults plus helper UFUNCTION.
// C++: AngelscriptObjectModelTests.cpp::ReflectedDefaultsAndFunction
// VerifyByPath Counter==9 ObjectLabel=="FunctionalObject"; ComputeMarker()==14.
// Extra: Counter 0 yields 5; empty ObjectLabel; copy independence. Keep Counter/ObjectLabel.
// DefaultSafe.

UCLASS()
class UObjectReflectedDefaultsAndFunction : UObject
{
	UPROPERTY()
	int Counter = 9;

	UPROPERTY()
	FString ObjectLabel = "FunctionalObject";

	UFUNCTION()
	int ComputeMarker()
	{
		return Counter + 5;
	}
}

bool Observe_ReflectedDefaults_EmptyDefaultIsNull()
{
	UObjectReflectedDefaultsAndFunction Obj;
	return Obj == nullptr;
}

int Observe_ReflectedDefaults_ComputeMarkerNominal(UObjectReflectedDefaultsAndFunction Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-FEAT-0221 setup: required UObjectReflectedDefaultsAndFunction is null");
	}
	return Obj.ComputeMarker();
}

int Observe_ReflectedDefaults_ComputeMarkerZeroBoundary(UObjectReflectedDefaultsAndFunction Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-FEAT-0221 setup: required UObjectReflectedDefaultsAndFunction is null");
	}
	Obj.Counter = 0;
	return Obj.ComputeMarker();
}

FString Observe_ReflectedDefaults_EmptyLabelBoundary(UObjectReflectedDefaultsAndFunction Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-FEAT-0221 setup: required UObjectReflectedDefaultsAndFunction is null");
	}
	Obj.ObjectLabel = "";
	return Obj.ObjectLabel;
}

bool Observe_ReflectedDefaults_CopyIndependent(
	UObjectReflectedDefaultsAndFunction First,
	UObjectReflectedDefaultsAndFunction Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0221 setup: required UObjectReflectedDefaultsAndFunction pair is null");
	}
	First.Counter = 0;
	First.ObjectLabel = "";
	return Second.Counter == 9 && Second.ObjectLabel == "FunctionalObject";
}
