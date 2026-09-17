/**
 * @version v1
 * @summary AllowPrivateAccess versus hidden private UPROPERTY visibility. ReadValues returns 37+41+43=121. Keep ReadValues and the three private property names.
 * @topic Definitions
 */
/**
 * @version root
 * @summary AllowPrivateAccess versus hidden private UPROPERTY visibility. ReadValues returns 37+41+43=121. Keep ReadValues and the three private property names.
 * @topic Baseline
 */
UCLASS()
class UCoverageUClassPrivatePropertyVisibilityObject : UObject
{
	UPROPERTY(BlueprintReadWrite, meta=(AllowPrivateAccess))
	private int AllowedPrivateValue = 37;

	UPROPERTY(BlueprintReadWrite)
	private int HiddenPrivateValue = 41;

	UPROPERTY(BlueprintReadOnly, meta=(AllowPrivateAccess))
	private int ReadOnlyPrivateValue = 43;

	/**
	 * Observe ReadValues: it sums the three private fields.
	 *
	 * @Kind Observe
	 * @Covers UClass.Access
	 * @Inputs AllowedPrivateValue, HiddenPrivateValue, ReadOnlyPrivateValue
	 * @Return 121
	 */
	UFUNCTION(BlueprintCallable)
	int ReadValues()
	{
		return AllowedPrivateValue + HiddenPrivateValue + ReadOnlyPrivateValue;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Access
	 * @Inputs an unset UCoverageUClassPrivatePropertyVisibilityObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassPrivatePropertyVisibilityObject Obj;
		return Obj == nullptr;
	}

	/**
	 * Observe the ReadValues default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Access
	 * @Inputs a freshly constructed object
	 * @Return ReadValues()
	 */
	UFUNCTION()
	int ReadValuesDefault()
	{
		return ReadValues();
	}

	/**
	 * Observe that two instances both report 121.
	 *
	 * @Kind Observe
	 * @Covers UClass.Access
	 * @Param Second Other instance expected to stay at 121
	 * @Inputs ReadValues on this and Second
	 * @Return true when both return 121
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UCoverageUClassPrivatePropertyVisibilityObject Second)
	{
		if (Second is null)
		{
			throw("UClassPrivateAllowPrivateAccessPropertyVisibility setup: required Second is null");
		}
		if (ReadValues() != 121)
		{
			return false;
		}
		return Second.ReadValues() == 121;
	}
}
/** @end */
