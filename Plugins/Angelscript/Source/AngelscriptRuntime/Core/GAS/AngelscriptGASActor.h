#pragma once

#include "CoreMinimal.h"

#include "AngelscriptAbilitySystemComponent.h"
#include "GameFramework/Character.h"
#include "AbilitySystemInterface.h"

#include "AngelscriptGASActor.generated.h"

UCLASS(abstract, meta = (ChildCanTick))
class ANGELSCRIPTRUNTIME_API AAngelscriptGASActor : public AActor, public IAbilitySystemInterface
{
	GENERATED_BODY()

public:
	AAngelscriptGASActor(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get());

public:
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "AbilitySystem")
	UAngelscriptAbilitySystemComponent* AbilitySystem;

	/************************************************************************/
	/* IAbilitySystemInterface                                              */
	/************************************************************************/
public:
	virtual UAbilitySystemComponent* GetAbilitySystemComponent() const override;
};
