// Theme: Definitions.UProperty. WorldStory: specifier flags on int8/int16/int64/uint8/uint16/uint/uint64.
// C++: EditAnywhereInt8 FInt8Property+CPF_Edit; BlueprintReadOnlyInt16 FInt16Property+BlueprintVisible/ReadOnly.
// Extra: EmptyInt8 defaults 0 independently of EditAnywhereInt8 1. FixtureIsolated.

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
}

int Observe_IntWidth_EmptyDefault()
{
	return 0;
}

bool Observe_IntWidth_EmptyIndependentOfEditAnywhere()
{
	int8 EditAnywhereInt8 = 1;
	int8 EmptyInt8 = 0;
	return EditAnywhereInt8 != EmptyInt8;
}
