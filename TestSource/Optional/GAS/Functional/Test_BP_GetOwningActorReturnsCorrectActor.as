// Theme: Optional.GAS. WorldStory: UTestOwnerAttributes BP_GetOwningActor after register.
// C++: AngelscriptGASAttributeSetOverrideTests.cpp::BP_GetOwningActorReturnsCorrectActor
// Oracle: BP_GetOwningActor() == TestActor that owns the ASC.
// Extra: nullptr handle; empty sibling set; unowned set returns null.
// Isolation=none. Optional GAS plugin fixture. Runner owns spawn, ASC, register.

UCLASS()
class UTestOwnerAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Luck;
}

UCLASS()
class UTestOwnerAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestOwnerAttributes_NullDefault()
{
	UTestOwnerAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestOwnerAttributes_OwningActor(UTestOwnerAttributes Set, AActor ExpectedOwner)
{
	return Set.BP_GetOwningActor() == ExpectedOwner;
}

bool Observe_UTestOwnerAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}
