/**
 * @version v1
 * @summary UPROPERTY TMap starts empty and Add persists for int, FString, FName, FVector, and FString-to-FName.
 * @topic Containers
 *
 * ObjectProperty
 */
/**
 * @begin ObjectProperty
 * @summary UPROPERTY TMap starts empty and Add persists for int, FString, FName, FVector, and FString-to-FName.
 * @topic Containers
 */
UCLASS()
class UTMapPropertyHost : UObject
{
	UPROPERTY()
	TMap<int, int> Ints;

	UPROPERTY()
	TMap<FString, int> Strings;

	UPROPERTY()
	TMap<FName, int> Names;

	UPROPERTY()
	TMap<int, FVector> Vectors;

	UPROPERTY()
	TMap<FString, FName> StringToName;
}

bool ObjectProperty()
{
	UTMapPropertyHost Host = Cast<UTMapPropertyHost>(
		NewObject(GetTransientPackage(), UTMapPropertyHost::StaticClass(), n"TMapProperty_Host", true));
	if (Host == nullptr)
	{
		return false;
	}

	if (Host.Ints.Num() != 0 || Host.Strings.Num() != 0
		|| Host.Names.Num() != 0 || Host.Vectors.Num() != 0
		|| Host.StringToName.Num() != 0)
	{
		return false;
	}

	Host.Ints.Add(10, 100);
	Host.Ints.Add(20, 200);
	if (Host.Ints.Num() != 2 || Host.Ints[10] != 100 || Host.Ints[20] != 200)
	{
		return false;
	}

	Host.Strings.Add("alpha", 1);
	Host.Strings.Add("beta", 2);
	if (Host.Strings.Num() != 2 || Host.Strings["alpha"] != 1 || Host.Strings["beta"] != 2)
	{
		return false;
	}

	Host.Names.Add(n"Player", 1);
	Host.Names.Add(n"Enemy", 2);
	if (Host.Names.Num() != 2 || Host.Names[n"Player"] != 1 || Host.Names[n"Enemy"] != 2)
	{
		return false;
	}

	Host.Vectors.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Host.Vectors.Add(2, FVector(0.0f, 1.0f, 0.0f));
	if (Host.Vectors.Num() != 2
		|| !Host.Vectors[1].Equals(FVector(1.0f, 0.0f, 0.0f))
		|| !Host.Vectors[2].Equals(FVector(0.0f, 1.0f, 0.0f)))
	{
		return false;
	}

	Host.StringToName.Add("StringKey", n"StringName");
	return Host.StringToName.Num() == 1 && Host.StringToName["StringKey"] == n"StringName";
}
/** @end */
