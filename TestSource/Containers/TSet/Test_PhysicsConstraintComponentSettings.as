// Theme: Containers.TSet. WorldStory: UPhysicsConstraintComponent limits and break.
// C++: AngelscriptCoveragePhysicsTests.cpp::PhysicsConstraintComponentSettings
// CompileScriptModule + spawn + BeginPlay. Oracle: ConstrainedComponentsSet, LinearLimitsSet,
// AngularLimitsSet, LinearDriveSet, ConstraintBroken all true.
// Extra: local construct leaves flags false.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoveragePhysicsConstraintActor : AActor
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
	bool ConstrainedComponentsSet = false;

	UPROPERTY()
	bool LinearLimitsSet = false;

	UPROPERTY()
	bool AngularLimitsSet = false;

	UPROPERTY()
	bool LinearDriveSet = false;

	UPROPERTY()
	bool ConstraintBroken = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BodyA.SetSimulatePhysics(true);
		BodyB.SetSimulatePhysics(true);
		Constraint.SetConstrainedComponents(BodyA, NAME_None, BodyB, NAME_None);

		UPrimitiveComponent OutA;
		FName BoneA;
		UPrimitiveComponent OutB;
		FName BoneB;
		Constraint.GetConstrainedComponents(OutA, BoneA, OutB, BoneB);
		ConstrainedComponentsSet = OutA == BodyA && OutB == BodyB;

		Constraint.SetLinearXLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetLinearYLimit(ELinearConstraintMotion::LCM_Limited, 25.0f);
		Constraint.SetLinearZLimit(ELinearConstraintMotion::LCM_Free, 0.0f);
		LinearLimitsSet = true;

		Constraint.SetAngularSwing1Limit(EAngularConstraintMotion::ACM_Limited, 45.0f);
		Constraint.SetAngularSwing2Limit(EAngularConstraintMotion::ACM_Locked, 0.0f);
		Constraint.SetAngularTwistLimit(EAngularConstraintMotion::ACM_Free, 0.0f);
		AngularLimitsSet = true;

		Constraint.SetLinearPositionDrive(true, false, true);
		Constraint.SetLinearPositionTarget(FVector(5.0f, 0.0f, 10.0f));
		LinearDriveSet = true;

		Constraint.BreakConstraint();
		ConstraintBroken = true;
	}
}

bool Observe_PhysicsConstraint_DefaultEmpty(ACoveragePhysicsConstraintActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PhysicsConstraintComponentSettings setup: required Actor is null");
	}
	return Actor.ConstrainedComponentsSet == false
		&& Actor.LinearLimitsSet == false
		&& Actor.AngularLimitsSet == false
		&& Actor.LinearDriveSet == false
		&& Actor.ConstraintBroken == false;
}

bool Observe_PhysicsConstraint_CopyIndependence(ACoveragePhysicsConstraintActor First, ACoveragePhysicsConstraintActor Second)
{
	if (First is null)
	{
		throw("Test_PhysicsConstraintComponentSettings setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_PhysicsConstraintComponentSettings setup: required Second is null");
	}
	First.LinearLimitsSet = true;
	return First.LinearLimitsSet == true && Second.LinearLimitsSet == false && Second.ConstraintBroken == false;
}
