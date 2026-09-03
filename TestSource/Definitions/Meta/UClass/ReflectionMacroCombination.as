/**
 * UENUM, USTRUCT, delegate and UCLASS meta combined. After BeginPlay, RuntimeResult
 * is 42 (20+21+1 Ready). Blocked skips the Ready bonus. Empty Amount and Bonus on
 * Blocked is 0.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.ReflectionMacroCombination
 * @Harness UClass
 * @Tag Definitions.Meta.ReflectionMacroCombination
 * @Provenance Theme: Definitions.Meta. WorldStory: UENUM / USTRUCT / delegate / UCLASS meta combined.
 * @Provenance C++: AngelscriptCoverageMacrosTests.cpp::ReflectionMacroCombination
 * @Provenance Oracle after BeginPlay: RuntimeResult is 42 (20+21+1 Ready). Extra: Blocked skips +1; empty Amount/Bonus on Blocked is 0.
 * @Provenance FixtureIsolated. Keep Payload / State / RuntimeResult names.
 */

UENUM(BlueprintType)
enum ECoverageMacroCombinedState
{
	Ready UMETA(DisplayName="Ready State"),
	Blocked UMETA(Hidden)
}

/**
 * A combined-macro signal carrying an integer payload.
 *
 * @Covers Meta.ReflectionMacroCombination
 * @Inputs the payload Value
 * @Return nothing when broadcast
 * @Param Value the integer payload
 */
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

	/**
	 * Apply Amount plus Bonus, adding 1 when State is Ready.
	 *
	 * @Kind Observe
	 * @Covers Meta.ReflectionMacroCombination
	 * @Inputs a bonus
	 * @Return RuntimeResult
	 * @Param Bonus added to Payload.Amount
	 */
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

	/**
	 * WorldStory: BeginPlay sets Amount 20 and applies bonus 21.
	 *
	 * @Kind WorldStory
	 * @Covers Meta.ReflectionMacroCombination
	 * @Inputs none
	 * @Return RuntimeResult 42 after play
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Payload.Amount = 20;
		ApplyPayload(21);
	}

	/**
	 * Observe RuntimeResult after BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Meta.ReflectionMacroCombination
	 * @Inputs none
	 * @Return RuntimeResult
	 */
	UFUNCTION()
	int ApplyAfterBeginPlay()
	{
		return RuntimeResult;
	}

	/**
	 * Observe that Blocked with empty Amount and Bonus yields 0.
	 *
	 * @Kind Observe
	 * @Covers Meta.ReflectionMacroCombination
	 * @Inputs none
	 * @Return 0
	 * @Boundary empty Amount and Bonus on Blocked
	 */
	UFUNCTION()
	int EmptyAmountBoundary()
	{
		Payload.Amount = 0;
		State = ECoverageMacroCombinedState::Blocked;
		return ApplyPayload(0);
	}

	/**
	 * Observe that Blocked skips the Ready bonus.
	 *
	 * @Kind Observe
	 * @Covers Meta.ReflectionMacroCombination
	 * @Inputs none
	 * @Return 41
	 * @Boundary Blocked skips +1
	 */
	UFUNCTION()
	int BlockedSkipsReadyBonus()
	{
		Payload.Amount = 20;
		State = ECoverageMacroCombinedState::Blocked;
		return ApplyPayload(21);
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Meta.ReflectionMacroCombination
	 * @Inputs an unset actor handle
	 * @Return 1 when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptyDefaultIsNull()
	{
		ACoverageMacrosCombinedActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
