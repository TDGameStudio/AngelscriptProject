/**
 * @version v1
 * @summary TSet of a USTRUCT that contains TArray stores unique members by equality.
 * @topic Containers
 *
 * StructsContainingArrays
 */
/**
 * @begin StructsContainingArrays
 * @summary TSet of a USTRUCT that contains TArray stores unique members by equality.
 * @topic Containers
 */
USTRUCT()
struct FSetPayload
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;

	UPROPERTY()
	TArray<int> Values;

	bool opEquals(const FSetPayload&in Other) const
	{
		return Score == Other.Score;
	}
}

bool StructsContainingArrays()
{
	FSetPayload First;
	First.Score = 1;
	First.Label = "one";
	First.Values.Add(10);

	FSetPayload DuplicateScore;
	DuplicateScore.Score = 1;
	DuplicateScore.Label = "other";
	DuplicateScore.Values.Add(20);

	FSetPayload Second;
	Second.Score = 2;
	Second.Label = "two";

	TSet<FSetPayload> Payloads;
	Payloads.Add(First);
	Payloads.Add(DuplicateScore);
	Payloads.Add(Second);
	return Payloads.Num() == 2
		&& Payloads.Contains(First)
		&& Payloads.Contains(Second);
}
/** @end */
