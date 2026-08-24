// Theme: Optional.GAS. WorldStory: UTestMultiNameAttributes Attack/Defense/Speed names.
// C++: AngelscriptGASAttributeSetOverrideTests.cpp::MultipleAttributeFieldsGetCorrectNames
// Oracle: each field AttributeName matches Attack, Defense, Speed after PostInit.
// Extra: nullptr handle; default FAngelscriptGameplayAttributeData AttributeName is None.
// Isolation=none. Optional GAS plugin fixture. Runner owns NewObject of the script class.

UCLASS()
class UTestMultiNameAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Attack;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Defense;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Speed;
}

UCLASS()
class UTestMultiNameAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestMultiNameAttributes_NullDefault()
{
	UTestMultiNameAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestMultiNameAttributes_FieldNames(UTestMultiNameAttributes Set)
{
	return Set.Attack.AttributeName == n"Attack"
		&& Set.Defense.AttributeName == n"Defense"
		&& Set.Speed.AttributeName == n"Speed";
}

bool Observe_UTestMultiNameAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}
