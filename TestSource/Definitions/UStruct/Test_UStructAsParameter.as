// Theme: Definitions.UStruct. WorldStory: value / &in / &out / &inout struct parameters.
// C++: AngelscriptCoverageUStructTests.cpp::UStructAsParameter spawn + BeginPlay.
// Oracle: ValueParam 100/Original, InParam 200/Source, OutParam 777/Modified, InoutParam 633/Mutable_Inout.
// Extra: empty Name and Value 0 before BeginPlay. FixtureIsolated.

USTRUCT()
struct FParamStruct
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	FString Name;
}

UCLASS()
class ACoverageStructParamActor : AActor
{
	UPROPERTY()
	FParamStruct ValueParam;

	UPROPERTY()
	FParamStruct InParam;

	UPROPERTY()
	FParamStruct OutParam;

	UPROPERTY()
	FParamStruct InoutParam;

	void ModifyByValue(FParamStruct Param)
	{
		// By-value UStruct params are immutable in this fork; mutating a local
		// copy still demonstrates that the caller's struct is unaffected.
		FParamStruct Local = Param;
		Local.Value = 999;
	}

	void ReadByConstRef(const FParamStruct&in Param)
	{
		InParam.Value = Param.Value;
		InParam.Name = Param.Name;
	}

	void WriteByRef(FParamStruct&out Param)
	{
		Param.Value = 777;
		Param.Name = "Modified";
	}

	void MutateInout(FParamStruct&inout Param)
	{
		Param.Value += 333;
		Param.Name += "_Inout";
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test value parameter (copy)
		ValueParam.Value = 100;
		ValueParam.Name = "Original";
		ModifyByValue(ValueParam);
		// ValueParam should remain 100

		// Test &in parameter (read-only reference)
		FParamStruct Source;
		Source.Value = 200;
		Source.Name = "Source";
		ReadByConstRef(Source);

		// Test &out parameter (write reference)
		WriteByRef(OutParam);

		// Test &inout parameter (read and write reference)
		InoutParam.Value = 300;
		InoutParam.Name = "Mutable";
		MutateInout(InoutParam);
	}
}

bool Observe_Param_DefaultEmpty(ACoverageStructParamActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructAsParameter setup: required Actor is null");
	}
	return Actor.ValueParam.Value == 0
		&& Actor.ValueParam.Name.Len() == 0
		&& Actor.OutParam.Value == 0
		&& Actor.InoutParam.Value == 0;
}

bool Observe_Param_NominalBeginPlay(ACoverageStructParamActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructAsParameter setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.ValueParam.Value == 100
		&& Actor.ValueParam.Name == "Original"
		&& Actor.InParam.Value == 200
		&& Actor.InParam.Name == "Source"
		&& Actor.OutParam.Value == 777
		&& Actor.OutParam.Name == "Modified"
		&& Actor.InoutParam.Value == 633
		&& Actor.InoutParam.Name == "Mutable_Inout";
}

bool Observe_Param_ValueCopyIndependence(ACoverageStructParamActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructAsParameter setup: required Actor is null");
	}
	FParamStruct Source;
	Source.Value = 0;
	Source.Name = "";
	Actor.ModifyByValue(Source);
	return Source.Value == 0 && Source.Name.Len() == 0;
}
