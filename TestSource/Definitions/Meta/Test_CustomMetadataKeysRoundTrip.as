// Theme: Definitions.Meta. WorldStory: custom meta keys round-trip on class, property, and function.
// C++: AngelscriptCoverageMacrosTests.cpp::CustomMetadataKeysRoundTrip
// Oracle: ReadValue() == 7 (ReflectedValue default). Extra: write 0; second instance stays 7 after spawn defaults.
// FixtureIsolated. Keep ReflectedValue for C++ metadata checks.

UCLASS(meta=(CoverageClassKey="ClassValue", DisplayName="Coverage Metadata Actor"))
class ACoverageMacrosMetadataActor : AActor
{
	UPROPERTY(meta=(CoveragePropertyKey="PropertyValue", ClampMin="1"))
	int ReflectedValue = 7;

	UFUNCTION(BlueprintCallable, meta=(CoverageFunctionKey="FunctionValue", Keywords="coverage metadata"))
	int ReadValue() const
	{
		return ReflectedValue;
	}
}

int Observe_CustomMetadata_ReadValue(ACoverageMacrosMetadataActor Actor)
{
	return Actor.ReadValue();
}

int Observe_CustomMetadata_ZeroBoundary(ACoverageMacrosMetadataActor Actor)
{
	Actor.ReflectedValue = 0;
	return Actor.ReadValue();
}

int Observe_CustomMetadata_EmptyDefaultIsNull()
{
	ACoverageMacrosMetadataActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
