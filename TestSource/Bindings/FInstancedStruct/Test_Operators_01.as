// Purpose: Observe FInstancedStruct equality as a deep compare of contained
// type and value, including empty identity and a differing payload.
// AS-facing API: bool bEqual = Left == Right;
// Inputs: Two empty default instanced structs, two Makes from the same
// payload Value=7, and one Make from Value=9 as the boundary operand.
// Expected observations: Empty == empty is true. Identical payloads compare
// true. Different Value compares false. Equality does not mutate either side.
// Boundary/ownership: Operator== is value-returning. Comparison is of the
// contained UScriptStruct type and bytes, not of wrapper identity.

USTRUCT()
struct FTSInstancedStructOpPayload
{
	UPROPERTY()
	int32 Value = 7;
}

namespace TS_FInstancedStruct_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FInstancedStruct EmptyLeft;
		FInstancedStruct EmptyRight;
		FTSInstancedStructOpPayload Same;
		Same.Value = 7;
		FInstancedStruct Left = FInstancedStruct::Make(Same);
		FInstancedStruct RightSame = FInstancedStruct::Make(Same);
		FTSInstancedStructOpPayload Different;
		Different.Value = 9;
		FInstancedStruct RightDifferent = FInstancedStruct::Make(Different);
		return (EmptyLeft == EmptyRight) &&
			(Left == RightSame) &&
			!(Left == RightDifferent) &&
			Left.IsValid();
	}
}
