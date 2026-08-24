// Theme: Language.Syntax.EdgeCases. WorldStory: script read/write of int-family UPROPERTY.
// C++: AngelscriptCoverageIntPropertyTests.cpp::IntPropertyScriptReadWriteApiSurface
// sha256=fd4267603cebc992e21bb61ccd69b680a5a91e0990de19852cd7acba589acdd2; lines 1489-1538.
// Oracle: ReadCurrentSum()==16; RewriteAndReadCurrentSum()==0 then Int8Value -8 ... UInt64Value 64.
// Extra: local construct is the default sum 16 without rewrite.
// FixtureIsolated. Actor owns the integers; RewriteAndReadCurrentSum mutates in place.

UCLASS()
class ACoverageIntScriptApiSurfaceActor : AActor
{
	UPROPERTY()
	int8 Int8Value = -1;

	UPROPERTY()
	int16 Int16Value = -2;

	UPROPERTY()
	int IntValue = -3;

	UPROPERTY()
	int64 Int64Value = -4;

	UPROPERTY()
	uint8 UInt8Value = 5;

	UPROPERTY()
	uint16 UInt16Value = 6;

	UPROPERTY()
	uint UIntValue = 7;

	UPROPERTY()
	uint64 UInt64Value = 8;

	UFUNCTION()
	int ReadCurrentSum()
	{
		return int(Int8Value) + int(Int16Value) + IntValue + int(Int64Value)
			+ int(UInt8Value) + int(UInt16Value) + int(UIntValue) + int(UInt64Value);
	}

	UFUNCTION()
	int RewriteAndReadCurrentSum()
	{
		Int8Value = -8;
		Int16Value = -16;
		IntValue = -32;
		Int64Value = -64;
		UInt8Value = 8;
		UInt16Value = 16;
		UIntValue = 32;
		UInt64Value = 64;
		return ReadCurrentSum();
	}
}

int Observe_IntPropertyScriptApi_DefaultSum(ACoverageIntScriptApiSurfaceActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntPropertyScriptReadWriteApiSurface setup: required Actor is null");
	}
	return Actor.ReadCurrentSum();
}

bool Observe_IntPropertyScriptApi_Rewrite(ACoverageIntScriptApiSurfaceActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntPropertyScriptReadWriteApiSurface setup: required Actor is null");
	}
	int After = Actor.RewriteAndReadCurrentSum();
	return After == 0 && Actor.Int8Value == -8 && Actor.UInt64Value == 64;
}
