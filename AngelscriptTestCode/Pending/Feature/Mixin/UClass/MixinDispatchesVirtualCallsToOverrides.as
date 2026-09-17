/**
 * @version v1
 * @summary A mixin virtual call dispatches to BlueprintOverride. C++ expects parent MixinResult==11 DirectResult==11 and child MixinResult==77 DirectResult==77. The observers cover the empty handle, pre-BeginPlay zeros, and the.
 * @topic Feature
 */
/**
 * @version root
 * @summary A mixin virtual call dispatches to BlueprintOverride. C++ expects parent MixinResult==11 DirectResult==11 and child MixinResult==77 DirectResult==77. The observers cover the empty handle, pre-BeginPlay zeros, and the.
 * @topic Baseline
 */
/**
 * Mixin that reads the virtual value through GetVirtualValue.
 *
 * @Kind Mixin
 * @Covers Mixin.MixinDispatchesVirtualCallsToOverrides
 * @Inputs the parent actor as Self
 * @Param Self the mixin receiver
 * @Return Self.GetVirtualValue()
 */
mixin int ReadVirtualValue(ACoverageMixinVirtualParent Self)
{
	return Self.GetVirtualValue();
}

/**
 * Mixin that stores the virtual value into MixinResult.
 *
 * @Kind Mixin
 * @Covers Mixin.MixinDispatchesVirtualCallsToOverrides
 * @Inputs the parent actor as Self
 * @Param Self the mixin receiver
 * @Return void; Self.MixinResult becomes Self.ReadVirtualValue()
 */
mixin void StoreVirtualValue(ACoverageMixinVirtualParent Self)
{
	Self.MixinResult = Self.ReadVirtualValue();
}

UCLASS()
class ACoverageMixinVirtualParent : AActor
{
	UPROPERTY()
	int MixinResult = 0;

	UPROPERTY()
	int DirectResult = 0;

	/**
	 * Parent virtual value, 11.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.MixinDispatchesVirtualCallsToOverrides
	 * @Inputs none
	 * @Return 11
	 */
	UFUNCTION(BlueprintEvent)
	int GetVirtualValue()
	{
		return 11;
	}

	/**
	 * WorldStory: store the mixin virtual value and the direct virtual value.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.MixinDispatchesVirtualCallsToOverrides
	 * @Inputs none
	 * @Return MixinResult 11, DirectResult 11
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		this.StoreVirtualValue();
		DirectResult = GetVirtualValue();
	}

	/**
	 * Observe that mixin and direct results are zero before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinDispatchesVirtualCallsToOverrides
	 * @Inputs this parent before BeginPlay
	 * @Return MixinResult + DirectResult
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int DefaultsAreZero()
	{
		return MixinResult + DirectResult;
	}

	/**
	 * Observe the parent BeginPlay oracle: both results are 11.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinDispatchesVirtualCallsToOverrides
	 * @Inputs this parent after BeginPlay
	 * @Return true when MixinResult is 11 and DirectResult is 11
	 */
	UFUNCTION()
	bool ParentVirtualAfterPlay()
	{
		if (MixinResult != 11)
		{
			return false;
		}
		return DirectResult == 11;
	}
}

UCLASS()
class ACoverageMixinVirtualChild : ACoverageMixinVirtualParent
{
	/**
	 * Child virtual value, 77.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.MixinDispatchesVirtualCallsToOverrides
	 * @Inputs none
	 * @Return 77
	 */
	UFUNCTION(BlueprintOverride)
	int GetVirtualValue()
	{
		return 77;
	}

	/**
	 * WorldStory: store the mixin virtual value and the direct virtual value on the child.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.MixinDispatchesVirtualCallsToOverrides
	 * @Inputs none
	 * @Return MixinResult 77, DirectResult 77
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		this.StoreVirtualValue();
		DirectResult = GetVirtualValue();
	}

	/**
	 * Observe that an unset child handle is null.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinDispatchesVirtualCallsToOverrides
	 * @Inputs an unset ACoverageMixinVirtualChild handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageMixinVirtualChild Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the child BeginPlay oracle: both results are 77.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinDispatchesVirtualCallsToOverrides
	 * @Inputs this child after BeginPlay
	 * @Return true when MixinResult is 77 and DirectResult is 77
	 */
	UFUNCTION()
	bool ChildVirtualAfterPlay()
	{
		if (MixinResult != 77)
		{
			return false;
		}
		return DirectResult == 77;
	}

	/**
	 * Observe the child's direct virtual value.
	 *
	 * @Kind Observe
	 * @Covers Mixin.MixinDispatchesVirtualCallsToOverrides
	 * @Inputs this child
	 * @Return GetVirtualValue()
	 */
	UFUNCTION()
	int DirectChildValue()
	{
		return GetVirtualValue();
	}
}
/** @end */
