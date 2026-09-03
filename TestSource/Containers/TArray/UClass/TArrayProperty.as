/**
 * TArray as UPROPERTY: Add, Num, and [] persist on a NewObject host.
 * int is canonical; FString, FName, and FVector are the other property shapes.
 * This is not a Bind API re-run and not a global RoundTrip.
 *
 * @Theme Containers.TArray
 * @Subject TArray.UProperty
 * @Harness UClass
 * @Tag Containers.TArray.TArrayProperty
 * @Namespace TArrayTest
 */

UCLASS()
class UTArrayPropertyHost : UObject
{
	UPROPERTY()
	TArray<int> Ints;

	UPROPERTY()
	TArray<FString> Strings;

	UPROPERTY()
	TArray<FName> Names;

	UPROPERTY()
	TArray<FVector> Vectors;
}

namespace TArrayTest
{
	/**
	 * Observe UPROPERTY TArray after NewObject: empty Num is 0, then Add persists
	 * for int, FString, FName, and FVector.
	 *
	 * @Kind Observe
	 * @Covers TArray.Add
	 * @Inputs NewObject UTArrayPropertyHost; empty properties; Add on each TArray UPROPERTY
	 * @Return true when empty Num is 0 and each property holds the added elements in order
	 */
	UFUNCTION()
	bool PropertyAddPersists()
	{
		UTArrayPropertyHost Host = Cast<UTArrayPropertyHost>(NewObject(GetTransientPackage(), UTArrayPropertyHost::StaticClass(), n"TArrayProperty_Host", true));
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
		if (Host.Ints.Num() != 2 || Host.Ints[0] != 10 || Host.Ints[1] != 20)
		{
			return false;
		}

		Host.Strings.Add("alpha");
		Host.Strings.Add("beta");
		if (Host.Strings.Num() != 2 || Host.Strings[0] != "alpha" || Host.Strings[1] != "beta")
		{
			return false;
		}

		Host.Names.Add(n"Player");
		Host.Names.Add(n"Enemy");
		if (Host.Names.Num() != 2 || Host.Names[0] != n"Player" || Host.Names[1] != n"Enemy")
		{
			return false;
		}

		Host.Vectors.Add(FVector(1.0f, 0.0f, 0.0f));
		Host.Vectors.Add(FVector(0.0f, 1.0f, 0.0f));
		return Host.Vectors.Num() == 2
			&& Host.Vectors[0].Equals(FVector(1.0f, 0.0f, 0.0f))
			&& Host.Vectors[1].Equals(FVector(0.0f, 1.0f, 0.0f));
	}
}
