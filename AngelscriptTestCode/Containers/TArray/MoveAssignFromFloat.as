/**
 * @version v1
 * @summary MoveAssignFrom moves float elements into the destination and empties the source.
 * @topic Containers
 *
 * MoveAssignFromFloat
 */
/**
 * @begin MoveAssignFromFloat
 * @summary MoveAssignFrom moves float elements into the destination and empties the source.
 * @topic Containers
 */
bool MoveAssignFromFloat()
{
	TArray<float> Source;
	Source.Add(10.0f);
	Source.Add(20.0f);
	TArray<float> Destination;
	Destination.Add(1.0f);
	Destination.MoveAssignFrom(Source);
	return Destination.Num() == 2 && Destination[0] == 10.0f && Destination[1] == 20.0f && Source.IsEmpty() && Source.Num() == 0;
}
/** @end */
