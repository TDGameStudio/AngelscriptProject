// Purpose: Observe Reset clearing contained struct storage, including
// repeated Reset on an already empty receiver.
// AS-facing API: void InstancedStruct.Reset();
// Inputs: A seeded Make from payload Value=7, then Reset, then a second
// Reset on the same receiver as the repeated-call case.
// Expected observations: Seeded IsValid is true. After Reset, IsValid is
// false and GetScriptStruct is null. A second Reset remains invalid.
// Boundary/ownership: Reset releases the contained struct bytes. It does not
// require a prior value; Reset on empty is a no-op cleanup.

USTRUCT()
struct FTSInstancedStructResetPayload
{
	UPROPERTY()
	int32 Value = 7;
}

namespace TS_FInstancedStruct_MutationAndLifecycle_01
{
	bool Observe_Reset_Nominal()
	{
		FTSInstancedStructResetPayload Payload;
		Payload.Value = 7;
		FInstancedStruct Instanced = FInstancedStruct::Make(Payload);
		bool bSeededValid = Instanced.IsValid();
		Instanced.Reset();
		bool bResetInvalid = !Instanced.IsValid();
		UScriptStruct AfterResetType = Instanced.GetScriptStruct();
		Instanced.Reset();
		return bSeededValid &&
			bResetInvalid &&
			AfterResetType is null &&
			!Instanced.IsValid();
	}
}
