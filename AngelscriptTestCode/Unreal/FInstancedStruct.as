/**
 * @version v1
 * @summary FInstancedStruct host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FInstancedStruct
 *
 * parameter
 * initialize-as
 * reset
 * make
 * equality
 * get
 * get-mutable
 * contains
 * is-valid
 * get-script-struct
 */
/**
 * @begin parameter
 * @summary storage.
 * @topic Unreal
 */
/**
 * @function ObserveParameterNominal
 * @summary storage.
 * @covers FInstancedStruct.parameter
 * @inputs FInstancedStruct values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveParameterNominal()
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
/** @end */
/**
 * @begin initialize-as
 * @summary storage.
 * @topic Unreal
 */
/**
 * @function ObserveInitializeAsNominal
 * @summary storage.
 * @covers FInstancedStruct.initialize-as
 * @inputs FInstancedStruct values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveInitializeAsNominal()
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
/** @end */
/**
 * @begin reset
 * @summary require a prior value.
 * @topic Unreal
 */
/**
 * @function ObserveResetNominal
 * @summary require a prior value.
 * @covers FInstancedStruct.reset
 * @inputs FInstancedStruct values exercised by this observe
 * @return true when the observe comparison holds
 */
USTRUCT()
struct FTSInstancedStructResetPayload
{
	UPROPERTY()
	int32 Value = 7;
}

bool ObserveResetNominal()
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
/** @end */
/**
 * @begin make
 * @summary The source payload remains an independent local.
 * @topic Unreal
 */
/**
 * @function ObserveMakeNominal
 * @summary The source payload remains an independent local.
 * @covers FInstancedStruct.make
 * @inputs FInstancedStruct values exercised by this observe
 * @return true when the observe comparison holds
 */
USTRUCT()
struct FTSInstancedStructMakePayload
{
	UPROPERTY()
	int32 Value = 0;
}

bool ObserveMakeNominal()
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
/** @end */
/**
 * @begin equality
 * @summary contained UScriptStruct type and bytes, not of wrapper identity.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary contained UScriptStruct type and bytes, not of wrapper identity.
 * @covers FInstancedStruct.equality
 * @inputs FInstancedStruct values exercised by this observe
 * @return true when the observe comparison holds
 */
USTRUCT()
struct FTSInstancedStructOpPayload
{
	UPROPERTY()
	int32 Value = 7;
}

bool ObserveEqualityNominal()
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
/** @end */
/**
 * @begin get
 * @summary path.
 * @topic Unreal
 */
/**
 * @function ObserveGetNominal
 * @summary path.
 * @covers FInstancedStruct.get
 * @inputs FInstancedStruct values exercised by this observe
 * @return true when the observe comparison holds
 */
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

bool ObserveGetNominal()
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
/** @end */
/**
 * @begin get-mutable
 * @summary path.
 * @topic Unreal
 */
/**
 * @function ObserveGetMutableNominal
 * @summary path.
 * @covers FInstancedStruct.get-mutable
 * @inputs FInstancedStruct values exercised by this observe
 * @return true when the observe comparison holds
 */
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

bool ObserveGetMutableNominal()
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
/** @end */
/**
 * @begin contains
 * @summary path.
 * @topic Unreal
 */
/**
 * @function ObserveContainsNominal
 * @summary path.
 * @covers FInstancedStruct.contains
 * @inputs FInstancedStruct values exercised by this observe
 * @return true when the observe comparison holds
 */
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

bool ObserveContainsNominal()
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
/** @end */
/**
 * @begin is-valid
 * @summary path.
 * @topic Unreal
 */
/**
 * @function ObserveIsValidNominal
 * @summary path.
 * @covers FInstancedStruct.is-valid
 * @inputs FInstancedStruct values exercised by this observe
 * @return true when the observe comparison holds
 */
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

bool ObserveIsValidNominal()
{
	FInstancedStruct Empty;
	FTSInstancedStructQueryPayload Payload;
	FInstancedStruct Instanced = FInstancedStruct::Make(Payload);
	return !Empty.IsValid() && Instanced.IsValid();
}
/** @end */
/**
 * @begin get-script-struct
 * @summary path.
 * @topic Unreal
 */
/**
 * @function ObserveGetScriptStructNominal
 * @summary path.
 * @covers FInstancedStruct.get-script-struct
 * @inputs FInstancedStruct values exercised by this observe
 * @return true when the observe comparison holds
 */
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

bool ObserveGetScriptStructNominal()
{
	FInstancedStruct Empty;
	UScriptStruct EmptyType = Empty.GetScriptStruct();
	FTSInstancedStructQueryPayload Payload;
	FInstancedStruct Instanced = FInstancedStruct::Make(Payload);
	UScriptStruct SeededType = Instanced.GetScriptStruct();
	return EmptyType is null && SeededType != nullptr;
}
/** @end */
