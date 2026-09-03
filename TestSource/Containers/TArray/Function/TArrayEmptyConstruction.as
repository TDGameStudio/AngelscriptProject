/**
 * Default-constructed TArray<T> is empty; read-only / no-op ops do not crash.
 * int is the canonical case (all six invariants). Other types repeat Key-depth
 * entries with a type suffix. A generator substitutes the placeholders below;
 * do not invent new function names.
 *
 * @Theme Containers.TArray
 * @Subject TArray.EmptyConstruction
 * @Harness Function
 * @Tag Containers.TArray.TArrayEmptyConstruction
 * @Namespace TArrayTest
 * @GenerateTemplate EmptyConstruction
 * @GenerateParam T element type
 * @GenerateParam Suffix empty for int; otherwise _ plus the type token (float -> _float)
 * @GenerateParam Default probe value for Contains / FindIndex
 * @GenerateParam Depth Full (six invariants) or Key (three invariants)
 *
 * Invariants:
 *   1. DefaultConstructedIsEmpty  Num() == 0 && IsEmpty()
 *   2. EmptyDoesNotContain        !Contains(${Default})
 *   3. EmptyFindIndexIsMinusOne   FindIndex(${Default}) == -1
 *   4. EmptySortKeepsEmpty        Sort(); Num() still 0
 *   5. EmptyCopyIsEmpty           copy is empty
 *   6. EmptyAppendIsNoOp          Append(empty); Num() still 0
 *
 * Depth:
 *   Full — all six. Use for value types when Sort / FindIndex apply.
 *   Key  — 1, 2, 5 only. Default for a new type; also the handwritten
 *          non-int instances in this file.
 *   Skip invariants 3 and 4 for UObject / AActor handles (Sort / FindIndex
 *   differ). Never instantiate this template as TArray<TArray<T>>.
 *
 * Instantiated here:
 *   int     Suffix=         Default=42                            Depth=Full
 *   float   Suffix=_float   Default=42.0f                         Depth=Key
 *   bool    Suffix=_bool    Default=true                          Depth=Key
 *   FString Suffix=_FString Default="hello"                       Depth=Key
 *   FVector Suffix=_FVector Default=FVector(1.0f, 2.0f, 3.0f)     Depth=Key
 *   UObject Suffix=_UObject Default=nullptr                       Depth=Key
 *   AActor  Suffix=_AActor  Default=nullptr                       Depth=Key
 *
 * Generate: copy the int UFUNCTION Doxygen blocks (Kind/Covers/Inputs/Return),
 * add ${Suffix} to the function name, replace int with ${T} and 42 with
 * ${Default}. Do not nest comment closers in this header.
 *
 *   UFUNCTION() bool DefaultConstructedIsEmpty${Suffix}()
 *   { TArray<${T}> Array; return Array.Num() == 0 && Array.IsEmpty(); }
 *
 *   UFUNCTION() bool EmptyDoesNotContain${Suffix}()
 *   { TArray<${T}> Array; return !Array.Contains(${Default}); }
 *
 *   UFUNCTION() bool EmptyCopyIsEmpty${Suffix}()
 *   { TArray<${T}> Array; TArray<${T}> Copy = Array;
 *     return Copy.Num() == 0 && Copy.IsEmpty(); }
 *
 * Generate Full — also emit:
 *
 *   UFUNCTION() bool EmptyFindIndexIsMinusOne${Suffix}()
 *   { TArray<${T}> Array; return Array.FindIndex(${Default}) == -1; }
 *
 *   UFUNCTION() bool EmptySortKeepsEmpty${Suffix}()
 *   { TArray<${T}> Array; Array.Sort(); return Array.Num() == 0; }
 *
 *   UFUNCTION() bool EmptyAppendIsNoOp${Suffix}()
 *   { TArray<${T}> Array; TArray<${T}> Empty; Array.Append(Empty);
 *     return Array.Num() == 0; }
 *
 * Example: T=double Suffix=_double Default=42.0 Depth=Key emits
 * DefaultConstructedIsEmpty_double / EmptyDoesNotContain_double /
 * EmptyCopyIsEmpty_double. Split files, if used later, are
 * TArrayEmptyConstruction_${T}.Generate.as and must not be hand-edited.
 */

namespace TArrayTest
{
	/**
	 * Default-constructed TArray is empty.
	 *
	 * @Kind Observe
	 * @Covers TArray.IsEmpty
	 * @Inputs Default-constructed TArray<int>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty()
	{
		TArray<int> Array;
		return Array.Num() == 0 && Array.IsEmpty();
	}

	/**
	 * Empty TArray does not contain the probe value.
	 *
	 * @Kind Observe
	 * @Covers TArray.Contains
	 * @Inputs Default-constructed TArray<int>; Contains(42)
	 * @Return true when Contains(42) is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain()
	{
		TArray<int> Array;
		return !Array.Contains(42);
	}

	/**
	 * Empty TArray FindIndex of the probe is -1.
	 *
	 * @Kind Observe
	 * @Covers TArray.FindIndex
	 * @Inputs Default-constructed TArray<int>; FindIndex(42)
	 * @Return true when FindIndex(42) == -1
	 */
	UFUNCTION()
	bool EmptyFindIndexIsMinusOne()
	{
		TArray<int> Array;
		return Array.FindIndex(42) == -1;
	}

	/**
	 * Sort on an empty TArray does not crash and leaves Num 0.
	 *
	 * @Kind Observe
	 * @Covers TArray.Sort
	 * @Inputs Default-constructed TArray<int>; Sort()
	 * @Return true when Num() == 0 after Sort
	 */
	UFUNCTION()
	bool EmptySortKeepsEmpty()
	{
		TArray<int> Array;
		Array.Sort();
		return Array.Num() == 0;
	}

	/**
	 * Copy of an empty TArray is also empty.
	 *
	 * @Kind Observe
	 * @Covers TArray copy
	 * @Inputs Default-constructed TArray<int>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty()
	{
		TArray<int> Array;
		TArray<int> Copy = Array;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}

	/**
	 * Append of an empty TArray onto an empty TArray is a no-op.
	 *
	 * @Kind Observe
	 * @Covers TArray.Append
	 * @Inputs Default-constructed TArray<int>; Append(empty)
	 * @Return true when Num() == 0 after Append
	 */
	UFUNCTION()
	bool EmptyAppendIsNoOp()
	{
		TArray<int> Array;
		TArray<int> Empty;
		Array.Append(Empty);
		return Array.Num() == 0;
	}

	/**
	 * Default-constructed TArray is empty.
	 *
	 * @Kind Observe
	 * @Covers TArray.IsEmpty
	 * @Inputs Default-constructed TArray<float>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty_float()
	{
		TArray<float> Array;
		return Array.Num() == 0 && Array.IsEmpty();
	}

	/**
	 * Empty TArray does not contain the probe value.
	 *
	 * @Kind Observe
	 * @Covers TArray.Contains
	 * @Inputs Default-constructed TArray<float>; Contains(42.0f)
	 * @Return true when Contains(42.0f) is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain_float()
	{
		TArray<float> Array;
		return !Array.Contains(42.0f);
	}

	/**
	 * Copy of an empty TArray is also empty.
	 *
	 * @Kind Observe
	 * @Covers TArray copy
	 * @Inputs Default-constructed TArray<float>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty_float()
	{
		TArray<float> Array;
		TArray<float> Copy = Array;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}

	/**
	 * Default-constructed TArray is empty.
	 *
	 * @Kind Observe
	 * @Covers TArray.IsEmpty
	 * @Inputs Default-constructed TArray<bool>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty_bool()
	{
		TArray<bool> Array;
		return Array.Num() == 0 && Array.IsEmpty();
	}

	/**
	 * Empty TArray does not contain the probe value.
	 *
	 * @Kind Observe
	 * @Covers TArray.Contains
	 * @Inputs Default-constructed TArray<bool>; Contains(true)
	 * @Return true when Contains(true) is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain_bool()
	{
		TArray<bool> Array;
		return !Array.Contains(true);
	}

	/**
	 * Copy of an empty TArray is also empty.
	 *
	 * @Kind Observe
	 * @Covers TArray copy
	 * @Inputs Default-constructed TArray<bool>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty_bool()
	{
		TArray<bool> Array;
		TArray<bool> Copy = Array;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}

	/**
	 * Default-constructed TArray is empty.
	 *
	 * @Kind Observe
	 * @Covers TArray.IsEmpty
	 * @Inputs Default-constructed TArray<FString>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty_FString()
	{
		TArray<FString> Array;
		return Array.Num() == 0 && Array.IsEmpty();
	}

	/**
	 * Empty TArray does not contain the probe value.
	 *
	 * @Kind Observe
	 * @Covers TArray.Contains
	 * @Inputs Default-constructed TArray<FString>; Contains("hello")
	 * @Return true when Contains("hello") is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain_FString()
	{
		TArray<FString> Array;
		return !Array.Contains("hello");
	}

	/**
	 * Copy of an empty TArray is also empty.
	 *
	 * @Kind Observe
	 * @Covers TArray copy
	 * @Inputs Default-constructed TArray<FString>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty_FString()
	{
		TArray<FString> Array;
		TArray<FString> Copy = Array;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}

	/**
	 * Default-constructed TArray is empty.
	 *
	 * @Kind Observe
	 * @Covers TArray.IsEmpty
	 * @Inputs Default-constructed TArray<FVector>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty_FVector()
	{
		TArray<FVector> Array;
		return Array.Num() == 0 && Array.IsEmpty();
	}

	/**
	 * Empty TArray does not contain the probe value.
	 *
	 * @Kind Observe
	 * @Covers TArray.Contains
	 * @Inputs Default-constructed TArray<FVector>; Contains(FVector(1,2,3))
	 * @Return true when Contains(FVector(1.0f, 2.0f, 3.0f)) is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain_FVector()
	{
		TArray<FVector> Array;
		return !Array.Contains(FVector(1.0f, 2.0f, 3.0f));
	}

	/**
	 * Copy of an empty TArray is also empty.
	 *
	 * @Kind Observe
	 * @Covers TArray copy
	 * @Inputs Default-constructed TArray<FVector>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty_FVector()
	{
		TArray<FVector> Array;
		TArray<FVector> Copy = Array;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}

	/**
	 * Default-constructed TArray is empty.
	 *
	 * @Kind Observe
	 * @Covers TArray.IsEmpty
	 * @Inputs Default-constructed TArray<UObject>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty_UObject()
	{
		TArray<UObject> Array;
		return Array.Num() == 0 && Array.IsEmpty();
	}

	/**
	 * Empty TArray does not contain the probe value.
	 *
	 * @Kind Observe
	 * @Covers TArray.Contains
	 * @Inputs Default-constructed TArray<UObject>; Contains(nullptr)
	 * @Return true when Contains(nullptr) is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain_UObject()
	{
		TArray<UObject> Array;
		return !Array.Contains(nullptr);
	}

	/**
	 * Copy of an empty TArray is also empty.
	 *
	 * @Kind Observe
	 * @Covers TArray copy
	 * @Inputs Default-constructed TArray<UObject>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty_UObject()
	{
		TArray<UObject> Array;
		TArray<UObject> Copy = Array;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}

	/**
	 * Default-constructed TArray is empty.
	 *
	 * @Kind Observe
	 * @Covers TArray.IsEmpty
	 * @Inputs Default-constructed TArray<AActor>
	 * @Return true when Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool DefaultConstructedIsEmpty_AActor()
	{
		TArray<AActor> Array;
		return Array.Num() == 0 && Array.IsEmpty();
	}

	/**
	 * Empty TArray does not contain the probe value.
	 *
	 * @Kind Observe
	 * @Covers TArray.Contains
	 * @Inputs Default-constructed TArray<AActor>; Contains(nullptr)
	 * @Return true when Contains(nullptr) is false
	 */
	UFUNCTION()
	bool EmptyDoesNotContain_AActor()
	{
		TArray<AActor> Array;
		return !Array.Contains(nullptr);
	}

	/**
	 * Copy of an empty TArray is also empty.
	 *
	 * @Kind Observe
	 * @Covers TArray copy
	 * @Inputs Default-constructed TArray<AActor>; copy construct
	 * @Return true when the copy has Num() == 0 && IsEmpty()
	 */
	UFUNCTION()
	bool EmptyCopyIsEmpty_AActor()
	{
		TArray<AActor> Array;
		TArray<AActor> Copy = Array;
		return Copy.Num() == 0 && Copy.IsEmpty();
	}
}
