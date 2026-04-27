#include "AngelscriptGASPawn.h"

AAngelscriptGASPawn::AAngelscriptGASPawn(const FObjectInitializer& ObjectInitializer) : Super(ObjectInitializer)
{
	AbilitySystem = CreateDefaultSubobject<UAngelscriptAbilitySystemComponent>(TEXT("AbilitySystem"));
	AbilitySystem->SetIsReplicated(true);
}

void AAngelscriptGASPawn::SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent)
{
	Super::SetupPlayerInputComponent(PlayerInputComponent);

	SetupPawnInput(PlayerInputComponent);
}


UAbilitySystemComponent* AAngelscriptGASPawn::GetAbilitySystemComponent() const
{
	return AbilitySystem;
}
