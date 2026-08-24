// Purpose: Observe UStructToJsonObjectString and JsonObjectStringToUStruct
// round-trip, including default pretty-print omission. Each function returns
// the exact comparison for the C++ runner.
// AS-facing API: bool FJsonObjectConverter::UStructToJsonObjectString(...);
// bool FJsonObjectConverter::JsonObjectStringToUStruct(...);
// Inputs: Payload Name=Alice Score=7, empty Result, CheckFlags/SkipFlags 0,
// malformed JSON as the failure path, and PrettyPrint false.
// Expected observations: Serialize succeeds and Result contains Alice.
// Deserialize into a default struct restores Score 7. Malformed JSON returns
// false.
// Boundary/ownership: Result/MaybeStruct are writebacks. The converter does
// not take ownership of the struct.

USTRUCT()
struct FTSJsonConverterRoundTripPayload
{
	UPROPERTY()
	FString Name = "Alice";

	UPROPERTY()
	int Score = 7;
}

namespace TS_JsonObjectConverter_NamespaceAndGlobalFunctions_01
{
	bool Observe_UStructToJsonObjectString_Nominal()
	{
		FTSJsonConverterRoundTripPayload Payload;
		FString Result;
		bool bSerialized = FJsonObjectConverter::UStructToJsonObjectString(Payload, Result);
		FString Compact;
		FJsonObjectConverter::UStructToJsonObjectString(Payload, Compact, 0, 0, 0, false);
		return bSerialized && Result.Contains("Alice") && Compact.Contains("Score");
	}

	bool Observe_JsonObjectStringToUStruct_Nominal()
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
}
