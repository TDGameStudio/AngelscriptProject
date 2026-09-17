/**
 * @version v1
 * @summary MoveAssignFrom moves elements into the destination and empties the source.
 * @topic Containers
 *
 * MoveAssignFrom
 */
/**
 * @begin MoveAssignFrom
 * @summary MoveAssignFrom moves elements into the destination and empties the source.
 * @topic Containers
 */
bool MoveAssignFrom()
{
	TArray<int32> Source;
	Source.Add(10);
	Source.Add(20);
	TArray<int32> Destination;
	Destination.Add(1);
	Destination.MoveAssignFrom(Source);
	return Destination.Num() == 2 && Destination[0] == 10 && Destination[1] == 20 && Source.IsEmpty() && Source.Num() == 0;
}
/** @end */
