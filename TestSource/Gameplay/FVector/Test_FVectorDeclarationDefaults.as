// Theme: Gameplay.FVector. WorldStory declaration defaults after spawn.
// C++: AngelscriptCoverageFVectorPropertyTests.cpp::FVectorDeclarationDefaults
// Oracle VerifyByPath: ZeroVec (0,0,0); OneVec (1,1,1); CustomVec (1,2,3);
// NoDefaultVec.X 0; UpVec (0,0,1). Extra: NoDefaultVec empty zero.
// FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoverageFVectorDefaultsActor : AActor
{
	UPROPERTY()
	FVector ZeroVec = FVector::ZeroVector;

	UPROPERTY()
	FVector OneVec = FVector::OneVector;

	UPROPERTY()
	FVector CustomVec = FVector(1, 2, 3);

	UPROPERTY()
	FVector NoDefaultVec;

	UPROPERTY()
	FVector UpVec = FVector::UpVector;
}

bool Observe_ZeroVec(ACoverageFVectorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVectorDeclarationDefaults setup: required Actor is null");
	}
	return Actor.ZeroVec.X == 0.0 && Actor.ZeroVec.Y == 0.0 && Actor.ZeroVec.Z == 0.0;
}

bool Observe_OneVec(ACoverageFVectorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVectorDeclarationDefaults setup: required Actor is null");
	}
	return Actor.OneVec.X == 1.0 && Actor.OneVec.Y == 1.0 && Actor.OneVec.Z == 1.0;
}

bool Observe_CustomVec(ACoverageFVectorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVectorDeclarationDefaults setup: required Actor is null");
	}
	return Actor.CustomVec.X == 1.0 && Actor.CustomVec.Y == 2.0 && Actor.CustomVec.Z == 3.0;
}

bool Observe_NoDefaultVec_EmptyZero(ACoverageFVectorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVectorDeclarationDefaults setup: required Actor is null");
	}
	return Actor.NoDefaultVec.X == 0.0;
}

bool Observe_UpVec(ACoverageFVectorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVectorDeclarationDefaults setup: required Actor is null");
	}
	return Actor.UpVec.X == 0.0 && Actor.UpVec.Y == 0.0 && Actor.UpVec.Z == 1.0;
}

bool Observe_CustomVec_CopyIndependence(ACoverageFVectorDefaultsActor First, ACoverageFVectorDefaultsActor Second)
{
	if (First is null)
	{
		throw("Test_FVectorDeclarationDefaults setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_FVectorDeclarationDefaults setup: required Second is null");
	}
	First.CustomVec.X = 0.0;
	return First.CustomVec.X == 0.0 && Second.CustomVec.X == 1.0;
}
