/**
 * @version v1
 * @summary An actor subclassing AAngelscriptGASActor, which must inherit the ability system component. The observers cover both null handles and handle independence.
 * @topic Optional
 */
/**
 * @version root
 * @summary An actor subclassing AAngelscriptGASActor, which must inherit the ability system component. The observers cover both null handles and handle independence.
 * @topic Baseline
 */
UCLASS()
class ATestGASActor : AAngelscriptGASActor
{
	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.ScriptSubclassInheritsASCFromGASActor
	 * @Inputs an unset actor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ATestGASActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that two runner-supplied handles refer to different objects.
	 *
	 * @Kind Observe
	 * @Covers GAS.ScriptSubclassInheritsASCFromGASActor
	 * @Inputs two actor handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(ATestGASActor First, ATestGASActor Second)
	{
		if (First == nullptr)
		{
			return false;
		}
		if (Second == nullptr)
		{
			return false;
		}
		return First != Second;
	}
}

/**
 * The empty sibling actor that C++ also compiles alongside the subclass.
 *
 * @Covers GAS.ScriptSubclassInheritsASCFromGASActor
 * @Inputs none
 * @Return a declared but empty actor subclass
 */
UCLASS()
class ATestGASActorEmpty : AAngelscriptGASActor
{
	/**
	 * Observe that an unset handle of the empty sibling is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.ScriptSubclassInheritsASCFromGASActor
	 * @Inputs an unset empty-sibling handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool EmptySiblingNull()
	{
		ATestGASActorEmpty Actor = nullptr;
		return Actor == nullptr;
	}
}
/** @end */
