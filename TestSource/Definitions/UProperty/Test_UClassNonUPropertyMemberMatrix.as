// Theme: Definitions.UProperty. WorldStory: plain members are usable; UPROPERTY copies are the observable oracle.
// C++: VerifyByPath ReflectedCounter 42; ReflectedLabel Seed_Runtime; ReflectedArraySum 11; ReflectedFunctionResult 42.
// Extra: empty RuntimeValues Num 0 before Add; ReadRuntimeCounter default 7. FixtureIsolated.

UCLASS()
class ACoverageUClassNonUPropertyMemberActor : AActor
{
	int RuntimeCounter = 7;
	FString RuntimeLabel = "Seed";
	TArray<int> RuntimeValues;

	UPROPERTY()
	int ReflectedCounter = 0;

	UPROPERTY()
	FString ReflectedLabel;

	UPROPERTY()
	int ReflectedArraySum = 0;

	UPROPERTY()
	int ReflectedFunctionResult = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RuntimeCounter += 35;
		RuntimeLabel += "_Runtime";
		RuntimeValues.Add(5);
		RuntimeValues.Add(6);
		ReflectedCounter = RuntimeCounter;
		ReflectedLabel = RuntimeLabel;
		ReflectedArraySum = RuntimeValues[0] + RuntimeValues[1];
		ReflectedFunctionResult = ReadRuntimeCounter();
	}

	UFUNCTION()
	int ReadRuntimeCounter()
	{
		return RuntimeCounter;
	}
}

int Observe_NonUProperty_EmptyRuntimeArrayNum()
{
	TArray<int> RuntimeValues;
	return RuntimeValues.Num();
}

int Observe_NonUProperty_DefaultRuntimeCounter()
{
	int RuntimeCounter = 7;
	return RuntimeCounter;
}
