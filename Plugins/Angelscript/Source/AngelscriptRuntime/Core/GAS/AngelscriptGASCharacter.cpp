#include "AngelscriptGASCharacter.h"

AAngelscriptGASCharacter::AAngelscriptGASCharacter(const FObjectInitializer& ObjectInitializer) : Super(ObjectInitializer)
{
	AbilitySystem = CreateDefaultSubobject<UAngelscriptAbilitySystemComponent>(TEXT("AbilitySystem"));
	AbilitySystem->SetIsReplicated(true);
}

void AAngelscriptGASCharacter::SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent)
{
	Super::SetupPlayerInputComponent(PlayerInputComponent);

	SetupCharacterInput(PlayerInputComponent);
}

UAbilitySystemComponent* AAngelscriptGASCharacter::GetAbilitySystemComponent() const
{
	return AbilitySystem;
}

void AAngelscriptGASCharacter::GetOwnedGameplayTags(FGameplayTagContainer& TagContainer) const
{
	if(AbilitySystem)
	{
		AbilitySystem->GetOwnedGameplayTags(TagContainer);
	}
}
