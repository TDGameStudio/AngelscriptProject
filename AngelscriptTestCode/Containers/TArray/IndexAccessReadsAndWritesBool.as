/**
 * @version v1
 * @summary Operator [] reads and writes bool elements, including const aliases.
 * @topic Containers
 *
 * IndexAccessReadsAndWritesBool
 */
/**
 * @begin IndexAccessReadsAndWritesBool
 * @summary Operator [] reads and writes bool elements, including const aliases.
 * @topic Containers
 */
bool IndexAccessReadsAndWritesBool()
{
	TArray<bool> Values;
	Values.Add(false);
	Values.Add(true);
	bool& Mutable = Values[0];
	bool bFirstIsFalse = Mutable == false;
	Mutable = true;
	bool AfterWrite = Values[0];
	bool Last = Values[1];
	const TArray<bool> ConstValues = Values;
	const bool& ConstFirst = ConstValues[0];
	return bFirstIsFalse && AfterWrite == true && Last == true && ConstFirst == true;
}
/** @end */
