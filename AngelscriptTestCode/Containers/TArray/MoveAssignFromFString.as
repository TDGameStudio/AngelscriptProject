/**
 * @version v1
 * @summary MoveAssignFrom moves FString elements into the destination and empties the source.
 * @topic Containers
 *
 * MoveAssignFromFString
 */
/**
 * @begin MoveAssignFromFString
 * @summary MoveAssignFrom moves FString elements into the destination and empties the source.
 * @topic Containers
 */
bool MoveAssignFromFString()
{
	TArray<FString> Source;
	Source.Add("alpha");
	Source.Add("beta");
	TArray<FString> Destination;
	Destination.Add("keep");
	Destination.MoveAssignFrom(Source);
	return Destination.Num() == 2 && Destination[0] == "alpha" && Destination[1] == "beta" && Source.IsEmpty() && Source.Num() == 0;
}
/** @end */
