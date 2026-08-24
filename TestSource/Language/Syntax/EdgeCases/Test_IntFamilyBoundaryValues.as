// Theme: Language.Syntax.EdgeCases. WorldStory: int-family numeric min/max storage.
// C++: AngelscriptCoverageIntPropertyTests.cpp::IntFamilyBoundaryValues SetByPath/VerifyByPath
// sha256=96d736167c58657e45b3485264e48e92b66299bb3cd45dbaee861fef46571084; lines 341-369.
// Oracle: signed mins then signed maxes then unsigned maxes survive reflection.
// Extra: local construct is the empty 0 vector; script WriteMin/WriteMax match C++ limits.
// FixtureIsolated. Actor owns the reflected integers.

UCLASS()
class ACoverageIntBoundaryActor : AActor
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
	void WriteSignedMins()
	{
		Int8Value = -128;
		Int16Value = -32768;
		IntValue = -2147483647 - 1;
		Int64Value = int64(-9223372036854775807) - 1;
	}

	UFUNCTION()
	void WriteSignedMaxes()
	{
		Int8Value = 127;
		Int16Value = 32767;
		IntValue = 2147483647;
		Int64Value = 9223372036854775807;
	}

	UFUNCTION()
	void WriteUnsignedMaxes()
	{
		UInt8Value = 255;
		UInt16Value = 65535;
		UInt32Value = 4294967295;
		UInt64Value = 18446744073709551615;
	}
}

bool Observe_IntFamilyBoundary_DefaultEmpty(ACoverageIntBoundaryActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntFamilyBoundaryValues setup: required Actor is null");
	}
	return Actor.Int8Value == 0 && Actor.UInt64Value == 0;
}

bool Observe_IntFamilyBoundary_SignedMins(ACoverageIntBoundaryActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntFamilyBoundaryValues setup: required Actor is null");
	}
	Actor.WriteSignedMins();
	return Actor.Int8Value == -128 && Actor.Int16Value == -32768 && Actor.IntValue == -2147483647 - 1;
}

bool Observe_IntFamilyBoundary_UnsignedMaxes(ACoverageIntBoundaryActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntFamilyBoundaryValues setup: required Actor is null");
	}
	Actor.WriteUnsignedMaxes();
	return Actor.UInt8Value == 255 && Actor.UInt16Value == 65535 && Actor.UInt32Value == 4294967295;
}
