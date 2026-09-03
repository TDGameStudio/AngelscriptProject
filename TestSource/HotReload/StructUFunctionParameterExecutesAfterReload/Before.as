// Theme: HotReload VersionPair Before. UFunction struct parameter payload.
// C++: AngelscriptHotReloadStructTests.cpp::StructUFunctionParameterExecutesAfterReload ReloadV1Source
// Retained on old function: ConsumePayload parameter type is the old struct (Value only).
// Replaced in After: struct object; Bonus field; ConsumePayload Value+Bonus; RunPayload 12 -> 20+22.
// Oracle Before: RunPayload == 12.
// FixtureIsolated. Load Before then After in recorded order.

USTRUCT()
struct FHotReloadStructFunctionPayload
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class UHotReloadStructFunctionReceiver : UObject
{
	/** Consumes the payload and returns the derived value. */
	UFUNCTION()
	int ConsumePayload(const FHotReloadStructFunctionPayload&in Payload)
	{
		return Payload.Value;
	}
}

/** Runs the payload path and returns the observed result. */
int RunPayload(UHotReloadStructFunctionReceiver Receiver)
{
	FHotReloadStructFunctionPayload Payload;
	Payload.Value = 12;
	return Receiver.ConsumePayload(Payload);
}
