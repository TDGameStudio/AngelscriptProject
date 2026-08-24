// Purpose: Observe implicit FAngelscriptAnyStructParameter wrapping and
// InitializeAs from a concrete value or a UScriptStruct type.
// AS-facing API: FAngelscriptAnyStructParameter Parameter(const ?&in Struct);
// FAngelscriptAnyStructParameter Parameter(const FInstancedStruct& Struct);
// void InstancedStruct.InitializeAs(const ?&in Struct);
// void InstancedStruct.InitializeAs(const UScriptStruct StructType);
// Inputs: Payload Value=7, an empty FInstancedStruct, Make of that payload,
// and GetScriptStruct as the type-only InitializeAs argument.
// Expected observations: Implicit wrap from a struct and from an instanced
// struct both yield a valid InstancedStruct. InitializeAs from a value stores
// 7. InitializeAs from a type is valid with a default payload value.
// Boundary/ownership: Any-struct wrapping copies into FInstancedStruct
// storage. Type-only InitializeAs default-constructs that UScriptStruct.

USTRUCT()
struct FTSInstancedStructBehaviorPayload
{
	UPROPERTY()
	int32 Value = 0;
}

namespace TS_FInstancedStruct_Behavior_01
{
	bool Observe_Parameter_Nominal()
	{
		FTSInstancedStructBehaviorPayload Payload;
		Payload.Value = 7;
		FAngelscriptAnyStructParameter FromStruct = Payload;
		const FTSInstancedStructBehaviorPayload& FromStructGot = FromStruct.InstancedStruct.Get(FTSInstancedStructBehaviorPayload);

		FInstancedStruct Instanced = FInstancedStruct::Make(Payload);
		FAngelscriptAnyStructParameter FromInstanced = Instanced;
		const FTSInstancedStructBehaviorPayload& FromInstancedGot = FromInstanced.InstancedStruct.Get(FTSInstancedStructBehaviorPayload);
		return FromStruct.InstancedStruct.IsValid() &&
			FromStructGot.Value == 7 &&
			FromInstanced.InstancedStruct.IsValid() &&
			FromInstancedGot.Value == 7;
	}

	bool Observe_InitializeAs_Nominal()
	{
		FTSInstancedStructBehaviorPayload Payload;
		Payload.Value = 7;
		FInstancedStruct FromValue;
		FromValue.InitializeAs(Payload);
		const FTSInstancedStructBehaviorPayload& GotValue = FromValue.Get(FTSInstancedStructBehaviorPayload);

		FInstancedStruct Typed = FInstancedStruct::Make(Payload);
		UScriptStruct StructType = Typed.GetScriptStruct();
		FInstancedStruct FromType;
		FromType.InitializeAs(StructType);
		UScriptStruct AfterType = FromType.GetScriptStruct();
		const FTSInstancedStructBehaviorPayload& Defaulted = FromType.Get(FTSInstancedStructBehaviorPayload);
		return FromValue.IsValid() &&
			GotValue.Value == 7 &&
			FromType.IsValid() &&
			AfterType == StructType &&
			Defaulted.Value == 0;
	}
}
