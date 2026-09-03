/**
 * An explicit preprocessor context selects which of two class definitions is
 * live: with CONTEXT_ENABLED set, only the first carrier is detected, and the
 * one in the #else branch never exists. The observers check the live carrier's
 * default and that calling its function leaves that default untouched.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.ExplicitContextControlsFlagsAndDefaults
 * @Harness UClass
 * @Tag Language.Preprocessor.ExplicitContextControlsFlagsAndDefaults
 * @Provenance C++: AngelscriptPreprocessorContextTests.cpp::ExplicitContextControlsFlagsAndDefaults
 * @Provenance lines 33-54; Context.PreprocessorFlags CONTEXT_ENABLED=true.
 * @Provenance sha256=effa82863492dfc277c727e87b4d7aaca599ddb95e27490bdabc2bdea95cc085.
 * @Provenance Oracle: UExplicitContextCarrier is detected; ImplicitProperty default 0;
 * @Provenance ImplicitFunction is callable and does not mutate ImplicitProperty.
 * @Provenance Extra: UWrongContextCarrier / WrongProperty exist only in the skipped branch.
 * @Provenance DefaultSafe. Keep ImplicitFunction, ImplicitProperty, UWrongContextCarrier.
 */

#if CONTEXT_ENABLED
UCLASS()
class UExplicitContextCarrier : UObject
{
	/**
	 * A no-op method on the live carrier.
	 *
	 * @Covers Preprocessor.Conditionals
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void ImplicitFunction()
	{
	}

	UPROPERTY()
	int ImplicitProperty;

	/**
	 * Observe that the property defaults to zero.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Conditionals
	 * @Inputs a freshly constructed carrier
	 * @Return true when ImplicitProperty is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ImplicitPropertyDefaultsToZero()
	{
		return ImplicitProperty == 0;
	}

	/**
	 * Observe that calling the function leaves the property untouched.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Conditionals
	 * @Inputs ImplicitFunction() then ImplicitProperty
	 * @Return true when the property is still 0
	 * @Boundary no mutation
	 */
	UFUNCTION()
	bool ImplicitFunctionDoesNotMutateProperty()
	{
		ImplicitFunction();
		return ImplicitProperty == 0;
	}
}
#else
UCLASS()
class UWrongContextCarrier : UObject
{
	UPROPERTY()
	int WrongProperty;
}
#endif
