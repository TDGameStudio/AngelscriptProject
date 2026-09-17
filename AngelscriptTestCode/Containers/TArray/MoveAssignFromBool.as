/**
 * @version v1
 * @summary MoveAssignFrom moves bool elements into the destination and empties the source.
 * @topic Containers
 *
 * MoveAssignFromBool
 */
/**
 * @begin MoveAssignFromBool
 * @summary MoveAssignFrom moves bool elements into the destination and empties the source.
 * @topic Containers
 */
bool MoveAssignFromBool()
{
	TArray<bool> Source;
	Source.Add(true);
	Source.Add(false);
	TArray<bool> Destination;
	Destination.Add(false);
	Destination.MoveAssignFrom(Source);
	return Destination.Num() == 2 && Destination[0] == true && Destination[1] == false && Source.IsEmpty() && Source.Num() == 0;
}
/** @end */
