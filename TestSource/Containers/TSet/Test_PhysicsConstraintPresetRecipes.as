// Theme: Containers.TSet. WorldStory: hinge / prismatic / ball-socket / fixed recipes.
// C++: AngelscriptCoveragePhysicsTests.cpp::PhysicsConstraintPresetRecipes
// CompileScriptModule + spawn + BeginPlay. Oracle: Hinge/Prismatic/BallSocket/Fixed/DriveTargets
// configured flags all true.
// Extra: local construct leaves flags false; instances do not share flags.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoveragePhysicsConstraintPresetRecipesActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USphereComponent BodyA;

	UPROPERTY(DefaultComponent, Attach=Root)
	USphereComponent BodyB;

	UPROPERTY(DefaultComponent, Attach=Root)
	UPhysicsConstraintComponent Constraint;

	UPROPERTY()
	bool HingeRecipeConfigured = false;

	UPROPERTY()
	bool PrismaticRecipeConfigured = false;

	UPROPERTY()
	bool BallSocketRecipeConfigured = false;

	UPROPERTY()
	bool FixedRecipeConfigured = false;

	UPROPERTY()
	bool DriveTargetsConfigured = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Constraint.SetConstrainedComponents(BodyA, NAME_None, BodyB, NAME_None);

		Constraint.SetLinearXLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetLinearYLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetLinearZLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetAngularSwing1Limit(EAngularConstraintMotion::ACM_Locked, 0.0f);
		Constraint.SetAngularSwing2Limit(EAngularConstraintMotion::ACM_Locked, 0.0f);
		Constraint.SetAngularTwistLimit(EAngularConstraintMotion::ACM_Free, 0.0f);
		HingeRecipeConfigured = true;

		Constraint.SetLinearXLimit(ELinearConstraintMotion::LCM_Limited, 40.0f);
		Constraint.SetLinearYLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetLinearZLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetAngularSwing1Limit(EAngularConstraintMotion::ACM_Locked, 0.0f);
		Constraint.SetAngularSwing2Limit(EAngularConstraintMotion::ACM_Locked, 0.0f);
		Constraint.SetAngularTwistLimit(EAngularConstraintMotion::ACM_Locked, 0.0f);
		PrismaticRecipeConfigured = true;

		Constraint.SetLinearXLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetLinearYLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetLinearZLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetAngularSwing1Limit(EAngularConstraintMotion::ACM_Limited, 35.0f);
		Constraint.SetAngularSwing2Limit(EAngularConstraintMotion::ACM_Limited, 35.0f);
		Constraint.SetAngularTwistLimit(EAngularConstraintMotion::ACM_Limited, 20.0f);
		BallSocketRecipeConfigured = true;

		Constraint.SetLinearXLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetLinearYLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetLinearZLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetAngularSwing1Limit(EAngularConstraintMotion::ACM_Locked, 0.0f);
		Constraint.SetAngularSwing2Limit(EAngularConstraintMotion::ACM_Locked, 0.0f);
		Constraint.SetAngularTwistLimit(EAngularConstraintMotion::ACM_Locked, 0.0f);
		FixedRecipeConfigured = true;

		Constraint.SetLinearPositionDrive(true, true, true);
		Constraint.SetLinearPositionTarget(FVector(10.0f, 20.0f, 30.0f));
		DriveTargetsConfigured = true;
	}
}

bool Observe_ConstraintRecipes_DefaultEmpty(ACoveragePhysicsConstraintPresetRecipesActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PhysicsConstraintPresetRecipes setup: required Actor is null");
	}
	return Actor.HingeRecipeConfigured == false
		&& Actor.PrismaticRecipeConfigured == false
		&& Actor.BallSocketRecipeConfigured == false
		&& Actor.FixedRecipeConfigured == false
		&& Actor.DriveTargetsConfigured == false;
}

bool Observe_ConstraintRecipes_CopyIndependence(ACoveragePhysicsConstraintPresetRecipesActor First, ACoveragePhysicsConstraintPresetRecipesActor Second)
{
	if (First is null)
	{
		throw("Test_PhysicsConstraintPresetRecipes setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_PhysicsConstraintPresetRecipes setup: required Second is null");
	}
	First.HingeRecipeConfigured = true;
	return First.HingeRecipeConfigured == true && Second.HingeRecipeConfigured == false;
}
