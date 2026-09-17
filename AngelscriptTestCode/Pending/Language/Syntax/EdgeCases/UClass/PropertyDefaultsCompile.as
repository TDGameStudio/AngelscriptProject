/**
 * @version v1
 * @summary CDO default overrides: a `default` statement replacing an inline initializer, and another filling a Tags array. The CDO values must survive into fresh instances and stay independent across them.
 * @topic Language
 */
/**
 * @version root
 * @summary CDO default overrides: a `default` statement replacing an inline initializer, and another filling a Tags array. The CDO values must survive into fresh instances and stay independent across them.
 * @topic Baseline
 */
UCLASS()
class UCompilerDefaultsCarrier : UObject
{
	UPROPERTY()
	int Score = 7;

	UPROPERTY()
	TArray<FName> Tags;

	/**
	 * Overrides the inline initializer with 21.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the CDO Score becomes 21
	 */
	default Score = 21;

	/**
	 * Fills the CDO Tags array with one entry.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the CDO Tags gain n"Alpha"
	 */
	default Tags.Add(n"Alpha");

	/**
	 * Observe the CDO default overrides.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed carrier
	 * @Return true when Score is 21 and Tags holds Alpha
	 */
	UFUNCTION()
	bool PropertyDefaultsNominal()
	{
		if (Score != 21)
		{
			return false;
		}

		if (!Tags.Contains(n"Alpha"))
		{
			return false;
		}

		return Tags.Num() >= 1;
	}

	/**
	 * Observe that instances do not share the defaults.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this carrier mutated, compared against a second carrier
	 * @Return true when the mutation is local and the other keeps defaults
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool PropertyDefaultsSecondInstanceIndependent()
	{
		UCompilerDefaultsCarrier Second =
			Cast<UCompilerDefaultsCarrier>(
				NewObject(GetTransientPackage(), UCompilerDefaultsCarrier::StaticClass(), n"CompilerDefaultsCarrierSecond"));
		if (Second == nullptr)
		{
			throw("Test_PropertyDefaultsCompile setup: NewObject returned null");
		}

		Score = 0;
		Tags.Empty();

		if (Score != 0)
		{
			return false;
		}

		if (Tags.Num() != 0)
		{
			return false;
		}

		if (Second.Score != 21)
		{
			return false;
		}

		return Second.Tags.Contains(n"Alpha");
	}
}
/** @end */
