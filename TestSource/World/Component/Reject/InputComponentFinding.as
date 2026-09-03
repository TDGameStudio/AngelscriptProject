/**
 * FindComponentByClass taking a UClass argument is not available, so this
 * program is rejected. The failing call is isolated inside BeginPlay; no extra
 * declaration may be added that would compile the failure away.
 *
 * @Theme World.Component
 * @Subject Component.InputComponentFinding
 * @Harness CompileReject
 * @Tag World.Component.InputComponentFinding
 * @Provenance Theme: World.Component. CSV WorldStory; C++ CompileAndExpectFailure.
 * @Provenance Isolated failing program: FindComponentByClass(UClass) is unavailable.
 * @Provenance C++: AngelscriptCoverageInputTests.cpp::InputComponentFinding
 * @Provenance sha256=52a30413afe6b1ec398290c0eca835854be1d71217ad394c7493cdbeb7e89d6e; lines 957-971.
 * @Provenance Expected diagnostic: No matching signatures to 'FindComponentByClass(UClass)'.
 * @Provenance Do not add extra declarations that would compile this away.
 */

UCLASS()
class AInputComponentFindingPawn : APawn
{
	UPROPERTY()
	bool FoundInputComponent = false;

	/**
	 * The isolated failing program: the UClass overload of FindComponentByClass
	 * has no matching signature.
	 *
	 * @Kind WorldStory
	 * @Covers Component.InputComponentFinding
	 * @Inputs FindComponentByClass(UInputComponent::StaticClass())
	 * @Return does not compile; "No matching signatures to 'FindComponentByClass(UClass)'"
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Expected diagnostic: No matching signatures to 'FindComponentByClass(UClass)'
		UInputComponent InputComp = Cast<UInputComponent>(FindComponentByClass(UInputComponent::StaticClass()));
		FoundInputComponent = (InputComp != nullptr);
	}
}
