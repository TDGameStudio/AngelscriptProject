// Theme: Definitions.Meta. WorldStory: UENUM / USTRUCT / delegate / UCLASS meta combined.
// C++: AngelscriptCoverageMacrosTests.cpp::ReflectionMacroCombination
// Oracle after BeginPlay: RuntimeResult is 42 (20+21+1 Ready). Extra: Blocked skips +1; empty Amount/Bonus on Blocked is 0.
// FixtureIsolated. Keep Payload / State / RuntimeResult names.

UENUM(BlueprintType)
enum ECoverageMacroCombinedState
{
	Ready UMETA(DisplayName="Ready State"),
	Blocked UMETA(Hidden)
}

delegate void FCoverageMacroCombinedSignal(int Value);

USTRUCT(BlueprintType)
struct FCoverageMacroCombinedPayload
{
	UPROPERTY()
	int Amount = 0;
}

UCLASS(BlueprintType, meta=(CoverageCombinedKey="CombinedValue"))
class ACoverageMacrosCombinedActor : AActor
{
	UPROPERTY(meta=(CoveragePropertyKey="CombinedProperty"))
	FCoverageMacroCombinedPayload Payload;

	UPROPERTY()
	ECoverageMacroCombinedState State = ECoverageMacroCombinedState::Ready;

	UPROPERTY()
	FCoverageMacroCombinedSignal Signal;

	UPROPERTY()
	int RuntimeResult = 0;

	UFUNCTION(BlueprintCallable, meta=(CoverageFunctionKey="CombinedFunction"))
	int ApplyPayload(int Bonus)
	{
		RuntimeResult = Payload.Amount + Bonus;
		if (State == ECoverageMacroCombinedState::Ready)
		{
			RuntimeResult += 1;
		}
		return RuntimeResult;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Payload.Amount = 20;
		ApplyPayload(21);
	}
}

int Observe_CombinedMacros_ApplyAfterBeginPlay(ACoverageMacrosCombinedActor Actor)
{
	return Actor.RuntimeResult;
}

int Observe_CombinedMacros_EmptyAmountBoundary(ACoverageMacrosCombinedActor Actor)
{
	Actor.Payload.Amount = 0;
	Actor.State = ECoverageMacroCombinedState::Blocked;
	return Actor.ApplyPayload(0);
}

int Observe_CombinedMacros_BlockedSkipsReadyBonus(ACoverageMacrosCombinedActor Actor)
{
	Actor.Payload.Amount = 20;
	Actor.State = ECoverageMacroCombinedState::Blocked;
	return Actor.ApplyPayload(21);
}

int Observe_CombinedMacros_EmptyDefaultIsNull()
{
	ACoverageMacrosCombinedActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
