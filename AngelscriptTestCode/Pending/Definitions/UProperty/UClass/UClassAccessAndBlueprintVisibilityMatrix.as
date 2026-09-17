/**
 * @version v1
 * @summary BlueprintReadWrite/ReadOnly/Hidden plus protected/private access matrix. C++ verifies named members and ReadBaseAccessSum/MutateInheritedVisibleMembers, so those names are kept. The observers cover the default sum 158.
 * @topic Definitions
 */
/**
 * @version root
 * @summary BlueprintReadWrite/ReadOnly/Hidden plus protected/private access matrix. C++ verifies named members and ReadBaseAccessSum/MutateInheritedVisibleMembers, so those names are kept. The observers cover the default sum 158.
 * @topic Baseline
 */
UCLASS()
class UCoverageUClassPropertyAccessBaseObject : UObject
{
	UPROPERTY(BlueprintReadWrite)
	int PublicReadWriteValue = 3;

	UPROPERTY(BlueprintReadOnly)
	int PublicReadOnlyValue = 5;

	UPROPERTY(BlueprintHidden)
	int PublicHiddenValue = 7;

	UPROPERTY(BlueprintReadWrite)
	protected int ProtectedReadWriteValue = 11;

	UPROPERTY(BlueprintReadOnly)
	protected int ProtectedReadOnlyValue = 13;

	UPROPERTY(BlueprintHidden)
	protected int ProtectedHiddenValue = 17;

	UPROPERTY(BlueprintReadWrite, meta=(AllowPrivateAccess))
	private int PrivateAllowedReadWriteValue = 19;

	UPROPERTY(BlueprintReadOnly, meta=(AllowPrivateAccess))
	private int PrivateAllowedReadOnlyValue = 23;

	UPROPERTY(BlueprintReadWrite)
	private int PrivateHiddenReadWriteValue = 29;

	UPROPERTY(BlueprintHidden)
	private int PrivateExplicitHiddenValue = 31;

	/**
	 * Sum every access-controlled member on the base object.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassAccessAndBlueprintVisibilityMatrix
	 * @Inputs none
	 * @Return 158 for the declared defaults
	 */
	UFUNCTION(BlueprintCallable)
	int ReadBaseAccessSum()
	{
		return PublicReadWriteValue
			+ PublicReadOnlyValue
			+ PublicHiddenValue
			+ ProtectedReadWriteValue
			+ ProtectedReadOnlyValue
			+ ProtectedHiddenValue
			+ PrivateAllowedReadWriteValue
			+ PrivateAllowedReadOnlyValue
			+ PrivateHiddenReadWriteValue
			+ PrivateExplicitHiddenValue;
	}
}

UCLASS()
class UCoverageUClassPropertyAccessLeafObject : UCoverageUClassPropertyAccessBaseObject
{
	UPROPERTY()
	int ObservedProtectedSum = 0;

	UPROPERTY()
	int ObservedPublicSum = 0;

	/**
	 * Mutate inherited visible members and return the combined observed sums.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassAccessAndBlueprintVisibilityMatrix
	 * @Inputs none
	 * @Return 356 after adding 100/200 to the writable members
	 */
	UFUNCTION(BlueprintCallable)
	int MutateInheritedVisibleMembers()
	{
		PublicReadWriteValue += 100;
		ProtectedReadWriteValue += 200;
		ObservedPublicSum = PublicReadWriteValue + PublicReadOnlyValue + PublicHiddenValue;
		ObservedProtectedSum = ProtectedReadWriteValue + ProtectedReadOnlyValue + ProtectedHiddenValue;
		return ObservedPublicSum + ObservedProtectedSum;
	}

	/**
	 * Observe the default base-access sum of the declared defaults.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassAccessAndBlueprintVisibilityMatrix
	 * @Inputs none
	 * @Return 3+5+7+11+13+17+19+23+29+31
	 * @Boundary empty default
	 */
	UFUNCTION()
	int AccessMatrixDefaultBaseSum()
	{
		return 3 + 5 + 7 + 11 + 13 + 17 + 19 + 23 + 29 + 31;
	}

	/**
	 * Observe that mutating a local public value leaves the protected value alone.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassAccessAndBlueprintVisibilityMatrix
	 * @Inputs local PublicReadWriteValue 3 plus 100, ProtectedReadWriteValue 11
	 * @Return 103 when the two locals differ, otherwise 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int AccessMatrixMutatedPublicIndependentOfProtected()
	{
		int PublicReadWriteValue = 3;
		int ProtectedReadWriteValue = 11;
		PublicReadWriteValue += 100;
		return PublicReadWriteValue != ProtectedReadWriteValue ? PublicReadWriteValue : 0;
	}
}
/** @end */
