/**
 * TSet as UPROPERTY: Add, Num, and Contains persist on a NewObject host.
 * int is canonical; FString, FName, and FVector are the other property shapes.
 * This is not a Bind API re-run and not a global RoundTrip.
 *
 * @Theme Containers.TSet
 * @Subject TSet.UProperty
 * @Harness UClass
 * @Tag Containers.TSet.TSetProperty
 * @Namespace TSetTest
 */

UCLASS()
class UTSetPropertyHost : UObject
{
	UPROPERTY()
	TSet<int> Ints;

	UPROPERTY()
	TSet<FString> Strings;

	UPROPERTY()
	TSet<FName> Names;

	UPROPERTY()
	TSet<FVector> Vectors;
}

namespace TSetTest
{
	/**
	 * Observe UPROPERTY TSet after NewObject: empty Num is 0, then Add persists
	 * for int, FString, FName, and FVector.
	 *
	 * @Kind Observe
	 * @Covers TSet.Add
	 * @Inputs NewObject UTSetPropertyHost; empty properties; Add on each TSet UPROPERTY
	 * @Return true when empty Num is 0 and each property holds the added members
	 */
	UFUNCTION()
	bool PropertyAddPersists()
	{
		UTSetPropertyHost Host = Cast<UTSetPropertyHost>(
			NewObject(GetTransientPackage(), UTSetPropertyHost::StaticClass(), n"TSetProperty_Host", true));
		if (Host == nullptr)
		{
			return false;
		}

		if (Host.Ints.Num() != 0 || Host.Strings.Num() != 0
			|| Host.Names.Num() != 0 || Host.Vectors.Num() != 0)
		{
			return false;
		}

		Host.Ints.Add(10);
		Host.Ints.Add(20);
		if (Host.Ints.Num() != 2 || !Host.Ints.Contains(10) || !Host.Ints.Contains(20))
		{
			return false;
		}

		Host.Strings.Add("alpha");
		Host.Strings.Add("beta");
		if (Host.Strings.Num() != 2 || !Host.Strings.Contains("alpha") || !Host.Strings.Contains("beta"))
		{
			return false;
		}

		Host.Names.Add(n"Player");
		Host.Names.Add(n"Enemy");
		if (Host.Names.Num() != 2 || !Host.Names.Contains(n"Player") || !Host.Names.Contains(n"Enemy"))
		{
			return false;
		}

		Host.Vectors.Add(FVector(1.0f, 0.0f, 0.0f));
		Host.Vectors.Add(FVector(0.0f, 1.0f, 0.0f));
		return Host.Vectors.Num() == 2
			&& Host.Vectors.Contains(FVector(1.0f, 0.0f, 0.0f))
			&& Host.Vectors.Contains(FVector(0.0f, 1.0f, 0.0f));
	}
}
