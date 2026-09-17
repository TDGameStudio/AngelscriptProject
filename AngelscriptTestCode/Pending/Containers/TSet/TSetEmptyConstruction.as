/**
 * @version v1
 * @summary Default-constructed TSet<T> is empty; read-only / no-op ops do not crash. int is the canonical case (all five invariants). Other shapes repeat Key-depth entries with a type suffix. Do not invent new function names.
 * @topic Containers
 */
/**
 * @version root
 * @summary Default-constructed TSet<T> is empty; read-only / no-op ops do not crash. int is the canonical case (all five invariants). Other shapes repeat Key-depth entries with a type suffix. Do not invent new function names.
 * @topic Baseline
 */
UCLASS()
class UTSetEmptyConstructionObject : UObject
{
}

namespace TSetTest
{
	/**
	 * Default-constructed TSet is empty.
	 *
	 * @Kind Observe
	 * @Covers TSet.IsEmpty
	 * @Inputs Default-constructed TSet<int>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty()
	{
		TSet<int> Values;
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * Empty TSet does not contain the probe value.
	 *
	 * @Kind Observe
	 * @Covers TSet.Contains
	 * @Inputs Default-constructed TSet<int>; Contains(42)
	 * @Return true when Contains(42) is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain()
	{
		TSet<int> Values;
		return !Values.Contains(42);
	}

	/**
	 * Copy of an empty TSet is also empty.
	 *
	 * @Kind Observe
	 * @Covers TSet copy
	 * @Inputs Default-constructed TSet<int>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty()
	{
		TSet<int> Values;
		TSet<int> Copy = Values;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}

	/**
	 * Two empty TSets compare equal.
	 *
	 * @Kind Observe
	 * @Covers TSet.opEquals
	 * @Inputs Two default-constructed TSet<int>
	 * @Return true when Left == Right
	 */
	UFUNCTION()
	bool EmptyEqualsEmpty()
	{
		TSet<int> Left;
		TSet<int> Right;
		return Left == Right;
	}

	/**
	 * Append of an empty TSet onto an empty TSet is a no-op.
	 *
	 * @Kind Observe
	 * @Covers TSet.Append
	 * @Inputs Default-constructed TSet<int>; Append(empty set)
	 * @Return true when Num() == 0 after Append
	 */
	UFUNCTION()
	bool EmptyAppendIsNoOp()
	{
		TSet<int> Values;
		TSet<int> Empty;
		Values.Append(Empty);
		return Values.Num() == 0;
	}


	/**
	 * Default-constructed TSet is empty.
	 *
	 * @Kind Observe
	 * @Covers TSet.IsEmpty
	 * @Inputs Default-constructed TSet<FString>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty_FString()
	{
		TSet<FString> Values;
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * Empty TSet does not contain the probe value.
	 *
	 * @Kind Observe
	 * @Covers TSet.Contains
	 * @Inputs Default-constructed TSet<FString>; Contains("hello")
	 * @Return true when Contains("hello") is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain_FString()
	{
		TSet<FString> Values;
		return !Values.Contains("hello");
	}

	/**
	 * Copy of an empty TSet is also empty.
	 *
	 * @Kind Observe
	 * @Covers TSet copy
	 * @Inputs Default-constructed TSet<FString>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty_FString()
	{
		TSet<FString> Values;
		TSet<FString> Copy = Values;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}


	/**
	 * Default-constructed TSet is empty.
	 *
	 * @Kind Observe
	 * @Covers TSet.IsEmpty
	 * @Inputs Default-constructed TSet<FName>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty_FName()
	{
		TSet<FName> Values;
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * Empty TSet does not contain the probe value.
	 *
	 * @Kind Observe
	 * @Covers TSet.Contains
	 * @Inputs Default-constructed TSet<FName>; Contains(n"Probe")
	 * @Return true when Contains(n"Probe") is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain_FName()
	{
		TSet<FName> Values;
		return !Values.Contains(n"Probe");
	}

	/**
	 * Copy of an empty TSet is also empty.
	 *
	 * @Kind Observe
	 * @Covers TSet copy
	 * @Inputs Default-constructed TSet<FName>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty_FName()
	{
		TSet<FName> Values;
		TSet<FName> Copy = Values;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}


	/**
	 * Default-constructed TSet is empty.
	 *
	 * @Kind Observe
	 * @Covers TSet.IsEmpty
	 * @Inputs Default-constructed TSet<bool>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty_bool()
	{
		TSet<bool> Values;
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * Empty TSet does not contain the probe value.
	 *
	 * @Kind Observe
	 * @Covers TSet.Contains
	 * @Inputs Default-constructed TSet<bool>; Contains(true)
	 * @Return true when Contains(true) is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain_bool()
	{
		TSet<bool> Values;
		return !Values.Contains(true);
	}

	/**
	 * Copy of an empty TSet is also empty.
	 *
	 * @Kind Observe
	 * @Covers TSet copy
	 * @Inputs Default-constructed TSet<bool>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty_bool()
	{
		TSet<bool> Values;
		TSet<bool> Copy = Values;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}


	/**
	 * Default-constructed TSet is empty.
	 *
	 * @Kind Observe
	 * @Covers TSet.IsEmpty
	 * @Inputs Default-constructed TSet<FVector>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty_FVector()
	{
		TSet<FVector> Values;
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * Empty TSet does not contain the probe value.
	 *
	 * @Kind Observe
	 * @Covers TSet.Contains
	 * @Inputs Default-constructed TSet<FVector>; Contains(FVector(1.0f, 2.0f, 3.0f))
	 * @Return true when Contains(FVector(1.0f, 2.0f, 3.0f)) is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain_FVector()
	{
		TSet<FVector> Values;
		return !Values.Contains(FVector(1.0f, 2.0f, 3.0f));
	}

	/**
	 * Copy of an empty TSet is also empty.
	 *
	 * @Kind Observe
	 * @Covers TSet copy
	 * @Inputs Default-constructed TSet<FVector>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty_FVector()
	{
		TSet<FVector> Values;
		TSet<FVector> Copy = Values;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}


	/**
	 * Default-constructed TSet is empty.
	 *
	 * @Kind Observe
	 * @Covers TSet.IsEmpty
	 * @Inputs Default-constructed TSet<UObject>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty_UObject()
	{
		TSet<UObject> Values;
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * Empty TSet does not contain the probe value.
	 *
	 * @Kind Observe
	 * @Covers TSet.Contains
	 * @Inputs Default-constructed TSet<UObject>; Contains(nullptr)
	 * @Return true when Contains(nullptr) is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain_UObject()
	{
		TSet<UObject> Values;
		return !Values.Contains(nullptr);
	}

	/**
	 * Copy of an empty TSet is also empty.
	 *
	 * @Kind Observe
	 * @Covers TSet copy
	 * @Inputs Default-constructed TSet<UObject>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty_UObject()
	{
		TSet<UObject> Values;
		TSet<UObject> Copy = Values;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}


}
/** @end */
