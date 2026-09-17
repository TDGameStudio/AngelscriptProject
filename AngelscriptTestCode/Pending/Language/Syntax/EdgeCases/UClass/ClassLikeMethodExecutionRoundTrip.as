/**
 * @version v1
 * @summary Class-like values — a plain UClass, a TSubclassOf and a TSoftClassPtr — passed through UFUNCTION signatures and back. Each echo must return the same value it was given, including the null and empty cases.
 * @topic Language
 */
/**
 * @version root
 * @summary Class-like values — a plain UClass, a TSubclassOf and a TSoftClassPtr — passed through UFUNCTION signatures and back. Each echo must return the same value it was given, including the null and empty cases.
 * @topic Baseline
 */
UCLASS()
class UCompilerClassLikeExecutionCarrier : UObject
{
	/**
	 * Echoes a plain UClass value.
	 *
	 * @Covers Syntax.EdgeCases
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
	 * @Covers Syntax.EdgeCases
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
	 * @Covers Syntax.EdgeCases
	 * @Inputs a TSoftClassPtr<AActor>
	 * @Return the same TSoftClassPtr
	 * @Param Value the soft class pointer to echo
	 */
	UFUNCTION()
	TSoftClassPtr<AActor> EchoSoftActorClass(TSoftClassPtr<AActor> Value)
	{
		return Value;
	}

	/**
	 * Verifies all three echoes in sequence.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 1 on success, otherwise 10, 20 or 30 naming the failing echo
	 */
	UFUNCTION()
	int VerifyRoundTrip()
	{
		if (!(EchoPlainClass(AActor::StaticClass()) == AActor::StaticClass()))
			return 10;

		if (!(EchoActorClass(ACameraActor::StaticClass()) == ACameraActor::StaticClass()))
			return 20;

		TSoftClassPtr<AActor> SoftActorClass = TSoftClassPtr<AActor>(AActor::StaticClass());
		if (!(EchoSoftActorClass(SoftActorClass).Get() == AActor::StaticClass()))
			return 30;

		return 1;
	}

	/**
	 * Observe that the full round-trip verification passes.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs VerifyRoundTrip()
	 * @Return true when the result is 1
	 */
	UFUNCTION()
	bool ClassLikeVerifyRoundTripSucceeds()
	{
		return VerifyRoundTrip() == 1;
	}

	/**
	 * Observe that echoing a null class stays null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EchoPlainClass(nullptr)
	 * @Return true when the result is null
	 * @Boundary null class
	 */
	UFUNCTION()
	bool ClassLikePlainNullStaysNull()
	{
		return EchoPlainClass(nullptr) == nullptr;
	}

	/**
	 * Observe that an empty TSubclassOf echoes back empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EchoActorClass over an empty TSubclassOf
	 * @Return true when the empty value survives
	 * @Boundary empty subclass
	 */
	UFUNCTION()
	bool ClassLikeActorEmptyStaysEmpty()
	{
		TSubclassOf<AActor> Empty;
		return EchoActorClass(Empty) == Empty;
	}

	/**
	 * Observe that a real TSubclassOf echoes back unchanged.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EchoActorClass over the camera actor class
	 * @Return true when the class identity is preserved
	 */
	UFUNCTION()
	bool ClassLikeActorIdentityPreserved()
	{
		return EchoActorClass(ACameraActor::StaticClass()) == ACameraActor::StaticClass();
	}
}
/** @end */
