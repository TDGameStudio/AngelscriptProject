// Theme: Definitions.UProperty. WorldStory: EditAnywhere FRotator plus reflected TArray/TMap of rotators.
// C++: EditableRotation CPF_Edit/BlueprintVisible/ReadOnly; Category Coverage|Rotator; ClampMin -180 ClampMax 180.
// Extra: empty ReflectedRotators Num 0 before BeginPlay; ZeroRotator is the empty vector. FixtureIsolated.

UCLASS()
class ACoverageFRotatorSpecifierActor : AActor
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Coverage|Rotator", meta = (ClampMin = "-180.0", ClampMax = "180.0"))
	FRotator EditableRotation = FRotator(10, -20, 30);

	UPROPERTY()
	TArray<FRotator> ReflectedRotators;

	UPROPERTY()
	TMap<int, FRotator> ReflectedRotatorMap;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ReflectedRotators.Add(EditableRotation);
		ReflectedRotators.Add(FRotator::ZeroRotator);

		ReflectedRotatorMap.Add(7, FRotator(70, 80, 90));
	}
}

int Observe_FRotator_EmptyArrayNum()
{
	TArray<FRotator> ReflectedRotators;
	return ReflectedRotators.Num();
}

bool Observe_FRotator_ZeroIsIndependentCopy()
{
	FRotator EditableRotation = FRotator(10, -20, 30);
	FRotator Zero = FRotator::ZeroRotator;
	return EditableRotation.Pitch != Zero.Pitch;
}
