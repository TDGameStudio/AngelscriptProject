// Theme: Optional.GAS. WorldStory: script UAngelscriptAttributeSet subclass registers
// Health, MaxHealth, Stamina and inherits OnRep_Attribute.
// C++: AngelscriptGASScriptAttributeSetTests.cpp::SubclassRegistersAttributeFieldsAndOnRepFunction
// sha256=34ccc9404e892ea0a225818650390ad766dfbd3c7272633fdcdf45b9a64d5157; lines 44-57.
// Oracle: class is a child of UAngelscriptAttributeSet; Health / MaxHealth / Stamina are
// FStructProperty holding FAngelscriptGameplayAttributeData; OnRep_Attribute is inherited.
// Extra: unset set handle is null; default FAngelscriptGameplayAttributeData AttributeName is None.
// FixtureIsolated. Runner owns module teardown. Do not spawn from script.

UCLASS()
class UFunctionalCharacterAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Health;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData MaxHealth;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Stamina;
}

bool Observe_SubclassRegistersAttributeFieldsAndOnRepFunction_DefaultEmpty()
{
	UFunctionalCharacterAttributes Unset;
	FAngelscriptGameplayAttributeData EmptyHealth;
	FAngelscriptGameplayAttributeData EmptyMaxHealth;
	FAngelscriptGameplayAttributeData EmptyStamina;
	return Unset == nullptr
		&& EmptyHealth.AttributeName.IsNone()
		&& EmptyMaxHealth.AttributeName.IsNone()
		&& EmptyStamina.AttributeName.IsNone();
}

bool Observe_SubclassRegistersAttributeFieldsAndOnRepFunction_CopyIndependence()
{
	UFunctionalCharacterAttributes First;
	UFunctionalCharacterAttributes Second;
	FAngelscriptGameplayAttributeData Copied;
	First = Second;
	return First == Second
		&& First == nullptr
		&& Copied.AttributeName.IsNone();
}
