// Theme: Optional.GAS. WorldStory: UTestPostInitAttributes Charisma AttributeName after PostInit.
// C++: AngelscriptGASAttributeSetOverrideTests.cpp::PostInitPropertiesSetsAttributeName
// Oracle: AttrData->AttributeName == FName("Charisma") on NewObject instance.
// Extra: nullptr handle; default FAngelscriptGameplayAttributeData AttributeName is None.
// Isolation=none. Optional GAS plugin fixture. Runner owns NewObject of the script class.

UCLASS()
class UTestPostInitAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Charisma;
}

UCLASS()
class UTestPostInitAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestPostInitAttributes_NullDefault()
{
	UTestPostInitAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestPostInitAttributes_CharismaName(UTestPostInitAttributes Set)
{
	return Set.Charisma.AttributeName == n"Charisma";
}

bool Observe_UTestPostInitAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}
