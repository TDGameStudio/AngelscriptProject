// Theme: Language.Syntax.EdgeCases. WorldStory: int-family SetByPath/VerifyByPath round trip.
// C++: AngelscriptCoverageIntPropertyTests.cpp::IntFamilyWriteRoundTrip
// sha256=26708c798096ff29e6d6da8c8d58310df66aff38bcc1850cedc49028b236a539; lines 255-283.
// Oracle after SetByPath: Int8Value -42; Int16Value -12345; IntValue -987654;
// Int64Value -9000000000; UInt8Value 200; UInt16Value 54321; UInt32Value 3000000000;
// UInt64Value 12000000000000000000.
// Extra: local construct keeps every field 0; script assignment is copy-independent of C++ SetByPath.
// FixtureIsolated. Actor owns the reflected integers.

UCLASS()
class ACoverageIntRoundTripActor : AActor
{
	UPROPERTY()
	int8 Int8Value = 0;

	UPROPERTY()
	int16 Int16Value = 0;

	UPROPERTY()
	int IntValue = 0;

	UPROPERTY()
	int64 Int64Value = 0;

	UPROPERTY()
	uint8 UInt8Value = 0;

	UPROPERTY()
	uint16 UInt16Value = 0;

	UPROPERTY()
	uint UInt32Value = 0;

	UPROPERTY()
	uint64 UInt64Value = 0;

	UFUNCTION()
	void WriteRoundTripValues()
	{
		Int8Value = -42;
		Int16Value = -12345;
		IntValue = -987654;
		Int64Value = -9000000000;
		UInt8Value = 200;
		UInt16Value = 54321;
		UInt32Value = 3000000000;
		UInt64Value = 12000000000000000000;
	}
}

bool Observe_IntFamilyWriteRoundTrip_DefaultEmpty(ACoverageIntRoundTripActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntFamilyWriteRoundTrip setup: required Actor is null");
	}
	return Actor.Int8Value == 0
		&& Actor.Int16Value == 0
		&& Actor.IntValue == 0
		&& Actor.Int64Value == 0
		&& Actor.UInt8Value == 0
		&& Actor.UInt16Value == 0
		&& Actor.UInt32Value == 0
		&& Actor.UInt64Value == 0;
}

bool Observe_IntFamilyWriteRoundTrip_Nominal(ACoverageIntRoundTripActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntFamilyWriteRoundTrip setup: required Actor is null");
	}
	Actor.WriteRoundTripValues();
	return Actor.Int8Value == -42
		&& Actor.Int16Value == -12345
		&& Actor.IntValue == -987654
		&& Actor.Int64Value == -9000000000
		&& Actor.UInt8Value == 200
		&& Actor.UInt16Value == 54321
		&& Actor.UInt32Value == 3000000000
		&& Actor.UInt64Value == 12000000000000000000;
}
