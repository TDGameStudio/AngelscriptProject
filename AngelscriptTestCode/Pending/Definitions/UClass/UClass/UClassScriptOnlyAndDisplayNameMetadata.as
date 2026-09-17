/**
 * @version v1
 * @summary Script-only class plus fallback versus explicit DisplayName. The plain script class still publishes a UClass with a non-empty DisplayName; explicit DisplayName is "Coverage Explicit Display Object".
 * @topic Definitions
 */
/**
 * @version root
 * @summary Script-only class plus fallback versus explicit DisplayName. The plain script class still publishes a UClass with a non-empty DisplayName; explicit DisplayName is "Coverage Explicit Display Object".
 * @topic Baseline
 */
class FCoverageUClassPlainScriptState
{
	int Value = 5;

	/**
	 * Observe the script-state Value default.
	 *
	 * @Kind Observe
	 * @Covers UClass.DisplayName
	 * @Inputs a freshly constructed state
	 * @Return Value
	 */
	int ValueDefault()
	{
		return Value;
	}

	/**
	 * Observe writing Value to 0.
	 *
	 * @Kind Observe
	 * @Covers UClass.DisplayName
	 * @Inputs Value set to 0
	 * @Return Value
	 * @Boundary zero
	 */
	int ZeroBoundary()
	{
		Value = 0;
		return Value;
	}

	/**
	 * Observe that writing this state leaves another at 5.
	 *
	 * @Kind Observe
	 * @Covers UClass.DisplayName
	 * @Inputs this.Value set to 9
	 * @Return true when this holds 9 and the other holds 5
	 * @Boundary copy independence
	 */
	bool CopyIndependence()
	{
		FCoverageUClassPlainScriptState Other;
		Value = 9;
		if (Value != 9)
		{
			return false;
		}
		return Other.Value == 5;
	}
}

UCLASS()
class UCoverageUClassDefaultDisplayNameObject : UObject
{
	/**
	 * Observe that an unset default-display-name handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.DisplayName
	 * @Inputs an unset UCoverageUClassDefaultDisplayNameObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassDefaultDisplayNameObject Obj;
		return Obj == nullptr;
	}
}

UCLASS(meta=(DisplayName="Coverage Explicit Display Object"))
class UCoverageUClassExplicitDisplayNameObject : UObject
{
	/**
	 * Observe that an unset explicit-display-name handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.DisplayName
	 * @Inputs an unset UCoverageUClassExplicitDisplayNameObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassExplicitDisplayNameObject Obj;
		return Obj == nullptr;
	}
}
/** @end */
