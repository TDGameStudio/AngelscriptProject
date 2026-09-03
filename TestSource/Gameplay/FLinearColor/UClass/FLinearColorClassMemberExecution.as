/**
 * FLinearColor members on a script actor: a reflected editable color, a history array, a
 * raw runtime tint, and methods that run after BeginPlay. C++ verifies the reflected
 * members by path and calls the methods, so those names are part of the contract and are
 * kept verbatim. The observers cover the empty history before BeginPlay and the
 * independence of two instances.
 *
 * @Theme Gameplay.FLinearColor
 * @Subject FLinearColor.ClassMemberExecution
 * @Harness UClass
 * @Tag Gameplay.FLinearColor.FLinearColorClassMemberExecution
 * @Provenance Theme: Gameplay.FLinearColor. WorldStory class-member execution after BeginPlay.
 * @Provenance C++: AngelscriptCoverageFLinearColorPropertyTests.cpp::FLinearColorClassMemberExecution
 * @Provenance Oracle: EditableColor.R 0.2 A 0.8; ColorHistory Num 3; [0].G 0.4; [1].R 1; [2].B 1;
 * @Provenance ReadRuntimeTint Equals (0.2,1,1,1); ReadConstTint Yellow; BlendHistory (1,1,1,1).
 * @Provenance Extra: ColorHistory empty before BeginPlay. FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class ACoverageFLinearColorClassMemberActor : AActor
{
	UPROPERTY()
	FLinearColor EditableColor = FLinearColor(0.2, 0.4, 0.6, 0.8);

	UPROPERTY()
	TArray<FLinearColor> ColorHistory;

	FLinearColor RuntimeTint = FLinearColor::LucBlue;

	/**
	 * WorldStory: BeginPlay clamps the runtime tint against the editable color and records
	 * three history entries.
	 *
	 * @Kind WorldStory
	 * @Covers FLinearColor.ClassMemberExecution
	 * @Inputs none
	 * @Return three history entries and a clamped runtime tint
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FLinearColor LocalTint = EditableColor + RuntimeTint.GetClamped(0.0, 1.0);
		RuntimeTint = LocalTint.GetClamped(0.0, 1.0);
		ColorHistory.Add(EditableColor);
		ColorHistory.Add(ReadConstTint());
		ColorHistory.Add(FLinearColor::MakeFromHex(0xFFFFFFFF, false));
	}

	/**
	 * Read the raw runtime tint.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ClassMemberExecution
	 * @Inputs none
	 * @Return the current RuntimeTint
	 */
	UFUNCTION()
	FLinearColor ReadRuntimeTint()
	{
		return RuntimeTint;
	}

	/**
	 * Read a const local yellow tint.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ClassMemberExecution
	 * @Inputs none
	 * @Return yellow
	 */
	UFUNCTION()
	FLinearColor ReadConstTint()
	{
		const FLinearColor ConstTint = FLinearColor::Yellow;
		return ConstTint;
	}

	/**
	 * Blend every recorded history color and clamp the total.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ClassMemberExecution
	 * @Inputs none
	 * @Return the clamped sum of ColorHistory
	 */
	UFUNCTION()
	FLinearColor BlendHistory()
	{
		FLinearColor Total = FLinearColor::Transparent;
		for (int Index = 0; Index < ColorHistory.Num(); ++Index)
		{
			Total += ColorHistory[Index];
		}
		return Total.GetClamped(0.0, 1.0);
	}

	/**
	 * Observe that the history starts empty and the editable color keeps its default.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ClassMemberExecution
	 * @Inputs none
	 * @Return true when the history is empty and EditableColor reads R 0.2 A 0.8
	 * @Boundary empty history
	 */
	UFUNCTION()
	bool ColorHistoryDefaultEmpty()
	{
		if (ColorHistory.Num() != 0)
		{
			return false;
		}
		if (EditableColor.R != 0.2)
		{
			return false;
		}
		return EditableColor.A == 0.8;
	}

	/**
	 * Observe that BeginPlay records three history colors.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ClassMemberExecution
	 * @Inputs none
	 * @Return true when the history holds three entries with G 0.4, R 1 and B 1
	 */
	UFUNCTION()
	bool ColorHistoryAfterBeginPlay()
	{
		BeginPlay();

		if (ColorHistory.Num() != 3)
		{
			return false;
		}
		if (ColorHistory[0].G != 0.4)
		{
			return false;
		}
		if (ColorHistory[1].R != 1.0)
		{
			return false;
		}
		return ColorHistory[2].B == 1.0;
	}

	/**
	 * Observe that BeginPlay clamps the runtime tint to (0.2, 1, 1, 1).
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ClassMemberExecution
	 * @Inputs none
	 * @Return true when ReadRuntimeTint equals (0.2, 1, 1, 1)
	 */
	UFUNCTION()
	bool ReadRuntimeTintAfterBeginPlay()
	{
		BeginPlay();
		return ReadRuntimeTint().Equals(FLinearColor(0.2, 1.0, 1.0, 1.0), 0.001);
	}

	/**
	 * Observe that the const tint is yellow.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ClassMemberExecution
	 * @Inputs none
	 * @Return true when ReadConstTint equals yellow
	 */
	UFUNCTION()
	bool ReadConstTintNominal()
	{
		return ReadConstTint().Equals(FLinearColor::Yellow, 0.001);
	}

	/**
	 * Observe that blending the history after BeginPlay saturates to white.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ClassMemberExecution
	 * @Inputs none
	 * @Return true when BlendHistory equals (1, 1, 1, 1)
	 */
	UFUNCTION()
	bool BlendHistoryAfterBeginPlay()
	{
		BeginPlay();
		return BlendHistory().Equals(FLinearColor(1.0, 1.0, 1.0, 1.0), 0.001);
	}

	/**
	 * Observe that driving one instance leaves another instance's history empty.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ClassMemberExecution
	 * @Inputs a second actor
	 * @Return true when this instance holds three entries and the other holds none
	 * @Param Second the other actor, expected to stay empty
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageFLinearColorClassMemberActor Second)
	{
		if (Second is null)
		{
			throw("FLinearColorClassMemberExecution setup: required Second is null");
		}
		BeginPlay();

		if (ColorHistory.Num() != 3)
		{
			return false;
		}
		return Second.ColorHistory.Num() == 0;
	}
}
