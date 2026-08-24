// Theme: Definitions.UProperty. WorldStory: BlueprintReadWrite TArray plus ClampMin/ClampMax metadata array.
// C++: BlueprintValues CPF_BlueprintVisible not ReadOnly; ClampedValues ClampMin 0 ClampMax 10.
// Extra: empty arrays Num 0 before Add. FixtureIsolated.

UCLASS()
class ACoverageTArrayPropertySpecifierActor : AActor
{
	UPROPERTY(BlueprintReadWrite)
	TArray<int> BlueprintValues;

	UPROPERTY(meta = (ClampMin = "0", ClampMax = "10"))
	TArray<int> ClampedValues;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BlueprintValues.Add(1);
		BlueprintValues.Add(2);
		ClampedValues.Add(3);
	}
}

int Observe_TArraySpecifier_EmptyBlueprintNum()
{
	TArray<int> BlueprintValues;
	return BlueprintValues.Num();
}

int Observe_TArraySpecifier_EmptyClampedNum()
{
	TArray<int> ClampedValues;
	return ClampedValues.Num();
}
