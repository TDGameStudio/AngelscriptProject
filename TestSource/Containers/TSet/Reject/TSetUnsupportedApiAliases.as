/**
 * Unbound UE TSet aliases have no matching signatures.
 *
 * @Theme Containers.TSet
 * @Subject TSet.UnsupportedApiAliases
 * @Harness CompileReject
 * @Tag Containers.TSet.TSetUnsupportedApiAliases
 * @Kind CompileReject
 * @Covers TSet.Unsupported
 * @Inputs Find / FindOrAdd / Reserve / Shrink / Sort / Array / GetMaxIndex / Union / Intersect / Difference / Includes
 * @Return does not compile
 * @Namespace TSetTest
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
