/**
 * @version v1
 * @summary MoveAssignFrom moves FVector elements into the destination and empties the source.
 * @topic Containers
 *
 * MoveAssignFromFVector
 */
/**
 * @begin MoveAssignFromFVector
 * @summary MoveAssignFrom moves FVector elements into the destination and empties the source.
 * @topic Containers
 */
bool MoveAssignFromFVector()
{
	TArray<FVector> Source;
	Source.Add(FVector(1.0f, 0.0f, 0.0f));
	Source.Add(FVector(0.0f, 1.0f, 0.0f));
	TArray<FVector> Destination;
	Destination.Add(FVector(1.0f, 1.0f, 1.0f));
	Destination.MoveAssignFrom(Source);
	return Destination.Num() == 2
		&& Destination[0].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& Destination[1].Equals(FVector(0.0f, 1.0f, 0.0f))
		&& Source.IsEmpty()
		&& Source.Num() == 0;
}
/** @end */
