/**
 * @version v1
 * @summary BlueprintAuthorityOnly compiles and is callable. AuthorityAction exists so C++ can check FUNC_BlueprintAuthorityOnly. A nullptr handle is the empty vector, and a second call remains a no-op.
 * @topic Definitions
 */
/**
 * @version root
 * @summary BlueprintAuthorityOnly compiles and is callable. AuthorityAction exists so C++ can check FUNC_BlueprintAuthorityOnly. A nullptr handle is the empty vector, and a second call remains a no-op.
 * @topic Baseline
 */
UCLASS()
class UAuthorityOnlyTestObj : UObject
{
	/**
	 * BlueprintAuthorityOnly UFUNCTION used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(BlueprintAuthorityOnly)
	void AuthorityAction()
	{
	}

	/**
	 * Observe that AuthorityAction can be invoked once.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs AuthorityAction()
	 * @Return 1
	 */
	UFUNCTION()
	int AuthorityActionEmptyCall()
	{
		AuthorityAction();
		return 1;
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs UAuthorityOnlyTestObj Object = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		UAuthorityOnlyTestObj Object = nullptr;
		return Object == nullptr;
	}

	/**
	 * Observe that a second AuthorityAction call remains a no-op.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs two AuthorityAction calls
	 * @Return 1
	 */
	UFUNCTION()
	int AuthorityActionRepeatCall()
	{
		AuthorityAction();
		AuthorityAction();
		return 1;
	}
}
/** @end */
