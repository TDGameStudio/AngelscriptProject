/**
 * @version v1
 * @summary Operator [] reads and writes FVector elements, including const aliases.
 * @topic Containers
 *
 * IndexAccessReadsAndWritesFVector
 */
/**
 * @begin IndexAccessReadsAndWritesFVector
 * @summary Operator [] reads and writes FVector elements, including const aliases.
 * @topic Containers
 */
bool IndexAccessReadsAndWritesFVector()
{
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	FVector& Mutable = Values[0];
	bool bFirstIsX = Mutable.Equals(FVector(1.0f, 0.0f, 0.0f));
	Mutable = FVector(0.0f, 0.0f, 1.0f);
	FVector AfterWrite = Values[0];
	FVector Last = Values[1];
	const TArray<FVector> ConstValues = Values;
	const FVector& ConstFirst = ConstValues[0];
	return bFirstIsX
		&& AfterWrite.Equals(FVector(0.0f, 0.0f, 1.0f))
		&& Last.Equals(FVector(0.0f, 1.0f, 0.0f))
		&& ConstFirst.Equals(FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
