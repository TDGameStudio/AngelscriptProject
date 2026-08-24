// Theme: Language.Syntax.EdgeCases. C++ compiles and VerifyByPath zero/explicit defaults.
// CSV SourceShape NegativeDiagnostic is wrong; follow IntFamilyImplicitAndExplicitZeroDefaults.
// C++: AngelscriptCoverageIntPropertyTests.cpp::IntFamilyImplicitAndExplicitZeroDefaults
// sha256=3cecca9785f13efa4eb190faacc32feea5a0a40f6e865a937a0a286b9bb8c76b; lines 163-203.
// Oracle: all NoDefault* fields are 0; ExplicitZero 0; NegativeDefault -100;
// LargeDefault 2147483647; LargeUnsignedDefault 18000000000000000000.
// Extra: local construct is the empty implicit-zero vector.
// FixtureIsolated. Actor owns the reflected integers.

UCLASS()
class ACoverageIntZeroDefaultsActor : AActor
{
	UPROPERTY()
	int8 NoDefaultInt8;

	UPROPERTY()
	int16 NoDefaultInt16;

	UPROPERTY()
	int NoDefaultInt;

	UPROPERTY()
	int64 NoDefaultInt64;

	UPROPERTY()
	uint8 NoDefaultUInt8;

	UPROPERTY()
	uint16 NoDefaultUInt16;

	UPROPERTY()
	uint NoDefaultUInt;

	UPROPERTY()
	uint64 NoDefaultUInt64;

	UPROPERTY()
	int ExplicitZero = 0;

	UPROPERTY()
	int8 NegativeDefault = -100;

	UPROPERTY()
	int LargeDefault = 2147483647;

	UPROPERTY()
	uint64 LargeUnsignedDefault = 18000000000000000000;
}

bool Observe_IntFamilyZeroDefaults_ImplicitEmpty(ACoverageIntZeroDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntFamilyImplicitAndExplicitZeroDefaults setup: required Actor is null");
	}
	return Actor.NoDefaultInt8 == 0
		&& Actor.NoDefaultInt16 == 0
		&& Actor.NoDefaultInt == 0
		&& Actor.NoDefaultInt64 == 0
		&& Actor.NoDefaultUInt8 == 0
		&& Actor.NoDefaultUInt16 == 0
		&& Actor.NoDefaultUInt == 0
		&& Actor.NoDefaultUInt64 == 0
		&& Actor.ExplicitZero == 0;
}

bool Observe_IntFamilyZeroDefaults_ExplicitBoundary(ACoverageIntZeroDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntFamilyImplicitAndExplicitZeroDefaults setup: required Actor is null");
	}
	return Actor.NegativeDefault == -100
		&& Actor.LargeDefault == 2147483647
		&& Actor.LargeUnsignedDefault == 18000000000000000000;
}
