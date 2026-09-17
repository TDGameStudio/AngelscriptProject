/**
 * @version v1
 * @summary TSubclassOf parameter and UClass conversions. StaticClassToSubclassParameter, TSubclassOfToUClassParameter, NullSubclassParameter, and DefaultObjectMatchesSubclass are the global names C++ InvokeGlobal uses.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TSubclassOf parameter and UClass conversions. StaticClassToSubclassParameter, TSubclassOfToUClassParameter, NullSubclassParameter, and DefaultObjectMatchesSubclass are the global names C++ InvokeGlobal uses.
 * @topic Baseline
 */
UCLASS()
class ACoverageSubclassParamBaseActor : AActor
{
}

UCLASS()
class ACoverageSubclassParamDerivedActor : ACoverageSubclassParamBaseActor
{
	/**
	 * Observe that an unset base handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.TSubclassOf
	 * @Inputs an unset ACoverageSubclassParamBaseActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageSubclassParamBaseActor Actor;
		return Actor == nullptr;
	}
}

/**
 * Observe a TSubclassOf<AActor> parameter: valid child classes return 1.
 *
 * @Kind Observe
 * @Covers UClass.TSubclassOf
 * @Param ActorClass Subclass handle
 * @Inputs IsValid and IsChildOf(AActor)
 * @Return 1 when valid and a child of AActor, otherwise 0
 */
UFUNCTION()
int AcceptSubclass(TSubclassOf<AActor> ActorClass)
{
	if (!ActorClass.IsValid())
	{
		return 0;
	}
	if (!ActorClass.IsChildOf(AActor::StaticClass()))
	{
		return 0;
	}
	return 1;
}

/**
 * Observe converting TSubclassOf to UClass and matching the derived static class.
 *
 * @Kind Observe
 * @Covers UClass.TSubclassOf
 * @Param ActorClass Subclass of the coverage base
 * @Inputs UClass Class = ActorClass
 * @Return 1 when Class equals the derived static class, otherwise 0
 */
UFUNCTION()
int AcceptExactDerived(TSubclassOf<ACoverageSubclassParamBaseActor> ActorClass)
{
	UClass Class = ActorClass;
	if (Class == ACoverageSubclassParamDerivedActor::StaticClass())
	{
		return 1;
	}
	return 0;
}

/**
 * Observe passing a derived StaticClass into a TSubclassOf<AActor> parameter.
 *
 * @Kind Observe
 * @Covers UClass.TSubclassOf
 * @Inputs AcceptSubclass(ACoverageSubclassParamDerivedActor::StaticClass())
 * @Return 1
 */
UFUNCTION()
int StaticClassToSubclassParameter()
{
	return AcceptSubclass(ACoverageSubclassParamDerivedActor::StaticClass());
}

/**
 * Observe converting a TSubclassOf value into a UClass parameter.
 *
 * @Kind Observe
 * @Covers UClass.TSubclassOf
 * @Inputs TSubclassOf assigned from the derived StaticClass
 * @Return 1
 */
UFUNCTION()
int TSubclassOfToUClassParameter()
{
	TSubclassOf<ACoverageSubclassParamBaseActor> ActorClass = ACoverageSubclassParamDerivedActor::StaticClass();
	return AcceptExactDerived(ActorClass);
}

/**
 * Observe an empty TSubclassOf parameter.
 *
 * @Kind Observe
 * @Covers UClass.TSubclassOf
 * @Inputs default TSubclassOf<AActor>
 * @Return 0
 * @Boundary empty subclass
 */
UFUNCTION()
int NullSubclassParameter()
{
	TSubclassOf<AActor> ActorClass;
	return AcceptSubclass(ActorClass);
}

/**
 * Observe GetDefaultObject on a TSubclassOf of the derived actor.
 *
 * @Kind Observe
 * @Covers UClass.TSubclassOf
 * @Inputs ActorClass.GetDefaultObject()
 * @Return 1 when the CDO is the derived class
 */
UFUNCTION()
int DefaultObjectMatchesSubclass()
{
	TSubclassOf<AActor> ActorClass = ACoverageSubclassParamDerivedActor::StaticClass();
	AActor DefaultActor = ActorClass.GetDefaultObject();
	if (DefaultActor == nullptr)
	{
		return 0;
	}
	if (!DefaultActor.IsA(ACoverageSubclassParamDerivedActor::StaticClass()))
	{
		return 0;
	}
	return 1;
}
/** @end */
