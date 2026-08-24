// Purpose: Observe typed Get/GetMutable aliasing, deprecated copy-out Get,
// Contains, IsValid, and GetScriptStruct on empty and seeded receivers.
// AS-facing API: const FScriptStructWildcard& InstancedStruct.Get(const UScriptStruct StructType) const;
// FScriptStructWildcard& InstancedStruct.GetMutable(const UScriptStruct StructType);
// void InstancedStruct.Get(?&out Struct) const;
// bool InstancedStruct.Contains(const UScriptStruct StructType) const;
// bool InstancedStruct.IsValid() const;
// UScriptStruct InstancedStruct.GetScriptStruct() const;
// Inputs: Default-empty FInstancedStruct, Make from payload Value=7, the
// payload type as StructType, and a second payload type as the mismatch key.
// Expected observations: Empty IsValid is false and Contains is false.
// Seeded Get returns Value 7. GetMutable write-through is visible on a later
// Get. Deprecated Get copies into the out struct. GetScriptStruct is non-null
// only when valid.
// Boundary/ownership: Get/GetMutable return aliases into instanced storage
// and throw on empty or type mismatch. That throw is the expected-failure
// path. Deprecated Get copies rather than aliasing.

USTRUCT()
struct FTSInstancedStructQueryPayload
{
	UPROPERTY()
	int32 Value = 7;
}

USTRUCT()
struct FTSInstancedStructQueryOtherPayload
{
	UPROPERTY()
	int32 Other = 1;
}

namespace TS_FInstancedStruct_Queries_01
{
	bool Observe_Get_Nominal()
	{
		FTSInstancedStructQueryPayload Payload;
		Payload.Value = 7;
		FInstancedStruct Instanced = FInstancedStruct::Make(Payload);
		const FTSInstancedStructQueryPayload& Got = Instanced.Get(FTSInstancedStructQueryPayload);

		FTSInstancedStructQueryPayload OutCopy;
		OutCopy.Value = -1;
		int32 OutBefore = OutCopy.Value;
		Instanced.Get(OutCopy);
		int32 OutAfter = OutCopy.Value;
		return Got.Value == 7 && OutBefore == -1 && OutAfter == 7;
	}

	bool Observe_GetMutable_Nominal()
	{
		FTSInstancedStructQueryPayload Payload;
		Payload.Value = 7;
		FInstancedStruct Instanced = FInstancedStruct::Make(Payload);
		FTSInstancedStructQueryPayload& Mutable = Instanced.GetMutable(FTSInstancedStructQueryPayload);
		int32 Before = Mutable.Value;
		Mutable.Value = 11;
		const FTSInstancedStructQueryPayload& AfterAlias = Instanced.Get(FTSInstancedStructQueryPayload);
		return Before == 7 && AfterAlias.Value == 11;
	}

	bool Observe_Contains_Nominal()
	{
		FInstancedStruct Empty;
		FTSInstancedStructQueryPayload Payload;
		FInstancedStruct Instanced = FInstancedStruct::Make(Payload);
		UScriptStruct StructType = Instanced.GetScriptStruct();
		FTSInstancedStructQueryOtherPayload Other;
		FInstancedStruct OtherInstanced = FInstancedStruct::Make(Other);
		UScriptStruct OtherType = OtherInstanced.GetScriptStruct();
		return !Empty.Contains(StructType) && Instanced.Contains(StructType) && !Instanced.Contains(OtherType);
	}

	bool Observe_IsValid_Nominal()
	{
		FInstancedStruct Empty;
		FTSInstancedStructQueryPayload Payload;
		FInstancedStruct Instanced = FInstancedStruct::Make(Payload);
		return !Empty.IsValid() && Instanced.IsValid();
	}

	bool Observe_GetScriptStruct_Nominal()
	{
		FInstancedStruct Empty;
		UScriptStruct EmptyType = Empty.GetScriptStruct();
		FTSInstancedStructQueryPayload Payload;
		FInstancedStruct Instanced = FInstancedStruct::Make(Payload);
		UScriptStruct SeededType = Instanced.GetScriptStruct();
		return EmptyType is null && SeededType != nullptr;
	}

	void ExerciseExpectedFailure()
	{
		FTSInstancedStructQueryPayload Payload;
		FInstancedStruct Instanced = FInstancedStruct::Make(Payload);
		const FTSInstancedStructQueryOtherPayload& Mismatch = Instanced.Get(FTSInstancedStructQueryOtherPayload);
	}
}
