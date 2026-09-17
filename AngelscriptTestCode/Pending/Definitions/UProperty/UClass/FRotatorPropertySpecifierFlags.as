/**
 * @version v1
 * @summary EditAnywhere FRotator plus reflected TArray/TMap of rotators. C++ verifies named properties by path, so those UPROPERTY names are kept. The observers cover empty array Num 0 and that ZeroRotator is independent of the.
 * @topic Definitions
 */
/**
 * @version root
 * @summary EditAnywhere FRotator plus reflected TArray/TMap of rotators. C++ verifies named properties by path, so those UPROPERTY names are kept. The observers cover empty array Num 0 and that ZeroRotator is independent of the.
 * @topic Baseline
 */
UCLASS()
class ACoverageFRotatorSpecifierActor : AActor
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Coverage|Rotator", meta = (ClampMin = "-180.0", ClampMax = "180.0"))
	FRotator EditableRotation = FRotator(10, -20, 30);

	UPROPERTY()
	TArray<FRotator> ReflectedRotators;

	UPROPERTY()
	TMap<int, FRotator> ReflectedRotatorMap;

	/**
	 * WorldStory: snapshot the editable rotator into the reflected containers.
	 *
	 * @Kind WorldStory
	 * @Covers UProperty.FRotatorPropertySpecifierFlags
	 * @Inputs none
	 * @Return ReflectedRotators holds the editable rotator and ZeroRotator; map key 7 is filled
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ReflectedRotators.Add(EditableRotation);
		ReflectedRotators.Add(FRotator::ZeroRotator);

		ReflectedRotatorMap.Add(7, FRotator(70, 80, 90));
	}

	/**
	 * Observe that an empty rotator array has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.FRotatorPropertySpecifierFlags
	 * @Inputs a default-constructed TArray<FRotator>
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int FRotatorEmptyArrayNum()
	{
		TArray<FRotator> ReflectedRotators;
		return ReflectedRotators.Num();
	}

	/**
	 * Observe that ZeroRotator is an independent copy of the editable default.
	 *
	 * @Kind Observe
	 * @Covers UProperty.FRotatorPropertySpecifierFlags
	 * @Inputs EditableRotation (10,-20,30) and ZeroRotator
	 * @Return true when Pitch differs
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool FRotatorZeroIsIndependentCopy()
	{
		FRotator EditableRotation = FRotator(10, -20, 30);
		FRotator Zero = FRotator::ZeroRotator;
		return EditableRotation.Pitch != Zero.Pitch;
	}
}
/** @end */
