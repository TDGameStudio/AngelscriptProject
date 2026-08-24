// Theme: Definitions.UFunction. WorldStory const UFUNCTION plus const &in parameter.
// C++: AngelscriptCoverageConstTests.cpp::ConstUFunctionAndPropertyReflection
// Oracle after BeginPlay: Observed == 21 + (21+8) == 50; Value stays 21.
// Extra: AddConstParam(0) empty addend; nullptr actor is the empty handle; mutating Observed does not change Value.
// FixtureIsolated. Keep Value / Observed names.

UCLASS()
class ACoverageConstActor : AActor
{
	UPROPERTY()
	int Value = 21;

	UPROPERTY()
	int Observed = 0;

	UFUNCTION()
	int GetValue() const
	{
		return Value;
	}

	UFUNCTION()
	int AddConstParam(const int&in Amount) const
	{
		return Value + Amount;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		const int Bonus = 8;
		Observed = GetValue() + AddConstParam(Bonus);
	}
}

bool Observe_Const_BeginPlayOracle(ACoverageConstActor Actor)
{
	Actor.BeginPlay();
	return Actor.Observed == 50 && Actor.Value == 21;
}

bool Observe_Const_AddZeroEmpty(ACoverageConstActor Actor)
{
	return Actor.AddConstParam(0) == 21 && Actor.GetValue() == 21;
}

bool Observe_Const_NullDefault()
{
	ACoverageConstActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_Const_CopyIndependent(ACoverageConstActor First, ACoverageConstActor Second)
{
	First.Observed = 0;
	First.Value = 0;
	return Second.Value == 21 && Second.GetValue() == 21;
}
