/**
 * @version v1
 * @summary The reflection shape of class-like signatures: a plain UClass, a TSubclassOf and a TSoftClassPtr each echoed through a UFUNCTION. The observers confirm the null pass-through, the AActor class identity, and the empty soft.
 * @topic Language
 */
/**
 * @version root
 * @summary The reflection shape of class-like signatures: a plain UClass, a TSubclassOf and a TSoftClassPtr each echoed through a UFUNCTION. The observers confirm the null pass-through, the AActor class identity, and the empty soft.
 * @topic Baseline
 */
UCLASS()
class UCompilerClassLikeShapeCarrier : UObject
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
	 * Observe that echoing a null class stays null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EchoPlainClass(nullptr)
	 * @Return true when the result is null
	 * @Boundary null class
	 */
	UFUNCTION()
	bool ClassLikeShapePlainNullStaysNull()
	{
		return EchoPlainClass(nullptr) == nullptr;
	}

	/**
	 * Observe that the AActor class identity survives the echo.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EchoActorClass over the AActor class
	 * @Return true when the identity is preserved
	 */
	UFUNCTION()
	bool ClassLikeShapeActorIdentityPreserved()
	{
		TSubclassOf<AActor> ActorClass = AActor::StaticClass();
		TSubclassOf<AActor> Echoed = EchoActorClass(ActorClass);
		return Echoed == ActorClass;
	}

	/**
	 * Observe that an empty soft class pointer echoes back null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EchoSoftActorClass over an empty TSoftClassPtr
	 * @Return true when the echoed value is null
	 * @Boundary empty soft pointer
	 */
	UFUNCTION()
	bool ClassLikeShapeSoftEmptyStaysNull()
	{
		TSoftClassPtr<AActor> Empty;
		TSoftClassPtr<AActor> Echoed = EchoSoftActorClass(Empty);
		return Echoed.IsNull();
	}
}
/** @end */
