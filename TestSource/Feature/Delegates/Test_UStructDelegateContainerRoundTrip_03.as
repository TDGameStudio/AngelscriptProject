// Theme: Feature.Delegates. Positive block 3: preserved-field flags on the container actor.
// C++: AngelscriptCoverageUStructTests.cpp::UStructDelegateContainerRoundTrip lines 5864-5913.
// Isolation=none: wrap the raw UPROPERTY flags in a complete actor. Oracle: defaults false.
// Extra: all flags false; toggling a copy does not change the original actor flags.
// DefaultSafe. Keep bArrayValuePreserved and sibling flag names.

UCLASS()
class ACoverageStructDelegateContainerActor : AActor
{
	UPROPERTY()
	bool bArrayValuePreserved = false;

	UPROPERTY()
	bool bArrayInPreserved = false;

	UPROPERTY()
	bool bMapValuePreserved = false;

	UPROPERTY()
	bool bMapInPreserved = false;

	UPROPERTY()
	bool bKeyMapValuePreserved = false;

	UPROPERTY()
	bool bKeyMapInPreserved = false;

	UPROPERTY()
	bool bKeyMapOutPreserved = false;

	UPROPERTY()
	bool bKeyMapInoutPreserved = false;

	UPROPERTY()
	bool bKeyMapReturnPreserved = false;

	UPROPERTY()
	bool bStructMapValuePreserved = false;

	UPROPERTY()
	bool bStructMapInPreserved = false;

	UPROPERTY()
	bool bStructMapOutPreserved = false;

	UPROPERTY()
	bool bStructMapInoutPreserved = false;

	UPROPERTY()
	bool bStructMapReturnPreserved = false;

	UPROPERTY()
	bool bSetValuePreserved = false;

	UPROPERTY()
	bool bSetInPreserved = false;
}

bool Observe_PreservedFlags_DefaultFalse(ACoverageStructDelegateContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructDelegateContainerRoundTrip_03 setup: required Actor is null");
	}
	return !Actor.bArrayValuePreserved && !Actor.bMapValuePreserved && !Actor.bKeyMapValuePreserved
		&& !Actor.bStructMapValuePreserved && !Actor.bSetValuePreserved;
}

bool Observe_BoolFlag_CopyIndependence()
{
	bool Original = false;
	bool Copy = Original;
	Copy = true;
	return !Original && Copy;
}
