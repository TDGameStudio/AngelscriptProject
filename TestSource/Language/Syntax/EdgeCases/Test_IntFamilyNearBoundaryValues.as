// Theme: Language.Syntax.EdgeCases. WorldStory: int-family min+1 near-boundary storage.
// C++: AngelscriptCoverageIntPropertyTests.cpp::IntFamilyNearBoundaryValues
// sha256=f16d8d1f1d4bbc62060b86d5630b39be66764b0bf3aaca11bffa07514a176e87; lines 438-466.
// Oracle: Int8Value min+1; Int16Value min+1; IntValue min+1; Int64Value min+1 via SetByPath.
// Extra: local construct is empty 0; script WriteNearMins uses -127/-32767/-2147483647.
// FixtureIsolated. Actor owns the reflected integers.

UCLASS()
class ACoverageIntNearBoundaryActor : AActor
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
	void WriteNearMins()
	{
		Int8Value = -127;
		Int16Value = -32767;
		IntValue = -2147483647;
		Int64Value = -9223372036854775807;
	}
}

bool Observe_IntFamilyNearBoundary_DefaultEmpty(ACoverageIntNearBoundaryActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntFamilyNearBoundaryValues setup: required Actor is null");
	}
	return Actor.Int8Value == 0 && Actor.IntValue == 0 && Actor.UInt8Value == 0;
}

bool Observe_IntFamilyNearBoundary_Nominal(ACoverageIntNearBoundaryActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntFamilyNearBoundaryValues setup: required Actor is null");
	}
	Actor.WriteNearMins();
	return Actor.Int8Value == -127 && Actor.Int16Value == -32767 && Actor.IntValue == -2147483647;
}
