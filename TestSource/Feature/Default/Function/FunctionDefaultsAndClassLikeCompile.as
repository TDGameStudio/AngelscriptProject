/**
 * Function defaults plus class-like UFUNCTION signatures. Entry() uses both
 * defaults on SumWithDefault and returns 42. The carrier echoes a plain UClass,
 * a TSubclassOf, and a TSoftClassPtr, including the null and empty cases.
 *
 * @Theme Feature.Default
 * @Subject Default.FunctionDefaultsAndClassLikeCompile
 * @Harness Function
 * @Tag Feature.Default.FunctionDefaultsAndClassLikeCompile
 * @Namespace DefaultTest
 * @Provenance Theme: Feature.Default. Positive function defaults plus class-like UFUNCTION signatures.
 * @Provenance C++: AngelscriptCompilerEndToEndTests.cpp::FunctionDefaultsAndClassLikeCompile
 * @Provenance ExecuteIntFunction Entry() == 42. EchoPlainClass / EchoActorClass / EchoSoftActorClass exist.
 * @Provenance Extra: SumWithDefault(0, 0) == 0; SumWithDefault(21) == 42; null/empty class echoes.
 * @Provenance DefaultSafe.
 */

UCLASS()
class UCompilerFunctionCarrier : UObject
{
	/**
	 * Echoes a plain UClass value.
	 *
	 * @Covers Default.FunctionDefaultsAndClassLikeCompile
	 * @Inputs a UClass
	 * @Return the same UClass
	 * @Param Value the class to echo
	 */
	UFUNCTION()
	UClass EchoPlainClass(UClass Value)
	{
		return Value;
	}

	/**
	 * Echoes a TSubclassOf value.
	 *
	 * @Covers Default.FunctionDefaultsAndClassLikeCompile
	 * @Inputs a TSubclassOf<AActor>
	 * @Return the same TSubclassOf
	 * @Param Value the subclass to echo
	 */
	UFUNCTION()
	TSubclassOf<AActor> EchoActorClass(TSubclassOf<AActor> Value)
	{
		return Value;
	}

	/**
	 * Echoes a TSoftClassPtr value.
	 *
	 * @Covers Default.FunctionDefaultsAndClassLikeCompile
	 * @Inputs a TSoftClassPtr<AActor>
	 * @Return the same TSoftClassPtr
	 * @Param Value the soft class pointer to echo
	 */
	UFUNCTION()
	TSoftClassPtr<AActor> EchoSoftActorClass(TSoftClassPtr<AActor> Value)
	{
		return Value;
	}
}

namespace DefaultTest
{
	/**
	 * Sums two ints whose defaults are both 21.
	 *
	 * @Covers Default.FunctionDefaultsAndClassLikeCompile
	 * @Inputs optional Value = 21 and Extra = 21
	 * @Return the sum
	 * @Param Value the first addend
	 * @Param Extra the second addend
	 */
	int SumWithDefault(int Value = 21, int Extra = 21)
	{
		return Value + Extra;
	}

	/**
	 * Calls SumWithDefault with both defaults omitted.
	 *
	 * @Covers Default.FunctionDefaultsAndClassLikeCompile
	 * @Inputs none
	 * @Return 42
	 */
	int Entry()
	{
		return SumWithDefault();
	}

	/**
	 * Observe that Entry() honours both defaults.
	 *
	 * @Kind Observe
	 * @Covers Default.FunctionDefaultsAndClassLikeCompile
	 * @Inputs Entry()
	 * @Return 42
	 */
	UFUNCTION()
	int EntryDefaultSum()
	{
		return Entry();
	}

	/**
	 * Observe the zero boundary of both addends.
	 *
	 * @Kind Observe
	 * @Covers Default.FunctionDefaultsAndClassLikeCompile
	 * @Inputs SumWithDefault(0, 0)
	 * @Return 0
	 * @Boundary zeros
	 */
	UFUNCTION()
	int SumWithDefaultZeroBoundary()
	{
		return SumWithDefault(0, 0);
	}

	/**
	 * Observe that supplying only the first argument keeps the second default.
	 *
	 * @Kind Observe
	 * @Covers Default.FunctionDefaultsAndClassLikeCompile
	 * @Inputs SumWithDefault(21)
	 * @Return 42
	 * @Boundary one explicit
	 */
	UFUNCTION()
	int SumWithDefaultOneExplicitKeepsSecondDefault()
	{
		return SumWithDefault(21);
	}

	/**
	 * Observe that echoing a null UClass stays null.
	 *
	 * @Kind Observe
	 * @Covers Default.FunctionDefaultsAndClassLikeCompile
	 * @Inputs EchoPlainClass(nullptr)
	 * @Return nullptr
	 * @Param Carrier the generated class instance
	 * @Boundary null class
	 */
	UFUNCTION()
	UClass EchoPlainClassNull(UCompilerFunctionCarrier Carrier)
	{
		if (Carrier == nullptr)
		{
			throw("FunctionDefaultsAndClassLikeCompile setup: required UCompilerFunctionCarrier is null");
		}
		return Carrier.EchoPlainClass(nullptr);
	}

	/**
	 * Observe that echoing an empty TSubclassOf stays empty.
	 *
	 * @Kind Observe
	 * @Covers Default.FunctionDefaultsAndClassLikeCompile
	 * @Inputs EchoActorClass of a default TSubclassOf
	 * @Return the empty TSubclassOf
	 * @Param Carrier the generated class instance
	 * @Boundary empty subclass
	 */
	UFUNCTION()
	TSubclassOf<AActor> EchoActorClassEmpty(UCompilerFunctionCarrier Carrier)
	{
		if (Carrier == nullptr)
		{
			throw("FunctionDefaultsAndClassLikeCompile setup: required UCompilerFunctionCarrier is null");
		}
		TSubclassOf<AActor> Empty;
		return Carrier.EchoActorClass(Empty);
	}

	/**
	 * Observe that echoing an empty TSoftClassPtr stays empty.
	 *
	 * @Kind Observe
	 * @Covers Default.FunctionDefaultsAndClassLikeCompile
	 * @Inputs EchoSoftActorClass of a default TSoftClassPtr
	 * @Return the empty TSoftClassPtr
	 * @Param Carrier the generated class instance
	 * @Boundary empty soft class
	 */
	UFUNCTION()
	TSoftClassPtr<AActor> EchoSoftActorClassEmpty(UCompilerFunctionCarrier Carrier)
	{
		if (Carrier == nullptr)
		{
			throw("FunctionDefaultsAndClassLikeCompile setup: required UCompilerFunctionCarrier is null");
		}
		TSoftClassPtr<AActor> Empty;
		return Carrier.EchoSoftActorClass(Empty);
	}
}
