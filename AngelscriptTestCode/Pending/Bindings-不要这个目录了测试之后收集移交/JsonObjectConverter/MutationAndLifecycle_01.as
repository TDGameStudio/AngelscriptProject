/**
 * @version v1
 * @summary Observe AppendUStructToJsonObjectString appending serialized struct JSON onto an existing string. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe AppendUStructToJsonObjectString appending serialized struct JSON onto an existing string. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// "prefix:", default flags, Indent 0, PrettyPrint true then false, and an
// empty struct as the empty state.
// Expected observations: Success returns true and InOutString grows past the
// prefix. Repeated append grows further. PrettyPrint false still contains
// the field names.
// Boundary/ownership: InOutString is mutated in place. The struct is read,
// not consumed.

USTRUCT()
struct FTSJsonConverterPayload
{
	UPROPERTY()
	FString Name = "Alice";

	UPROPERTY()
	int Score = 7;
}

namespace TS_JsonObjectConverter_MutationAndLifecycle_01
{
	bool Observe_AppendUStructToJsonObjectString_Nominal()
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
}
/** @end */
