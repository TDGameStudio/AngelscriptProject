/**
 * @version v1
 * @summary HotReload VersionPair Before. UFunction struct parameter payload.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. UFunction struct parameter payload.
 * @topic Baseline
 */
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
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. UFunction struct parameter payload.
 * @topic HotReload
 */
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
/** @end */
