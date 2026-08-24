// Theme: Optional.GAS. WorldStory: UTestActorInfoAttributes BP_GetActorInfo after init.
// C++: AngelscriptGASAttributeSetOverrideTests.cpp::BP_GetActorInfoReturnsValidAfterInit
// Oracle: BP_GetActorInfo().OwnerActor == TestActor.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns ASC InitAbilityActorInfo.

UCLASS()
class UTestActorInfoAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Vitality;
}

UCLASS()
class UTestActorInfoAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestActorInfoAttributes_NullDefault()
{
	UTestActorInfoAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestActorInfoAttributes_OwnerActor(UTestActorInfoAttributes Set, AActor ExpectedOwner)
{
	FGameplayAbilityActorInfo ActorInfo = Set.BP_GetActorInfo();
	return ActorInfo.OwnerActor == ExpectedOwner;
}

bool Observe_UTestActorInfoAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}
