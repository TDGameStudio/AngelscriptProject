/**
 * @version v1
 * @summary TMap of structs that contain arrays keeps inner copies independent after the property inner grows.
 * @topic Containers
 *
 * StructsContainingArrays
 */
/**
 * @begin StructsContainingArrays
 * @summary TMap of structs that contain arrays keeps inner copies independent after the property inner grows.
 * @topic Containers
 */
USTRUCT()
struct FMapPayload
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;

	UPROPERTY()
	TArray<int> Values;
}

UCLASS()
class UTMapStructPayloadHost : UObject
{
	UPROPERTY()
	TMap<int, FMapPayload> Payloads;
}

bool StructsContainingArrays()
{
	UTMapStructPayloadHost Host = Cast<UTMapStructPayloadHost>(
		NewObject(GetTransientPackage(), UTMapStructPayloadHost::StaticClass(), n"TMapStructPayload_Host", true));
	if (Host == nullptr)
	{
		return false;
	}

	if (Host.Payloads.Num() != 0)
	{
		return false;
	}

	FMapPayload First;
	First.Score = 11;
	First.Label = "First";
	First.Values.Add(1);
	First.Values.Add(2);

	FMapPayload Second;
	Second.Score = 22;
	Second.Label = "Second";
	Second.Values.Add(10);
	Second.Values.Add(20);
	Second.Values.Add(30);

	Host.Payloads.Add(1, First);
	Host.Payloads.Add(2, Second);

	FMapPayload Found;
	if (!Host.Payloads.Find(2, Found)
		|| Found.Score != 22
		|| Found.Label != "Second"
		|| Found.Values.Num() != 3)
	{
		return false;
	}

	FMapPayload Replacement;
	Replacement.Score = 33;
	Replacement.Label = "Replacement";
	Replacement.Values.Add(7);
	Host.Payloads.Add(1, Replacement);

	if (Host.Payloads.Num() != 2
		|| Host.Payloads[1].Score != 33
		|| Host.Payloads[1].Label != "Replacement"
		|| Host.Payloads[2].Values[0] != 10)
	{
		return false;
	}

	TArray<int> CopiedSecondInner = Host.Payloads[2].Values;
	Host.Payloads[2].Values.Add(99);
	return CopiedSecondInner.Num() == 3
		&& Host.Payloads[2].Values.Num() == 4
		&& Host.Payloads[2].Values[3] == 99
		&& CopiedSecondInner[0] == 10
		&& CopiedSecondInner[2] == 30;
}
/** @end */
