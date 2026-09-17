/**
 * @version v1
 * @summary A UPROPERTY TArray starts empty after NewObject and Add persists int32, FString, FName, and FVector.
 * @topic Containers
 *
 * ObjectProperty
 */
/**
 * @begin ObjectProperty
 * @summary A UPROPERTY TArray starts empty after NewObject and Add persists int32, FString, FName, and FVector.
 * @topic Containers
 */
UCLASS()
class UTArrayPropertyHost : UObject
{
	UPROPERTY()
	TArray<int32> Ints;

	UPROPERTY()
	TArray<FString> Strings;

	UPROPERTY()
	TArray<FName> Names;

	UPROPERTY()
	TArray<FVector> Vectors;
}

bool ObjectProperty()
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
/** @end */
