// Theme: Optional.GAS. WorldStory: UTestNoASCOwnerAttributes unowned NewObject.
// C++: AngelscriptGASAttributeSetOverrideTests.cpp::BP_GetOwningActorReturnsNullWithoutASC
// Oracle: BP_GetOwningActor() is null when the set has no owning ASC.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns unowned NewObject set.

UCLASS()
class UTestNoASCOwnerAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Temp;
}

UCLASS()
class UTestNoASCOwnerAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestNoASCOwnerAttributes_NullDefault()
{
	UTestNoASCOwnerAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestNoASCOwnerAttributes_UnownedOwnerIsNull(UTestNoASCOwnerAttributes Set)
{
	return Set.BP_GetOwningActor() == nullptr;
}

bool Observe_UTestNoASCOwnerAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}
