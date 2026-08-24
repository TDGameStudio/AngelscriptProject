// Purpose: Observe FInstancedStruct::Make wrapping a concrete struct value.
// AS-facing API: FInstancedStruct FInstancedStruct::Make(const ?&in Struct);
// Inputs: A payload with Value=7 as the explicit argument, and a default
// payload Value=0 as the empty-state argument.
// Expected observations: Make of Value=7 is valid and Get reads 7. Make of
// a default payload is still valid because a struct value is present.
// Boundary/ownership: Make copies the argument into new instanced storage.
// The source payload remains an independent local.

USTRUCT()
struct FTSInstancedStructMakePayload
{
	UPROPERTY()
	int32 Value = 0;
}

namespace TS_FInstancedStruct_NamespaceAndGlobalFunctions_01
{
	bool Observe_Make_Nominal()
	{
		FTSInstancedStructMakePayload Seeded;
		Seeded.Value = 7;
		FInstancedStruct FromSeeded = FInstancedStruct::Make(Seeded);
		const FTSInstancedStructMakePayload& Got = FromSeeded.Get(FTSInstancedStructMakePayload);

		FTSInstancedStructMakePayload DefaultPayload;
		FInstancedStruct FromDefault = FInstancedStruct::Make(DefaultPayload);
		const FTSInstancedStructMakePayload& DefaultGot = FromDefault.Get(FTSInstancedStructMakePayload);
		return FromSeeded.IsValid() &&
			Got.Value == 7 &&
			Seeded.Value == 7 &&
			FromDefault.IsValid() &&
			DefaultGot.Value == 0;
	}
}
