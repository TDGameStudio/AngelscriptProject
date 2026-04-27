#pragma once

#include "CoreMinimal.h"

#include "AngelscriptAbilitySystemComponent.h"
#include "GameFramework/Character.h"
#include "AbilitySystemInterface.h"

#include "AngelscriptGASPawn.generated.h"

UCLASS(abstract, meta = (ChildCanTick))
class ANGELSCRIPTRUNTIME_API AAngelscriptGASPawn : public APawn, public IAbilitySystemInterface
{
	GENERATED_BODY()

public:
	AAngelscriptGASPawn(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get());

public:
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "AbilitySystem")
	UAngelscriptAbilitySystemComponent* AbilitySystem;

public:
	UFUNCTION(BlueprintImplementableEvent)
	void SetupPawnInput(class UInputComponent* PlayerInputComponent);

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
};
