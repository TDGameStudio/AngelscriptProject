/**
 * @version v1
 * @summary A debugger marker probe whose getter reads a property declared only on the base class. The derived class must not redeclare Health, so the getter resolves the inherited property address.
 * @topic Debugger
 */
/**
 * @version root
 * @summary A debugger marker probe whose getter reads a property declared only on the base class. The derived class must not redeclare Health, so the getter resolves the inherited property address.
 * @topic Baseline
 */
UCLASS()
class ADebuggerValueBaseProbe : AActor
{
	UPROPERTY()
	int Health = 42;
}

UCLASS()
class ADebuggerValueDerivedProbe : ADebuggerValueBaseProbe
{
	/**
	 * Reads the property inherited from the base probe.
	 *
	 * @Covers InheritedGetterTracksBasePropertyAddress.InheritedTracking
	 * @Inputs the inherited Health
	 * @Return 42 by default
	 */
	UFUNCTION()
	int GetHealth() const
	{
		return Health;
	}

	/**
	 * Observe that the inherited property keeps its default.
	 *
	 * @Kind Observe
	 * @Covers InheritedGetterTracksBasePropertyAddress.InheritedTracking
	 * @Inputs a freshly constructed derived probe
	 * @Return true when Health is 42
	 * @Boundary inherited default
	 */
	UFUNCTION()
	bool InheritedHealthDefaultsToFortyTwo()
	{
		return Health == 42;
	}

	/**
	 * Observe that the derived getter reads the base property.
	 *
	 * @Kind Observe
	 * @Covers InheritedGetterTracksBasePropertyAddress.InheritedTracking
	 * @Inputs GetHealth() and the inherited Health
	 * @Return true when both report 42
	 */
	UFUNCTION()
	bool DerivedGetterResolvesBaseProperty()
	{
		if (GetHealth() != 42)
		{
			return false;
		}

		return Health == 42;
	}

	/**
	 * Observe that writing the inherited property is visible to the getter.
	 *
	 * @Kind Observe
	 * @Covers InheritedGetterTracksBasePropertyAddress.InheritedTracking
	 * @Inputs the inherited Health set through the derived probe
	 * @Return true when the getter reports the new value
	 * @Boundary inherited write
	 */
	UFUNCTION()
	bool InheritedHealthWriteIsVisibleToGetter()
	{
		Health = 0;
		return GetHealth() == 0;
	}
}
/** @end */
