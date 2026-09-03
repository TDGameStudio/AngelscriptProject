/**
 * Legal nesting: TArray of a USTRUCT that itself contains TArray.
 * This is one container plus a struct, not a container nested in a container.
 *
 * @Theme Containers.TArray
 * @Subject TArray.StructPayload
 * @Harness UClass
 * @Tag Containers.TArray.ArrayOfStructsContainingArrays
 * @Namespace TArrayTest
 */

USTRUCT()
struct FArrayPayload
{
	UPROPERTY()
	TArray<int> Values;
}

UCLASS()
class UTArrayStructPayloadHost : UObject
{
	UPROPERTY()
	TArray<FArrayPayload> Payloads;
}

namespace TArrayTest
{
	/**
	 * Observe TArray<FArrayPayload> as UPROPERTY: two payloads, inner sizes, first
	 * inner copy stays independent after the property inner array grows.
	 *
	 * @Kind Observe
	 * @Covers TArray.Add
	 * @Inputs NewObject host; Add payload [1,2] then [10,20,30]; copy Payloads[0].Values; Add 99 on the property inner
	 * @Return true when Num is 2, first inner Num is 2 then 3, second inner [0] is 10, and the copy stays Num 2
	 */
	UFUNCTION()
	bool StructPayloadArrayPersistsIndependentInners()
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

		TArray<int> CopiedFirstInner = Host.Payloads[0].Values;
		Host.Payloads[0].Values.Add(99);
		return CopiedFirstInner.Num() == 2
			&& Host.Payloads[0].Values.Num() == 3
			&& Host.Payloads[0].Values[2] == 99
			&& CopiedFirstInner[0] == 1
			&& CopiedFirstInner[1] == 2;
	}
}
