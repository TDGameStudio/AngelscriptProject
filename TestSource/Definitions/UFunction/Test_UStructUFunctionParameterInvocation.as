// Theme: Definitions.UFunction. WorldStory: USTRUCT UFUNCTION value/const-ref/out/inout params.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUFunctionParameterInvocation
// CompileScriptModule then spawn + FFunctionInvoker. Keep LastValue/LastConstRef/LastOut/LastInout.
// Oracle: Incoming 10 -> LastValue 11/"Incoming_Value"; Borrowed 20 -> LastConstRef 22/"Borrowed_Ref";
// FillStructOut writes 55/"OutValue"; MutateStructInout 70/"Mutable" returns 73.
// Extra: default Count 0 / empty Label; by-value copy stays independent of LastValue.
// FixtureIsolated. Runner owns spawn.

USTRUCT(BlueprintType)
struct FInvokedStructParam
{
	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructUFunctionParamActor : AActor
{
	UPROPERTY()
	FInvokedStructParam LastValue;

	UPROPERTY()
	FInvokedStructParam LastConstRef;

	UPROPERTY()
	FInvokedStructParam LastOut;

	UPROPERTY()
	FInvokedStructParam LastInout;

	UFUNCTION(BlueprintCallable)
	void AcceptStructValue(FInvokedStructParam Param)
	{
		LastValue.Count = Param.Count + 1;
		LastValue.Label = Param.Label + "_Value";
	}

	UFUNCTION(BlueprintCallable)
	void AcceptStructConstRef(const FInvokedStructParam&in Param)
	{
		LastConstRef.Count = Param.Count + 2;
		LastConstRef.Label = Param.Label + "_Ref";
	}

	UFUNCTION(BlueprintCallable)
	void FillStructOut(FInvokedStructParam&out Param)
	{
		Param.Count = 55;
		Param.Label = "OutValue";
		LastOut = Param;
	}

	UFUNCTION(BlueprintCallable)
	int MutateStructInout(FInvokedStructParam&inout Param)
	{
		Param.Count += 3;
		Param.Label += "_Inout";
		LastInout = Param;
		return Param.Count;
	}
}

bool Observe_InvokedStructParam_EmptyDefault()
{
	FInvokedStructParam Param;
	return Param.Count == 0 && Param.Label == "";
}

bool Observe_AcceptStructValue_Nominal(ACoverageStructUFunctionParamActor Actor)
{
	FInvokedStructParam Param;
	Param.Count = 10;
	Param.Label = "Incoming";
	Actor.AcceptStructValue(Param);
	return Actor.LastValue.Count == 11 && Actor.LastValue.Label == "Incoming_Value";
}

bool Observe_AcceptStructValue_CopyIndependence(ACoverageStructUFunctionParamActor Actor)
{
	FInvokedStructParam First;
	First.Count = 10;
	First.Label = "Incoming";
	FInvokedStructParam Second = First;
	Actor.AcceptStructValue(First);
	return Second.Count == 10
		&& Second.Label == "Incoming"
		&& First.Count == 10
		&& Actor.LastValue.Count == 11
		&& Actor.LastValue.Label == "Incoming_Value";
}

bool Observe_AcceptStructConstRef_Nominal(ACoverageStructUFunctionParamActor Actor)
{
	FInvokedStructParam Param;
	Param.Count = 20;
	Param.Label = "Borrowed";
	Actor.AcceptStructConstRef(Param);
	return Actor.LastConstRef.Count == 22 && Actor.LastConstRef.Label == "Borrowed_Ref";
}

bool Observe_FillStructOut_Nominal(ACoverageStructUFunctionParamActor Actor)
{
	FInvokedStructParam Param;
	Actor.FillStructOut(Param);
	return Param.Count == 55
		&& Param.Label == "OutValue"
		&& Actor.LastOut.Count == 55
		&& Actor.LastOut.Label == "OutValue";
}

int Observe_MutateStructInout_Nominal(ACoverageStructUFunctionParamActor Actor)
{
	FInvokedStructParam Param;
	Param.Count = 70;
	Param.Label = "Mutable";
	int Result = Actor.MutateStructInout(Param);
	return Result;
}

bool Observe_MutateStructInout_Fields(ACoverageStructUFunctionParamActor Actor)
{
	FInvokedStructParam Param;
	Param.Count = 70;
	Param.Label = "Mutable";
	int Result = Actor.MutateStructInout(Param);
	return Result == 73
		&& Param.Count == 73
		&& Param.Label == "Mutable_Inout"
		&& Actor.LastInout.Count == 73
		&& Actor.LastInout.Label == "Mutable_Inout";
}

bool Observe_MutateStructInout_ZeroBoundary(ACoverageStructUFunctionParamActor Actor)
{
	FInvokedStructParam Param;
	int Result = Actor.MutateStructInout(Param);
	return Result == 3 && Param.Count == 3 && Param.Label == "_Inout";
}
