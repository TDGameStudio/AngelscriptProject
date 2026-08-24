// Theme: Gameplay.FRotator. WorldStory UPROPERTY declaration defaults.
// C++: AngelscriptCoverageFRotatorPropertyTests.cpp::FRotatorDeclarationDefaults
// Oracle VerifyByPath: ZeroRot 0,0,0; CustomRot 10,20,30; NoDefaultRot Pitch 0; PitchOnly 45.
// Extra: NoDefault Yaw/Roll 0. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoverageFRotatorDefaultsActor : AActor
{
	UPROPERTY()
	FRotator ZeroRot = FRotator::ZeroRotator;

	UPROPERTY()
	FRotator CustomRot = FRotator(10, 20, 30);

	UPROPERTY()
	FRotator NoDefaultRot;

	UPROPERTY()
	FRotator PitchOnly = FRotator(45, 0, 0);
}

bool Observe_ZeroRot(ACoverageFRotatorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FRotatorDeclarationDefaults setup: required Actor is null");
	}
	return Actor.ZeroRot.Pitch == 0.0 && Actor.ZeroRot.Yaw == 0.0 && Actor.ZeroRot.Roll == 0.0;
}

bool Observe_CustomRot(ACoverageFRotatorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FRotatorDeclarationDefaults setup: required Actor is null");
	}
	return Actor.CustomRot.Pitch == 10.0 && Actor.CustomRot.Yaw == 20.0 && Actor.CustomRot.Roll == 30.0;
}

bool Observe_NoDefaultRot(ACoverageFRotatorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FRotatorDeclarationDefaults setup: required Actor is null");
	}
	return Actor.NoDefaultRot.Pitch == 0.0;
}

bool Observe_PitchOnly(ACoverageFRotatorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FRotatorDeclarationDefaults setup: required Actor is null");
	}
	return Actor.PitchOnly.Pitch == 45.0;
}

bool Observe_NoDefaultRot_EmptyYawRoll(ACoverageFRotatorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FRotatorDeclarationDefaults setup: required Actor is null");
	}
	return Actor.NoDefaultRot.Yaw == 0.0 && Actor.NoDefaultRot.Roll == 0.0;
}

bool Observe_CustomRot_CopyIndependence(ACoverageFRotatorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FRotatorDeclarationDefaults setup: required Actor is null");
	}
	FRotator Copy = Actor.CustomRot;
	Copy.Pitch = 0.0;
	return Actor.CustomRot == FRotator(10, 20, 30);
}
