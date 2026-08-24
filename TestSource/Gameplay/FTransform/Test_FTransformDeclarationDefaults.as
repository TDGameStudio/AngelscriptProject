// Theme: Gameplay.FTransform. WorldStory declaration defaults after spawn.
// C++: AngelscriptCoverageFTransformPropertyTests.cpp::FTransformDeclarationDefaults
// Oracle VerifyByPath: IdentityTransform translation 0 and Scale3D 1;
// CustomTransform/FullTransform/NoDefaultTransform also materialize as identity
// on reflected properties (non-identity declaration initializers are a spawn
// boundary). Extra: NoDefaultTransform empty identity. FixtureIsolated.
// Keep UPROPERTY names.

UCLASS()
class ACoverageFTransformDefaultsActor : AActor
{
	UPROPERTY()
	FTransform IdentityTransform = FTransform::Identity;

	UPROPERTY()
	FTransform CustomTransform = FTransform(FVector(100, 200, 300));

	UPROPERTY()
	FTransform NoDefaultTransform;

	UPROPERTY()
	FTransform FullTransform = FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 2, 2));
}

bool Observe_IdentityTransform_Spawned(ACoverageFTransformDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FTransformDeclarationDefaults setup: required Actor is null");
	}
	return Actor.IdentityTransform.GetLocation().X == 0.0
		&& Actor.IdentityTransform.GetLocation().Y == 0.0
		&& Actor.IdentityTransform.GetLocation().Z == 0.0
		&& Actor.IdentityTransform.GetScale3D().X == 1.0
		&& Actor.IdentityTransform.GetScale3D().Y == 1.0
		&& Actor.IdentityTransform.GetScale3D().Z == 1.0;
}

bool Observe_NoDefaultTransform_EmptyIdentity(ACoverageFTransformDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FTransformDeclarationDefaults setup: required Actor is null");
	}
	return Actor.NoDefaultTransform.GetLocation().X == 0.0
		&& Actor.NoDefaultTransform.GetScale3D().X == 1.0;
}

bool Observe_CustomAndFull_SpawnedIdentityBoundary(ACoverageFTransformDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FTransformDeclarationDefaults setup: required Actor is null");
	}
	return Actor.CustomTransform.GetLocation().X == 0.0
		&& Actor.CustomTransform.GetLocation().Y == 0.0
		&& Actor.CustomTransform.GetLocation().Z == 0.0
		&& Actor.CustomTransform.GetScale3D().X == 1.0
		&& Actor.FullTransform.GetLocation().X == 0.0
		&& Actor.FullTransform.GetLocation().Y == 0.0
		&& Actor.FullTransform.GetLocation().Z == 0.0
		&& Actor.FullTransform.GetScale3D().X == 1.0
		&& Actor.FullTransform.GetScale3D().Y == 1.0
		&& Actor.FullTransform.GetScale3D().Z == 1.0;
}
