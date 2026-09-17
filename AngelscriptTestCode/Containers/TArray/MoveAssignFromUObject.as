/**
 * @version v1
 * @summary MoveAssignFrom moves UObject handles into the destination and empties the source.
 * @topic Containers
 *
 * MoveAssignFromUObject
 */
/**
 * @begin MoveAssignFromUObject
 * @summary MoveAssignFrom moves UObject handles into the destination and empties the source.
 * @topic Containers
 */
UCLASS()
class UTArrayMoveAssignFromUObjectHost : UObject
{
}

bool MoveAssignFromUObject()
{
	UObject First = NewObject(GetTransientPackage(), UTArrayMoveAssignFromUObjectHost::StaticClass(), n"MoveAssignFrom_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayMoveAssignFromUObjectHost::StaticClass(), n"MoveAssignFrom_Second", true);
	UObject Keep = NewObject(GetTransientPackage(), UTArrayMoveAssignFromUObjectHost::StaticClass(), n"MoveAssignFrom_Keep", true);
	TArray<UObject> Source;
	Source.Add(First);
	Source.Add(Second);
	TArray<UObject> Destination;
	Destination.Add(Keep);
	Destination.MoveAssignFrom(Source);
	return Destination.Num() == 2 && Destination[0] == First && Destination[1] == Second && Source.IsEmpty() && Source.Num() == 0;
}
/** @end */
