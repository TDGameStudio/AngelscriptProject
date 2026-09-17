/**
 * @version v1
 * @summary Append copies the other UObject array onto the end and leaves the source unchanged.
 * @topic Containers
 *
 * AppendOtherArrayUObject
 */
/**
 * @begin AppendOtherArrayUObject
 * @summary Append copies the other UObject array onto the end and leaves the source unchanged.
 * @topic Containers
 */
UCLASS()
class UTArrayAppendOtherArrayUObjectHost : UObject
{
}

bool AppendOtherArrayUObject()
{
	TArray<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTArrayAppendOtherArrayUObjectHost::StaticClass(), n"AppendOther_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayAppendOtherArrayUObjectHost::StaticClass(), n"AppendOther_Second", true);
	UObject Third = NewObject(GetTransientPackage(), UTArrayAppendOtherArrayUObjectHost::StaticClass(), n"AppendOther_Third", true);
	Values.Add(First);
	TArray<UObject> Other;
	Other.Add(Second);
	Other.Add(Third);
	Values.Append(Other);
	TArray<UObject> EmptyOther;
	Values.Append(EmptyOther);
	return Values.Num() == 3 && Values[1] == Second && Values[2] == Third && Other.Num() == 2;
}
/** @end */
