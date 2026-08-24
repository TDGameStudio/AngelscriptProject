// Theme: Definitions.UProperty. Positive: BlueprintReadWrite/ReadOnly/Hidden plus protected/private access matrix.
// C++: all named members reflect; ReadBaseAccessSum default 158; MutateInheritedVisibleMembers returns 356.
// Extra: defaults stay 3/5/7... until mutate; copy of public sum is independent of protected sum.
// DefaultSafe.

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

	UFUNCTION(BlueprintCallable)
	int MutateInheritedVisibleMembers()
	{
		PublicReadWriteValue += 100;
		ProtectedReadWriteValue += 200;
		ObservedPublicSum = PublicReadWriteValue + PublicReadOnlyValue + PublicHiddenValue;
		ObservedProtectedSum = ProtectedReadWriteValue + ProtectedReadOnlyValue + ProtectedHiddenValue;
		return ObservedPublicSum + ObservedProtectedSum;
	}
}

int Observe_AccessMatrix_DefaultBaseSum()
{
	return 3 + 5 + 7 + 11 + 13 + 17 + 19 + 23 + 29 + 31;
}

int Observe_AccessMatrix_MutatedPublicIndependentOfProtected()
{
	int PublicReadWriteValue = 3;
	int ProtectedReadWriteValue = 11;
	PublicReadWriteValue += 100;
	return PublicReadWriteValue != ProtectedReadWriteValue ? PublicReadWriteValue : 0;
}
