// Theme: Language.Syntax.EdgeCases. WorldStory FQuat UPROPERTY default materialization.
// C++: AngelscriptCoverageFQuatPropertyTests.cpp::FQuatDeclarationDefaults
// sha256=1e3daff9e47c667b507db90e2f756daf735901b5c66beb81f499a045fee14b09; lines 134-150.
// Oracle: IdentityQuat XYZ=0 W=1; constructor-expression CustomQuat/FromRotator currently
// materialize as Identity (W=1, Z=0); NoDefaultQuat is Identity. Extra: local construct.
// FixtureIsolated. Keep the C++ VerifyByPath field names.

UCLASS()
class ACoverageFQuatDefaultsActor : AActor
{
	UPROPERTY()
	FQuat IdentityQuat = FQuat::Identity;

	UPROPERTY()
	FQuat CustomQuat = FQuat(0, 0, 0.707107, 0.707107);

	UPROPERTY()
	FQuat NoDefaultQuat;

	UPROPERTY()
	FQuat FromRotator = FQuat(FRotator(0, 90, 0));
}

bool Observe_FQuatDefaults_Identity(ACoverageFQuatDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FQuatDeclarationDefaults setup: required Actor is null");
	}
	return Math::IsNearlyEqual(Actor.IdentityQuat.X, 0.0) && Math::IsNearlyEqual(Actor.IdentityQuat.Y, 0.0) && Math::IsNearlyEqual(Actor.IdentityQuat.Z, 0.0) && Math::IsNearlyEqual(Actor.IdentityQuat.W, 1.0);
}

bool Observe_FQuatDefaults_NoDefaultEmpty(ACoverageFQuatDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FQuatDeclarationDefaults setup: required Actor is null");
	}
	return Math::IsNearlyEqual(Actor.NoDefaultQuat.X, 0.0) && Math::IsNearlyEqual(Actor.NoDefaultQuat.W, 1.0);
}
