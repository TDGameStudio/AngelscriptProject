/**
 * Legal nesting: TSet of a USTRUCT that itself contains TArray.
 * This is one container plus a struct, not a container nested in a container.
 * TSet elements must be hashable, so the payload implements Hash and opEquals
 * on Score only. Inner TArray is not part of identity.
 *
 * @Theme Containers.TSet
 * @Subject TSet.StructPayload
 * @Harness UClass
 * @Tag Containers.TSet.SetOfStructsContainingArrays
 * @Namespace TSetTest
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

	uint32 Hash() const
	{
		return uint32(Score);
	}
}

UCLASS()
class UTSetStructPayloadHost : UObject
{
	UPROPERTY()
	TSet<FSetPayload> Payloads;
}

namespace TSetTest
{
	/**
	 * Observe TSet<FSetPayload> as UPROPERTY: two payloads, Contains by Score,
	 * and foreach can still read each inner TArray. Do not mutate a live set
	 * element in place (hash identity is Score).
	 *
	 * @Kind Observe
	 * @Covers TSet.Add
	 * @Inputs NewObject host; Add payload 11 and 22; Contains; foreach inners
	 * @Return true when Num is 2, Contains hits, and inner sizes are 2 and 3
	 */
	UFUNCTION()
	bool StructPayloadSetPersistsInnerArrays()
	{
		UTSetStructPayloadHost Host = Cast<UTSetStructPayloadHost>(
			NewObject(GetTransientPackage(), UTSetStructPayloadHost::StaticClass(), n"TSetStructPayload_Host", true));
		if (Host == nullptr)
		{
			return false;
		}

		if (Host.Payloads.Num() != 0)
		{
			return false;
		}

		FSetPayload First;
		First.Score = 11;
		First.Label = "First";
		First.Values.Add(1);
		First.Values.Add(2);

		FSetPayload Second;
		Second.Score = 22;
		Second.Label = "Second";
		Second.Values.Add(10);
		Second.Values.Add(20);
		Second.Values.Add(30);

		Host.Payloads.Add(First);
		Host.Payloads.Add(Second);

		FSetPayload Probe;
		Probe.Score = 22;
		if (Host.Payloads.Num() != 2 || !Host.Payloads.Contains(Probe))
		{
			return false;
		}

		int InnerTwo = 0;
		int InnerThree = 0;
		for (FSetPayload Payload : Host.Payloads)
		{
			if (Payload.Score == 11 && Payload.Values.Num() == 2 && Payload.Values[0] == 1)
			{
				InnerTwo++;
			}
			if (Payload.Score == 22 && Payload.Values.Num() == 3 && Payload.Values[0] == 10)
			{
				InnerThree++;
			}
		}

		return InnerTwo == 1 && InnerThree == 1;
	}
}
