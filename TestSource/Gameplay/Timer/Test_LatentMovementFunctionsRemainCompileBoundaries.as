// Theme: Gameplay.Timer. Isolated compile-fail: latent MoveComponentTo and RotatorTo
// remain compile boundaries until deterministic latent advance exists.
// C++: AngelscriptCoverageTimerTests.cpp::LatentMovementFunctionsRemainCompileBoundaries
// CompileAndExpectFailure. CSV WorldStory; C++ does not compile.
// Diagnostics: MoveComponentTo, RotatorTo.
// Do not add extra declarations that would make this compile.

UCLASS()
class ACoverageTimerLatentMovementBoundaryActor : AActor
{
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MoveComponentTo(nullptr, FVector::ZeroVector, FRotator::ZeroRotator, false, false, 0.25f, false, EMoveComponentAction::Move);
		RotatorTo(FRotator::ZeroRotator, FRotator(0.0f, 90.0f, 0.0f), 0.25f, 0.0f);
	}
}
