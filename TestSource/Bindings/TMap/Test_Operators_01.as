// Purpose: Observe TMap subscript aliasing and map equality by contents.
// Each function returns the exact comparison for the C++ runner.
// AS-facing API: Map[Key]; ConstMap[Key]; Map == Other;
// Inputs: Map with Alpha->1 and Beta->2, an identical Other, an empty map,
// and ConstMap copied from Map.
// Expected observations: Map[Alpha] is 1. Writing through the mutable
// reference is visible on a later read. Const subscript reads 1. Identical
// maps compare true; empty vs populated is false.
// Boundary/ownership: Mutable and const [] throw when Key is absent; Add or
// FindOrAdd inserts. Equality compares key/value contents, not iteration
// order.

namespace TS_TMap_Operators_01
{
	bool Observe_Index_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		Map.Add(n"Beta", 2);
		int32& Mutable = Map[n"Alpha"];
		bool bAlphaIsOne = Mutable == 1;
		Mutable = 9;
		int32 AfterWrite = Map[n"Alpha"];
		const TMap<FName, int32> ConstMap = Map;
		const int32& ConstValue = ConstMap[n"Alpha"];
		TMap<FString, int32> StringMap;
		StringMap.Add("Key", 7);
		int32 StringValue = StringMap["Key"];
		return bAlphaIsOne && AfterWrite == 9 && ConstValue == 9 && StringValue == 7;
	}

	bool Observe_Equality_Nominal()
	{
		TMap<FName, int32> Left;
		Left.Add(n"Alpha", 1);
		Left.Add(n"Beta", 2);
		TMap<FName, int32> Right;
		Right.Add(n"Beta", 2);
		Right.Add(n"Alpha", 1);
		TMap<FName, int32> EmptyLeft;
		TMap<FName, int32> EmptyRight;
		TMap<FName, int32> Different;
		Different.Add(n"Alpha", 1);
		return Left == Right && EmptyLeft == EmptyRight && !(Left == EmptyLeft) && !(Left == Different);
	}
}
