/**
 * CDO and spawned-instance defaults: DefaultCounter=21, bDefaultFlag=true,
 * DefaultLabel="CDOStable". Keep those UPROPERTY names.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.CDOHasExpectedDefaults
 * @Harness UClass
 * @Tag Definitions.UClass.CDOHasExpectedDefaults
 * @Provenance Theme: Definitions.UClass. WorldStory CDO and spawned-instance defaults.
 * @Provenance C++: AngelscriptScriptClassCreationTests.cpp::CDOHasExpectedDefaults
 * @Provenance Oracle: DefaultCounter=21, bDefaultFlag=true, DefaultLabel="CDOStable" on CDO and spawn.
 * @Provenance Extra: nullptr actor is the empty handle; mutating First does not write Second.
 * @Provenance FixtureIsolated. Runner owns CDO and spawned actor. Keep DefaultCounter/bDefaultFlag/DefaultLabel.
 */

UCLASS()
class ATestScriptClassCDOHasExpectedDefaults : AActor
{
	UPROPERTY()
	int DefaultCounter = 21;

	UPROPERTY()
	bool bDefaultFlag = true;

	UPROPERTY()
	FString DefaultLabel = "CDOStable";

	/**
	 * Observe the CDO defaults on this instance.
	 *
	 * @Kind Observe
	 * @Covers UClass.CDO
	 * @Inputs DefaultCounter, bDefaultFlag, DefaultLabel
	 * @Return true when the three defaults match 21, true, and "CDOStable"
	 */
	UFUNCTION()
	bool DefaultsNominal()
	{
		if (DefaultCounter != 21)
		{
			return false;
		}
		if (!bDefaultFlag)
		{
			return false;
		}
		return DefaultLabel == "CDOStable";
	}

	/**
	 * Observe that a nullptr handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.CDO
	 * @Inputs ATestScriptClassCDOHasExpectedDefaults Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ATestScriptClassCDOHasExpectedDefaults Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another at its CDO defaults.
	 *
	 * @Kind Observe
	 * @Covers UClass.CDO
	 * @Param Second Other actor expected to keep CDO defaults
	 * @Inputs this written to 0/false/""
	 * @Return true when Second still holds 21, true, and "CDOStable"
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestScriptClassCDOHasExpectedDefaults Second)
	{
		if (Second is null)
		{
			throw("CDOHasExpectedDefaults setup: required Second is null");
		}
		DefaultCounter = 0;
		bDefaultFlag = false;
		DefaultLabel = "";
		if (Second.DefaultCounter != 21)
		{
			return false;
		}
		if (!Second.bDefaultFlag)
		{
			return false;
		}
		return Second.DefaultLabel == "CDOStable";
	}
}
