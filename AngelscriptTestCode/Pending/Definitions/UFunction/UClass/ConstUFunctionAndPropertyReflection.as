/**
 * @version v1
 * @summary A const UFUNCTION plus a const &in parameter. After BeginPlay, Observed is 21 + (21+8) == 50 and Value stays 21. AddConstParam(0) is the empty addend, a nullptr actor is the empty handle, and mutating Observed does not.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A const UFUNCTION plus a const &in parameter. After BeginPlay, Observed is 21 + (21+8) == 50 and Value stays 21. AddConstParam(0) is the empty addend, a nullptr actor is the empty handle, and mutating Observed does not.
 * @topic Baseline
 */
UCLASS()
class ACoverageConstActor : AActor
{
	UPROPERTY()
	int Value = 21;

	UPROPERTY()
	int Observed = 0;

	/**
	 * Const getter for Value.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs Value
	 * @Return the current Value
	 */
	UFUNCTION()
	int GetValue() const
	{
		return Value;
	}

	/**
	 * Add a const &in Amount to Value without writing members.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Amount Addend received as const int&in
	 * @Inputs Amount
	 * @Return Value + Amount
	 */
	UFUNCTION()
	int AddConstParam(const int&in Amount) const
	{
		return Value + Amount;
	}

	/**
	 * Record GetValue plus AddConstParam(8) into Observed at play time.
	 *
	 * @Kind WorldStory
	 * @Covers UFunction.Specifier
	 * @Inputs Bonus 8
	 * @Return void; Observed becomes GetValue() + AddConstParam(8)
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		const int Bonus = 8;
		Observed = GetValue() + AddConstParam(Bonus);
	}

	/**
	 * Observe the BeginPlay oracle: Observed 50 and Value 21.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs BeginPlay()
	 * @Return true when Observed is 50 and Value is 21
	 */
	UFUNCTION()
	bool BeginPlayOracle()
	{
		BeginPlay();
		if (Observed != 50)
		{
			return false;
		}
		return Value == 21;
	}

	/**
	 * Observe AddConstParam(0) as the empty addend.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs AddConstParam(0)
	 * @Return true when the sum is 21 and GetValue is 21
	 * @Boundary zero addend
	 */
	UFUNCTION()
	bool AddZeroEmptyAddend()
	{
		if (AddConstParam(0) != 21)
		{
			return false;
		}
		return GetValue() == 21;
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ACoverageConstActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageConstActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that clearing this instance leaves another at Value 21.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Other Second actor that must stay at the default
	 * @Inputs Observed and Value set to 0 on this compared against Other
	 * @Return true when Other.Value and Other.GetValue stay 21
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool ConstStateIsIndependentAcrossInstances(ACoverageConstActor Other)
	{
		Observed = 0;
		Value = 0;
		if (Other.Value != 21)
		{
			return false;
		}
		return Other.GetValue() == 21;
	}
}
/** @end */
