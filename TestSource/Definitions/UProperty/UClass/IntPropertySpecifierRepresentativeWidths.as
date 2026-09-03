/**
 * Specifier flags on int8/int16/int64/uint8/uint16/uint/uint64. C++ verifies
 * named properties by path, so those UPROPERTY names are kept. The observers
 * cover the empty int8 0 default and that EmptyInt8 is independent of
 * EditAnywhereInt8.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.IntPropertySpecifierRepresentativeWidths
 * @Harness UClass
 * @Tag Definitions.UProperty.IntPropertySpecifierRepresentativeWidths
 * @Provenance Theme: Definitions.UProperty. WorldStory: specifier flags on int8/int16/int64/uint8/uint16/uint/uint64.
 * @Provenance C++: EditAnywhereInt8 FInt8Property+CPF_Edit; BlueprintReadOnlyInt16 FInt16Property+BlueprintVisible/ReadOnly.
 * @Provenance Extra: EmptyInt8 defaults 0 independently of EditAnywhereInt8 1. FixtureIsolated.
 */

UCLASS()
class ACoverageIntSpecifierWidthsActor : AActor
{
	UPROPERTY(EditAnywhere)
	int8 EditAnywhereInt8 = 1;

	UPROPERTY(BlueprintReadOnly)
	int16 BlueprintReadOnlyInt16 = 2;

	UPROPERTY(NotEditable)
	int64 NotEditableInt64 = 3;

	UPROPERTY(Transient)
	uint8 TransientUInt8 = 4;

	UPROPERTY(SaveGame)
	uint16 SaveGameUInt16 = 5;

	UPROPERTY(meta = (ClampMin = "0", ClampMax = "4000000000"))
	uint ClampedUInt = 6;

	UPROPERTY(Category = "Coverage")
	uint64 CategorizedUInt64 = 7;

	UPROPERTY()
	int8 EmptyInt8 = 0;

	/**
	 * Observe the empty int8 default.
	 *
	 * @Kind Observe
	 * @Covers UProperty.IntPropertySpecifierRepresentativeWidths
	 * @Inputs none
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int IntWidthEmptyDefault()
	{
		return 0;
	}

	/**
	 * Observe that EmptyInt8 is independent of EditAnywhereInt8.
	 *
	 * @Kind Observe
	 * @Covers UProperty.IntPropertySpecifierRepresentativeWidths
	 * @Inputs local EditAnywhereInt8 1 and EmptyInt8 0
	 * @Return true when the two locals differ
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool IntWidthEmptyIndependentOfEditAnywhere()
	{
		int8 EditAnywhereInt8 = 1;
		int8 EmptyInt8 = 0;
		return EditAnywhereInt8 != EmptyInt8;
	}
}
