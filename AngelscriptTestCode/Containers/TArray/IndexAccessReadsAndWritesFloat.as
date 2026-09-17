/**
 * @version v1
 * @summary Operator [] reads and writes float elements, including const aliases.
 * @topic Containers
 *
 * IndexAccessReadsAndWritesFloat
 */
/**
 * @begin IndexAccessReadsAndWritesFloat
 * @summary Operator [] reads and writes float elements, including const aliases.
 * @topic Containers
 */
bool IndexAccessReadsAndWritesFloat()
{
	TArray<float> Values;
	Values.Add(10.0f);
	Values.Add(20.0f);
	float& Mutable = Values[0];
	bool bFirstIsTen = Mutable == 10.0f;
	Mutable = 30.0f;
	float AfterWrite = Values[0];
	float Last = Values[1];
	const TArray<float> ConstValues = Values;
	const float& ConstFirst = ConstValues[0];
	return bFirstIsTen && AfterWrite == 30.0f && Last == 20.0f && ConstFirst == 30.0f;
}
/** @end */
