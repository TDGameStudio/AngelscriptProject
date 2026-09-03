/**
 * A debugger marker probe whose getter resolves the Health property address. The
 * debug session reads Health through reflection and compares it against what the
 * getter reports.
 *
 * @Theme Debugger.GetterPropertyTracking
 * @Subject GetterPropertyTracking.PropertyTracking
 * @Harness UClass
 * @Tag Debugger.GetterPropertyTracking.GetterPropertyTracking
 * @Provenance Theme: Debugger marker payload. Getter tracks the Health property address.
 * @Provenance C++: AngelscriptDebuggerValueTests.cpp::GetterPropertyTracking
 * @Provenance Oracle (DAP/C++): Health UPROPERTY 42, GetHealth resolves, actor in a World.
 * @Provenance Extra: default Health 42 is the nominal marker; 0 would be a different probe.
 * @Provenance DiagnosticOnly for the debug session; this file is a stable marker program.
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
