/**
 * An ordinary UFUNCTION may call a method marked `unsafe_during_construction`.
 * C++ CompileSafetyScript expects this module to compile. Entry() returns 7.
 * Keep Value and Entry.
 *
 * @Theme Feature.Default
 * @Subject Default.UnsafeDuringConstructionOrdinaryCall
 * @Harness UClass
 * @Tag Feature.Default.UnsafeDuringConstructionOrdinaryCall
 * @Provenance Theme: Feature.Default. CSV NegativeDiagnostic. C++ CompileSafetyScript(..., bExpectedCompile=true)
 * @Provenance so an ordinary UFUNCTION may call unsafe_during_construction.
 * @Provenance C++: AngelscriptDefaultStatementSafetyTests.cpp::UnsafeDuringConstructionRejectsDefaultAndConstructor
 * @Provenance Module TEXT("ASUnsafeOrdinary"). Oracle: Entry() returns 7. Extra: Value default 0; UnsafeValue()==7.
 * @Provenance Keep Value/Entry. DefaultSafe.
 */

UCLASS()
class UUnsafeOrdinaryTarget : UObject
{
	UPROPERTY()
	int Value = 0;

	/**
	 * A method that is unsafe during construction but legal from an ordinary UFUNCTION.
	 *
	 * @Covers Default.UnsafeDuringConstructionOrdinaryCall
	 * @Inputs none
	 * @Return 7
	 */
	int UnsafeValue() unsafe_during_construction
	{
		return 7;
	}

	/**
	 * Calls the unsafe method from an ordinary UFUNCTION.
	 *
	 * @Covers Default.UnsafeDuringConstructionOrdinaryCall
	 * @Inputs none
	 * @Return 7
	 */
	UFUNCTION()
	int Entry()
	{
		return UnsafeValue();
	}

	/**
	 * Observe that an unset handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers Default.UnsafeDuringConstructionOrdinaryCall
	 * @Inputs a freshly declared handle
	 * @Return true when the unset handle is null
	 * @Boundary unset handle
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		UUnsafeOrdinaryTarget Target;
		return Target == nullptr;
	}

	/**
	 * Observe that Value stays at its inline zero.
	 *
	 * @Kind Observe
	 * @Covers Default.UnsafeDuringConstructionOrdinaryCall
	 * @Inputs a freshly constructed object
	 * @Return 0
	 */
	UFUNCTION()
	int ValueDefaultZero()
	{
		return Value;
	}

	/**
	 * Observe that Entry() returns the unsafe method's result.
	 *
	 * @Kind Observe
	 * @Covers Default.UnsafeDuringConstructionOrdinaryCall
	 * @Inputs a freshly constructed object
	 * @Return 7
	 */
	UFUNCTION()
	int EntryNominal()
	{
		return Entry();
	}

	/**
	 * Observe that calling UnsafeValue directly also returns 7.
	 *
	 * @Kind Observe
	 * @Covers Default.UnsafeDuringConstructionOrdinaryCall
	 * @Inputs a freshly constructed object
	 * @Return 7
	 */
	UFUNCTION()
	int UnsafeValueDirect()
	{
		return UnsafeValue();
	}
}
