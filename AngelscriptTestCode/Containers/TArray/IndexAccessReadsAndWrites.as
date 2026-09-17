/**
 * @version v1
 * @summary Operator [] reads and writes elements, including const and FName aliases.
 * @topic Containers
 *
 * IndexAccessReadsAndWrites
 */
/**
 * @begin IndexAccessReadsAndWrites
 * @summary Operator [] reads and writes elements, including const and FName aliases.
 * @topic Containers
 */
bool IndexAccessReadsAndWrites()
{
	TArray<int32> Values;
	Values.Add(1);
	Values.Add(2);
	int32& Mutable = Values[0];
	bool bFirstIsOne = Mutable == 1;
	Mutable = 9;
	int32 AfterWrite = Values[0];
	int32 Last = Values[1];
	const TArray<int32> ConstValues = Values;
	const int32& ConstFirst = ConstValues[0];
	TArray<FName> Names;
	Names.Add(n"Alpha");
	FName& NameAlias = Names[0];
	return bFirstIsOne && AfterWrite == 9 && Last == 2 && ConstFirst == 9 && NameAlias == n"Alpha";
}
/** @end */
