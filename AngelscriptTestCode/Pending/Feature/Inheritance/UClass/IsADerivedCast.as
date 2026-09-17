/**
 * @version v1
 * @summary IsA/Cast After of the reload pair. C++ AnalyzeReloadFromMemory succeeds and requires a full reload. VerifyBaseCast returns 1 on a derived instance and 0 when the source is null.
 * @topic Feature
 */
/**
 * @version root
 * @summary IsA/Cast After of the reload pair. C++ AnalyzeReloadFromMemory succeeds and requires a full reload. VerifyBaseCast returns 1 on a derived instance and 0 when the source is null.
 * @topic Baseline
 */
UCLASS()
class ATestInheritanceIsABase : AActor
{
}

UCLASS()
class ATestInheritanceIsADerived : ATestInheritanceIsABase
{
	/**
	 * Cast this derived instance to the base class and report whether it succeeded.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.IsADerivedCast
	 * @Inputs Cast<ATestInheritanceIsABase>(this)
	 * @Return 1 when the base handle is non-null, otherwise 0
	 */
	UFUNCTION()
	int VerifyBaseCast()
	{
		ATestInheritanceIsABase BaseRef = Cast<ATestInheritanceIsABase>(this);
		return BaseRef == null ? 0 : 1;
	}

	/**
	 * Observe that casting a null source to the base class stays 0.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.IsADerivedCast
	 * @Inputs Cast<ATestInheritanceIsABase>(nullptr)
	 * @Return 0 when the result is null
	 * @Boundary null source
	 */
	UFUNCTION()
	int NullCastBoundary()
	{
		ATestInheritanceIsABase BaseRef = Cast<ATestInheritanceIsABase>(nullptr);
		return BaseRef == null ? 0 : 1;
	}
}
/** @end */
