/**
 * @version v1
 * @summary GetUObject is null when unbound and this when bound. RunGetUObjectTest returns 1. A second local stays unbound.
 * @topic Feature
 */
/**
 * @version root
 * @summary GetUObject is null when unbound and this when bound. RunGetUObjectTest returns 1. A second local stays unbound.
 * @topic Baseline
 */
/**
 * A parameterless void unicast.
 *
 * @Covers Delegates.GetUObject
 * @Inputs none
 * @Return nothing when executed
 */
delegate void FSimpleNotify();

UCLASS()
class ATestDelegateGetUObject : AActor
{
	UPROPERTY()
	FSimpleNotify OnNotify;

	/**
	 * An empty named handler for BindUFunction.
	 *
	 * @Covers Delegates.GetUObject
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void HandleNotify()
	{
	}

	/**
	 * Checks GetUObject unbound, then bound to this.
	 *
	 * @Covers Delegates.GetUObject
	 * @Inputs none
	 * @Return 1 on success, or 10/20/30 on a failed step
	 */
	UFUNCTION()
	int RunGetUObjectTest()
	{
		if (OnNotify.GetUObject() != nullptr)
		{
			return 10;
		}

		OnNotify.BindUFunction(this, n"HandleNotify");
		UObject Target = OnNotify.GetUObject();
		if (Target == nullptr)
		{
			return 20;
		}
		if (Target != this)
		{
			return 30;
		}

		return 1;
	}

	/**
	 * Observe the GetUObject path.
	 *
	 * @Kind Observe
	 * @Covers Delegates.GetUObject
	 * @Inputs RunGetUObjectTest()
	 * @Return 1
	 */
	UFUNCTION()
	int GetUObjectPathReturnsOne()
	{
		return RunGetUObjectTest();
	}

	/**
	 * Observe that GetUObject starts null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.GetUObject
	 * @Inputs this
	 * @Return true when GetUObject is null
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool DefaultNull()
	{
		return OnNotify.GetUObject() == nullptr;
	}

	/**
	 * Observe that binding this leaves Second unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.GetUObject
	 * @Param Second the other actor, runner-owned when non-null
	 * @Inputs RunGetUObjectTest on this
	 * @Return true when this returns 1 and Second.GetUObject is null
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TwoLocalsIndependent(ATestDelegateGetUObject Second)
	{
		if (Second is null)
		{
			throw("GetUObjectReturnsTarget setup: required Second is null");
		}
		int FirstResult = RunGetUObjectTest();
		if (FirstResult != 1)
		{
			return false;
		}
		return Second.OnNotify.GetUObject() == nullptr;
	}
}
/** @end */
