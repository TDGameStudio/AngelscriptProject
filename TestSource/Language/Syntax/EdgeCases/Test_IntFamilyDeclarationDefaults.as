// Theme: Language.Syntax.EdgeCases. WorldStory: int-family UPROPERTY declaration defaults.
// C++: AngelscriptCoverageIntPropertyTests.cpp::IntFamilyDeclarationDefaults VerifyByPath
// sha256=26cb9c5e99174c9e7bc4631183a724f57afa1b9cecf45781a3f8f242137485e7; lines 90-118.
// Oracle: Int8Value 100; Int16Value 30000; IntValue 123456; Int64Value 10000000000;
// UInt8Value 250; UInt16Value 60000; UInt32Value 123456; UInt64Value 123456.
// Extra: local construct reads the same CDO defaults (BeginPlay not required).
// FixtureIsolated. Actor owns the reflected integers.

UCLASS()
class ACoverageIntDefaultsActor : AActor
{
	UPROPERTY()
	int8 Int8Value = 100;

	UPROPERTY()
	int16 Int16Value = 30000;

	UPROPERTY()
	int IntValue = 123456;

	UPROPERTY()
	int64 Int64Value = 10000000000;

	UPROPERTY()
	uint8 UInt8Value = 250;

	UPROPERTY()
	uint16 UInt16Value = 60000;

	UPROPERTY()
	uint UInt32Value = 123456;

	UPROPERTY()
	uint64 UInt64Value = 123456;
}

bool Observe_IntFamilyDeclarationDefaults_Nominal(ACoverageIntDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntFamilyDeclarationDefaults setup: required Actor is null");
	}
	return Actor.Int8Value == 100
		&& Actor.Int16Value == 30000
		&& Actor.IntValue == 123456
		&& Actor.Int64Value == 10000000000
		&& Actor.UInt8Value == 250
		&& Actor.UInt16Value == 60000
		&& Actor.UInt32Value == 123456
		&& Actor.UInt64Value == 123456;
}
