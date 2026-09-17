/**
 * @version v1
 * @summary A UPROPERTY TArray of structs with inner arrays copies independently after the property inner grows.
 * @topic Containers
 *
 * StructsContainingArrays
 */
/**
 * @begin StructsContainingArrays
 * @summary A UPROPERTY TArray of structs with inner arrays copies independently after the property inner grows.
 * @topic Containers
 */
USTRUCT()
struct FArrayPayload
{
	UPROPERTY()
	TArray<int32> Values;
}

UCLASS()
class UTArrayStructPayloadHost : UObject
{
	UPROPERTY()
	TArray<FArrayPayload> Payloads;
}

bool StructsContainingArrays()
{
	UTArrayStructPayloadHost Host = Cast<UTArrayStructPayloadHost>(NewObject(GetTransientPackage(), UTArrayStructPayloadHost::StaticClass(), n"TArrayStructPayload_Host", true));
	if (Host == nullptr)
	{
		return false;
	}

	if (Host.Payloads.Num() != 0)
	{
		return false;
	}

	FArrayPayload First;
	First.Values.Add(1);
	First.Values.Add(2);

	FArrayPayload Second;
	Second.Values.Add(10);
	Second.Values.Add(20);
	Second.Values.Add(30);

	Host.Payloads.Add(First);
	Host.Payloads.Add(Second);

	if (Host.Payloads.Num() != 2
		|| Host.Payloads[0].Values.Num() != 2
		|| Host.Payloads[1].Values.Num() != 3
		|| Host.Payloads[1].Values[0] != 10)
	{
		return false;
	}

	TArray<int32> CopiedFirstInner = Host.Payloads[0].Values;
	Host.Payloads[0].Values.Add(99);
	return CopiedFirstInner.Num() == 2
		&& Host.Payloads[0].Values.Num() == 3
		&& Host.Payloads[0].Values[2] == 99
		&& CopiedFirstInner[0] == 1
		&& CopiedFirstInner[1] == 2;
}
/** @end */
