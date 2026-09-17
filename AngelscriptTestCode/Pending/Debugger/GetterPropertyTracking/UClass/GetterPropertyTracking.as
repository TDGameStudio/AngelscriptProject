/**
 * @version v1
 * @summary A debugger marker probe whose getter resolves the Health property address. The debug session reads Health through reflection and compares it against what the getter reports.
 * @topic Debugger
 */
/**
 * @version root
 * @summary A debugger marker probe whose getter resolves the Health property address. The debug session reads Health through reflection and compares it against what the getter reports.
 * @topic Baseline
 */
UCLASS()
class ADebuggerValueGetterProbe : AActor
{
	UPROPERTY()
	int Health = 42;

	/**
	 * Reads the tracked property without modifying it.
	 *
	 * @Covers GetterPropertyTracking.PropertyTracking
	 * @Inputs the actor's Health
	 * @Return 42 by default
	 */
	UFUNCTION()
	int GetHealth() const
	{
		return Health;
	}

	/**
	 * Observe the nominal property value the debug session expects.
	 *
	 * @Kind Observe
	 * @Covers GetterPropertyTracking.PropertyTracking
	 * @Inputs a freshly constructed probe
	 * @Return true when Health is 42
	 */
	UFUNCTION()
	bool HealthDefaultsToFortyTwo()
	{
		return Health == 42;
	}

	/**
	 * Observe that the getter resolves to the property value.
	 *
	 * @Kind Observe
	 * @Covers GetterPropertyTracking.PropertyTracking
	 * @Inputs GetHealth() and Health
	 * @Return true when both report 42
	 */
	UFUNCTION()
	bool GetHealthResolvesPropertyAddress()
	{
		if (GetHealth() != 42)
		{
			return false;
		}

		return Health == 42;
	}

	/**
	 * Observe the zero boundary that would mark a different probe.
	 *
	 * @Kind Observe
	 * @Covers GetterPropertyTracking.PropertyTracking
	 * @Inputs Health set to 0
	 * @Return true when the getter reports 0
	 * @Boundary zero health
	 */
	UFUNCTION()
	bool HealthZeroBoundaryIsDistinct()
	{
		Health = 0;
		return GetHealth() == 0;
	}
}
/** @end */
