/**
 * @version v1
 * @summary JsonObjectConverter host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic JsonObjectConverter
 *
 * append-u-struct-to-json-object-string
 * u-struct-to-json-object-string
 * json-object-string-to-u-struct
 */
/**
 * @begin append-u-struct-to-json-object-string
 * @summary not consumed.
 * @topic Unreal
 */
/**
 * @function ObserveAppendUStructToJsonObjectStringNominal
 * @summary not consumed.
 * @covers JsonObjectConverter.append-u-struct-to-json-object-string
 * @inputs JsonObjectConverter values exercised by this observe
 * @return true when the observe comparison holds
 */
USTRUCT()
struct FTSJsonConverterPayload
{
	UPROPERTY()
	FString Name = "Alice";

	UPROPERTY()
	int Score = 7;
}

bool ObserveAppendUStructToJsonObjectStringNominal()
{
	FTSJsonConverterPayload Payload;
	FString InOutString = "prefix:";
	bool bAppended = FJsonObjectConverter::AppendUStructToJsonObjectString(Payload, InOutString);
	int AfterFirst = InOutString.Len();
	FJsonObjectConverter::AppendUStructToJsonObjectString(Payload, InOutString, 0, 0, 0, false);
	int AfterSecond = InOutString.Len();
	FTSJsonConverterPayload EmptyPayload;
	EmptyPayload.Name = "";
	EmptyPayload.Score = 0;
	FString EmptyOut = "";
	bool bEmptyAppended = FJsonObjectConverter::AppendUStructToJsonObjectString(EmptyPayload, EmptyOut);
	return bAppended && AfterFirst > 7 && InOutString.Contains("Alice") && AfterSecond > AfterFirst && bEmptyAppended;
}
/** @end */
/**
 * @begin u-struct-to-json-object-string
 * @summary not take ownership of the struct.
 * @topic Unreal
 */
/**
 * @function ObserveUStructToJsonObjectStringNominal
 * @summary not take ownership of the struct.
 * @covers JsonObjectConverter.u-struct-to-json-object-string
 * @inputs JsonObjectConverter values exercised by this observe
 * @return true when the observe comparison holds
 */
USTRUCT()
struct FTSJsonConverterRoundTripPayload
{
	UPROPERTY()
	FString Name = "Alice";

	UPROPERTY()
	int Score = 7;
}

bool ObserveUStructToJsonObjectStringNominal()
{
	FTSJsonConverterRoundTripPayload Payload;
	FString Result;
	bool bSerialized = FJsonObjectConverter::UStructToJsonObjectString(Payload, Result);
	FString Compact;
	FJsonObjectConverter::UStructToJsonObjectString(Payload, Compact, 0, 0, 0, false);
	return bSerialized && Result.Contains("Alice") && Compact.Contains("Score");
}
/** @end */
/**
 * @begin json-object-string-to-u-struct
 * @summary not take ownership of the struct.
 * @topic Unreal
 */
/**
 * @function ObserveJsonObjectStringToUStructNominal
 * @summary not take ownership of the struct.
 * @covers JsonObjectConverter.json-object-string-to-u-struct
 * @inputs JsonObjectConverter values exercised by this observe
 * @return true when the observe comparison holds
 */
USTRUCT()
struct FTSJsonConverterRoundTripPayload
{
	UPROPERTY()
	FString Name = "Alice";

	UPROPERTY()
	int Score = 7;
}

bool ObserveJsonObjectStringToUStructNominal()
{
	FTSJsonConverterRoundTripPayload Payload;
	FString Json;
	FJsonObjectConverter::UStructToJsonObjectString(Payload, Json, 0, 0, 0, false);
	FTSJsonConverterRoundTripPayload Restored;
	Restored.Name = "";
	Restored.Score = 0;
	bool bDeserialized = FJsonObjectConverter::JsonObjectStringToUStruct(Json, Restored);
	FTSJsonConverterRoundTripPayload Failed;
	bool bMalformed = FJsonObjectConverter::JsonObjectStringToUStruct("{", Failed);
	return bDeserialized && Restored.Name == "Alice" && Restored.Score == 7 && !bMalformed;
}
/** @end */
