/**
 * @version v1
 * @summary Unbound UE TSet aliases have no matching signatures.
 * @topic Containers
 */
/**
 * @version root
 * @summary Unbound UE TSet aliases have no matching signatures.
 * @topic Negative
 */
namespace TSetTest
{
	void Test()
	{
		TSet<int> Values;
		TSet<int> Other;
		Values.Add(1);
		Other.Add(2);
		Values.Find(1);
		Values.FindOrAdd(1);
		Values.Reserve(8);
		Values.Shrink();
		Values.Sort();
		Values.Array();
		Values.GetMaxIndex();
		Values.Union(Other);
		Values.Intersect(Other);
		Values.Difference(Other);
		Values.Includes(Other);
	}
}
/** @end */
