/**
 * Custom meta keys round-trip on the class, a property and a function. C++ reads
 * CoverageClassKey, CoveragePropertyKey and CoverageFunctionKey. The observers
 * cover ReadValue, a zero write and a null default handle.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.CustomMetadataKeysRoundTrip
 * @Harness UClass
 * @Tag Definitions.Meta.CustomMetadataKeysRoundTrip
 * @Provenance Theme: Definitions.Meta. WorldStory: custom meta keys round-trip on class, property, and function.
 * @Provenance C++: AngelscriptCoverageMacrosTests.cpp::CustomMetadataKeysRoundTrip
 * @Provenance Oracle: ReadValue() == 7 (ReflectedValue default). Extra: write 0; second instance stays 7 after spawn defaults.
 * @Provenance FixtureIsolated. Keep ReflectedValue for C++ metadata checks.
 */

UCLASS(meta=(CoverageClassKey="ClassValue", DisplayName="Coverage Metadata Actor"))
class ACoverageMacrosMetadataActor : AActor
{
	UPROPERTY(meta=(CoveragePropertyKey="PropertyValue", ClampMin="1"))
	int ReflectedValue = 7;

	/**
	 * Return the reflected property through the annotated function.
	 *
	 * @Kind Observe
	 * @Covers Meta.CustomMetadataKeysRoundTrip
	 * @Inputs none
	 * @Return ReflectedValue
	 */
	UFUNCTION(BlueprintCallable, meta=(CoverageFunctionKey="FunctionValue", Keywords="coverage metadata"))
	int ReadValue() const
	{
		return ReflectedValue;
	}

	/**
	 * Observe that ReadValue reports the declared default.
	 *
	 * @Kind Observe
	 * @Covers Meta.CustomMetadataKeysRoundTrip
	 * @Inputs none
	 * @Return 7
	 */
	UFUNCTION()
	int ReadValueDefault()
	{
		return ReadValue();
	}

	/**
	 * Observe that writing zero still reads back through ReadValue.
	 *
	 * @Kind Observe
	 * @Covers Meta.CustomMetadataKeysRoundTrip
	 * @Inputs none
	 * @Return 0
	 * @Boundary zero write
	 */
	UFUNCTION()
	int ZeroBoundary()
	{
		ReflectedValue = 0;
		return ReadValue();
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Meta.CustomMetadataKeysRoundTrip
	 * @Inputs an unset actor handle
	 * @Return 1 when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptyDefaultIsNull()
	{
		ACoverageMacrosMetadataActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
