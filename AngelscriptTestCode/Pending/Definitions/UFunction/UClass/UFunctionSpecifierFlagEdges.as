/**
 * @version v1
 * @summary NotBlueprintCallable, AuthorityOnly, Protected, Deprecated, and a const getter. HiddenAction writes StoredValue, AuthorityProtectedAction writes Value+10, and ReadStoredValue returns it. StoredValue defaults to 0, a.
 * @topic Definitions
 */
/**
 * @version root
 * @summary NotBlueprintCallable, AuthorityOnly, Protected, Deprecated, and a const getter. HiddenAction writes StoredValue, AuthorityProtectedAction writes Value+10, and ReadStoredValue returns it. StoredValue defaults to 0, a.
 * @topic Baseline
 */
UCLASS()
class ACoverageUFunctionFlagEdgeActor : AActor
{
	UPROPERTY()
	int StoredValue = 0;

	/**
	 * NotBlueprintCallable action that writes StoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value New StoredValue
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION(NotBlueprintCallable)
	void HiddenAction(int Value)
	{
		StoredValue = Value;
	}

	/**
	 * Authority-only protected deprecated action that writes Value+10.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Value added to 10
	 * @Inputs Value
	 * @Return void; StoredValue becomes Value + 10
	 */
	UFUNCTION(BlueprintCallable, BlueprintAuthorityOnly, BlueprintProtected, meta=(DeprecatedFunction, DeprecationMessage="Use ReplacementAction"))
	void AuthorityProtectedAction(int Value)
	{
		StoredValue = Value + 10;
	}

	/**
	 * Const getter for StoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs StoredValue
	 * @Return the current StoredValue
	 */
	UFUNCTION(BlueprintCallable)
	int ReadStoredValue() const
	{
		return StoredValue;
	}

	/**
	 * Observe the default StoredValue of 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a freshly constructed actor
	 * @Return true when ReadStoredValue and StoredValue are 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool EmptyDefaultIsZero()
	{
		if (ReadStoredValue() != 0)
		{
			return false;
		}
		return StoredValue == 0;
	}

	/**
	 * Observe HiddenAction at the zero write.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs HiddenAction(0)
	 * @Return true when ReadStoredValue is 0
	 * @Boundary zero write
	 */
	UFUNCTION()
	bool ZeroHiddenWrite()
	{
		HiddenAction(0);
		return ReadStoredValue() == 0;
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ACoverageUFunctionFlagEdgeActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageUFunctionFlagEdgeActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe HiddenAction(5) then AuthorityProtectedAction(5) writing 15.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs HiddenAction(5) then AuthorityProtectedAction(5)
	 * @Return true when StoredValue is 15
	 */
	UFUNCTION()
	bool AuthorityBoundary()
	{
		HiddenAction(5);
		if (ReadStoredValue() != 5)
		{
			return false;
		}
		AuthorityProtectedAction(5);
		if (ReadStoredValue() != 15)
		{
			return false;
		}
		return StoredValue == 15;
	}
}
/** @end */
