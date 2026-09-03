/**
 * A UObject CDO whose Counter is 12 and Label is "Seed". Fresh instances
 * carry those defaults and stay independent of each other. Keep Counter/Label.
 *
 * @Theme Feature.Default
 * @Subject Default.UClassDefaultObjectAndInstanceStateIndependence
 * @Harness UClass
 * @Tag Feature.Default.UClassDefaultObjectAndInstanceStateIndependence
 * @Provenance Theme: Feature.Default. Positive UObject CDO defaults and instance independence.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassDefaultObjectAndInstanceStateIndependence
 * @Provenance VerifyByPath Counter==12 Label=="Seed" on the first instance. Keep Counter/Label.
 * @Provenance Extra: empty handle is null; mutating First does not write Second.
 * @Provenance DefaultSafe.
 */

UCLASS(BlueprintType)
class UCoverageUClassDefaultObjectProbe : UObject
{
	UPROPERTY()
	int Counter = 12;

	UPROPERTY()
	FString Label = "Seed";

	/**
	 * Observe that an unset handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers Default.UClassDefaultObjectAndInstanceStateIndependence
	 * @Inputs a freshly declared handle
	 * @Return true when the unset handle is null
	 * @Boundary unset handle
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		UCoverageUClassDefaultObjectProbe Obj;
		return Obj == nullptr;
	}

	/**
	 * Observe the CDO Counter default.
	 *
	 * @Kind Observe
	 * @Covers Default.UClassDefaultObjectAndInstanceStateIndependence
	 * @Inputs a freshly constructed object
	 * @Return 12
	 */
	UFUNCTION()
	int CounterNominal()
	{
		return Counter;
	}

	/**
	 * Observe the CDO Label default.
	 *
	 * @Kind Observe
	 * @Covers Default.UClassDefaultObjectAndInstanceStateIndependence
	 * @Inputs a freshly constructed object
	 * @Return "Seed"
	 */
	UFUNCTION()
	FString LabelNominal()
	{
		return Label;
	}

	/**
	 * Observe that writing this object leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Default.UClassDefaultObjectAndInstanceStateIndependence
	 * @Inputs this object written to, compared against a second object
	 * @Return true when the other still holds 12 and Seed
	 * @Param Second the other object
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependent(UCoverageUClassDefaultObjectProbe Second)
	{
		if (Second == nullptr)
		{
			throw("UClassDefaultObjectAndInstanceStateIndependence setup: required Second is null");
		}
		Counter = 0;
		Label = "";
		if (Second.Counter != 12)
		{
			return false;
		}
		return Second.Label == "Seed";
	}
}
