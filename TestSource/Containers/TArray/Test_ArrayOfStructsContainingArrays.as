// Theme: Containers.TArray. WorldStory: TArray<struct{TArray<int>}> occupancy.
// C++ VerifyByPath: PayloadCount=2, FirstInnerSize=2, SecondInnerFirstValue=10.
// Extra: empty Payloads stay 0 until BeginPlay; copy of First.Values is independent
// after Add. FixtureIsolated.

USTRUCT()
struct FArrayPayload
{
	UPROPERTY()
	TArray<int> Values;
}

UCLASS()
class ACoverageContainerArrayStructArrayActor : AActor
{
	UPROPERTY()
	TArray<FArrayPayload> Payloads;

	UPROPERTY()
	int PayloadCount = 0;

	UPROPERTY()
	int FirstInnerSize = 0;

	UPROPERTY()
	int SecondInnerFirstValue = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FArrayPayload First;
		First.Values.Add(1);
		First.Values.Add(2);

		FArrayPayload Second;
		Second.Values.Add(10);
		Second.Values.Add(20);
		Second.Values.Add(30);

		Payloads.Add(First);
		Payloads.Add(Second);

		PayloadCount = Payloads.Num();
		FirstInnerSize = Payloads[0].Values.Num();
		SecondInnerFirstValue = Payloads[1].Values[0];
	}
}
