#pragma once

#include "CoreMinimal.h"

#include "AngelscriptAbilitySystemComponent.h"
#include "GameFramework/Character.h"
#include "AbilitySystemInterface.h"

#include "AngelscriptGASCharacter.generated.h"

UCLASS(abstract, meta = (ChildCanTick))
class ANGELSCRIPTRUNTIME_API AAngelscriptGASCharacter : public ACharacter, public IAbilitySystemInterface, public IGameplayTagAssetInterface
{
	GENERATED_BODY()

public:
	AAngelscriptGASCharacter(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get());

public:
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "AbilitySystem")
	UAngelscriptAbilitySystemComponent* AbilitySystem;

public:
	UFUNCTION(BlueprintImplementableEvent)
	void SetupCharacterInput(class UInputComponent* PlayerInputComponent);

	/************************************************************************/
	/* APawn                                                                */
	/************************************************************************/
public:
	virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;

	/************************************************************************/
	/* IAbilitySystemInterface                                              */
	/************************************************************************/
public:
	virtual UAbilitySystemComponent* GetAbilitySystemComponent() const override;

	/************************************************************************/
	/* IGameplayTagAssetInterface                                           */
	/************************************************************************/
public:
	virtual void GetOwnedGameplayTags(FGameplayTagContainer& TagContainer) const override;
};
