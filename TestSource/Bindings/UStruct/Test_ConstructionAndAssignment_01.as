// Purpose: Observe assignment of eligible reflected structs, including a
// native FVector and a script USTRUCT.
// AS-facing API: Value = Other;
// Inputs: FVector Other (1,2,3), default FVector Value, FTSBindStructPayload
// with Count 4 and Label "Payload", a copy assigned from that payload, and
// later mutation of Other/Source.
// Expected observations: Assigned FVector equals Other then stays (1,2,3)
// after Other is mutated. Assigned payload copies Count and Label, then stays
// independent when Source is mutated.
// Boundary/ownership: Assignment copies struct bytes through native ops or
// the reflective fallback. Other is not moved from.

USTRUCT()
struct FTSBindStructPayload
{
	UPROPERTY()
	int Count = 4;

	UPROPERTY()
	FString Label = "Payload";
}

namespace TS_UStruct_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FVector Value;
		FVector Other(1.0, 2.0, 3.0);
		Value = Other;
		Other.X = 9.0;

		FTSBindStructPayload Payload;
		FTSBindStructPayload Source;
		Source.Count = 4;
		Source.Label = "Payload";
		Payload = Source;
		Source.Count = -1;
		Source.Label = "Changed";

		FTSBindStructPayload Empty;
		Empty = FTSBindStructPayload();

		return Value.X == 1.0 && Value.Y == 2.0 && Value.Z == 3.0 && Other.X == 9.0 && Payload.Count == 4 && Payload.Label == "Payload" && Empty.Count == 4 && Empty.Label == "Payload";
	}
}
