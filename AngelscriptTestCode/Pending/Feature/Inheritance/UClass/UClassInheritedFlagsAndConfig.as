/**
 * @version v1
 * @summary Inherited class flags, Config and HideDropdown. C++ verifies CLASS_Config, DefaultConfig, Transient, Deprecated and DefaultToInstanced on the base, a child Config property, and HideDropdown base versus visible child.
 * @topic Feature
 */
/**
 * @version root
 * @summary Inherited class flags, Config and HideDropdown. C++ verifies CLASS_Config, DefaultConfig, Transient, Deprecated and DefaultToInstanced on the base, a child Config property, and HideDropdown base versus visible child.
 * @topic Baseline
 */
UCLASS(Transient, Deprecated, DefaultToInstanced, EditInlineNew, Config=Game, DefaultConfig)
class UCoverageUClassInheritedFlagBaseObject : UObject
{
	UPROPERTY(Config)
	int BaseConfigValue = 13;

	/**
	 * Observe the base Config default.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UClassInheritedFlagsAndConfig
	 * @Inputs a freshly constructed base object
	 * @Return BaseConfigValue, expected to be 13
	 */
	UFUNCTION()
	int BaseConfigDefault()
	{
		return BaseConfigValue;
	}
}

UCLASS()
class UCoverageUClassInheritedFlagChildObject : UCoverageUClassInheritedFlagBaseObject
{
	UPROPERTY(Config)
	int ChildConfigValue = 17;

	/**
	 * Observe the child Config default.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UClassInheritedFlagsAndConfig
	 * @Inputs a freshly constructed child object
	 * @Return ChildConfigValue, expected to be 17
	 */
	UFUNCTION()
	int ChildConfigDefault()
	{
		return ChildConfigValue;
	}

	/**
	 * Observe zeroing both Config values on this child.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UClassInheritedFlagsAndConfig
	 * @Inputs BaseConfigValue and ChildConfigValue set to 0
	 * @Return the sum of both values, expected to be 0
	 * @Boundary zero assign
	 */
	UFUNCTION()
	int ZeroBoundary()
	{
		BaseConfigValue = 0;
		ChildConfigValue = 0;
		return BaseConfigValue + ChildConfigValue;
	}

	/**
	 * Observe that writing ChildConfigValue on this child leaves another child untouched.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UClassInheritedFlagsAndConfig
	 * @Inputs this child plus a second child
	 * @Return true when this is 0 and the other stays ChildConfigValue 17 / BaseConfigValue 13
	 * @Param Second the other child, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UCoverageUClassInheritedFlagChildObject Second)
	{
		if (Second == nullptr)
		{
			throw("UClassInheritedFlagsAndConfig setup: required Second is null");
		}
		ChildConfigValue = 0;
		if (ChildConfigValue != 0)
		{
			return false;
		}
		if (Second.ChildConfigValue != 17)
		{
			return false;
		}
		return Second.BaseConfigValue == 13;
	}
}

UCLASS(HideDropdown)
class UCoverageUClassHiddenDropdownBaseObject : UObject
{
}

UCLASS()
class UCoverageUClassVisibleDropdownChildObject : UCoverageUClassHiddenDropdownBaseObject
{
	/**
	 * Observe that locally constructed HideDropdown handles stay null.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UClassInheritedFlagsAndConfig
	 * @Inputs local constructs of the hidden base and visible child
	 * @Return true when both local handles are null
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool LocalConstructHandlesAreNull()
	{
		UCoverageUClassHiddenDropdownBaseObject Hidden;
		UCoverageUClassVisibleDropdownChildObject Visible;
		if (Hidden != nullptr)
		{
			return false;
		}
		return Visible == nullptr;
	}
}
/** @end */
