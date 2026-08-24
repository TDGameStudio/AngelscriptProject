// Theme: World.Component. CSV WorldStory; C++ CompileAndExpectFailure.
// Isolated failing program: FindComponentByClass(UClass) is unavailable.
// C++: AngelscriptCoverageInputTests.cpp::InputComponentFinding
// sha256=52a30413afe6b1ec398290c0eca835854be1d71217ad394c7493cdbeb7e89d6e; lines 957-971.
// Expected diagnostic: No matching signatures to 'FindComponentByClass(UClass)'.
// Do not add extra declarations that would compile this away.

UCLASS()
class AInputComponentFindingPawn : APawn
{
	UPROPERTY()
	bool FoundInputComponent = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Expected diagnostic: No matching signatures to 'FindComponentByClass(UClass)'
		UInputComponent InputComp = Cast<UInputComponent>(FindComponentByClass(UInputComponent::StaticClass()));
		FoundInputComponent = (InputComp != nullptr);
	}
}
