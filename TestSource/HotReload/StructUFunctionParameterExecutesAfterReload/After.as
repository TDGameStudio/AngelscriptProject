// Theme: HotReload VersionPair After. UFunction struct parameter payload.
// C++: AngelscriptHotReloadStructTests.cpp::StructUFunctionParameterExecutesAfterReload ReloadV2Source
// Retained: FHotReloadStructFunctionPayload; UHotReloadStructFunctionReceiver; ConsumePayload; RunPayload names.
// Replaced: struct object; Bonus; ConsumePayload returns Value+Bonus; RunPayload writes 20 and 22.
// Oracle After: RunPayload == 42; struct reload broadcast once.
// FixtureIsolated. Load Before then After in recorded order.

USTRUCT()
struct FHotReloadStructFunctionPayload
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	int Bonus = 0;
}

UCLASS()
class UHotReloadStructFunctionReceiver : UObject
{
	/** Consumes the payload and returns the derived value. */
	UFUNCTION()
	int ConsumePayload(const FHotReloadStructFunctionPayload&in Payload)
	{
		return Payload.Value + Payload.Bonus;
	}
}

/** Runs the payload path and returns the observed result. */
int RunPayload(UHotReloadStructFunctionReceiver Receiver)
{
	FHotReloadStructFunctionPayload Payload;
	Payload.Value = 20;
	Payload.Bonus = 22;
	return Receiver.ConsumePayload(Payload);
}
