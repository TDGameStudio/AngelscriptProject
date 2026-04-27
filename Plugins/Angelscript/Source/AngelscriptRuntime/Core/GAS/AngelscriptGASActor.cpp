#include "AngelscriptGASActor.h"

AAngelscriptGASActor::AAngelscriptGASActor(const FObjectInitializer& ObjectInitializer) : Super(ObjectInitializer)
{
	AbilitySystem = CreateDefaultSubobject<UAngelscriptAbilitySystemComponent>(TEXT("AbilitySystem"));
	AbilitySystem->SetIsReplicated(true);
}

UAbilitySystemComponent* AAngelscriptGASActor::GetAbilitySystemComponent() const
{
	return AbilitySystem;
}
