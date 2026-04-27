#include "AngelscriptAttributeSet.h"
#include "AngelscriptAbilitySystemComponent.h"

#include "AngelscriptEngine.h"
#include "Runtime/Engine/Public/Net/UnrealNetwork.h"

bool UAngelscriptAttributeSet::BP_PreGameplayEffectExecute_Implementation(const FGameplayEffectSpec& EffectSpec, FGameplayModifierEvaluatedData& EvaluatedData, UAngelscriptAbilitySystemComponent* AbilitySystemComponent)
{
	return true;
}

bool UAngelscriptAttributeSet::BP_OnInitFromMetaDataTable_Implementation(const UDataTable* DataTable)
{
	return false;
}

bool UAngelscriptAttributeSet::PreGameplayEffectExecute(FGameplayEffectModCallbackData& Data)
{
	UAngelscriptAbilitySystemComponent* AbilitySytem = Cast<UAngelscriptAbilitySystemComponent>(&Data.Target);
	if (AbilitySytem)
	{
		return BP_PreGameplayEffectExecute(Data.EffectSpec, Data.EvaluatedData, AbilitySytem);
	}

	return true;
}

void UAngelscriptAttributeSet::PostGameplayEffectExecute(const FGameplayEffectModCallbackData& Data)
{
	UAngelscriptAbilitySystemComponent* AbilitySytem = Cast<UAngelscriptAbilitySystemComponent>(&Data.Target);
	if (AbilitySytem)
	{
		BP_PostGameplayEffectExecute(Data.EffectSpec, Data.EvaluatedData, AbilitySytem);
	}
}

void UAngelscriptAttributeSet::PreAttributeChange(const FGameplayAttribute& Attribute, float& NewValue)
{
	BP_PreAttributeChange(Attribute, NewValue);
}

void UAngelscriptAttributeSet::PostAttributeChange(const FGameplayAttribute& Attribute, float OldValue, float NewValue)
{
	BP_PostAttributeChange(Attribute, OldValue, NewValue);
}

void UAngelscriptAttributeSet::PreAttributeBaseChange(const FGameplayAttribute& Attribute, float& NewValue) const
{
	BP_PreAttributeBaseChange(Attribute, NewValue);
}

void UAngelscriptAttributeSet::PostAttributeBaseChange(const FGameplayAttribute& Attribute, float OldValue, float NewValue) const
{
	BP_PostAttributeBaseChange(Attribute, OldValue, NewValue);
}

void UAngelscriptAttributeSet::InitFromMetaDataTable(const UDataTable* DataTable)
{
	if (!BP_OnInitFromMetaDataTable(DataTable))
	{
		Super::InitFromMetaDataTable(DataTable);
	}
}

void UAngelscriptAttributeSet::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const
{
	Super::GetLifetimeReplicatedProps(OutLifetimeProps);

	for (FProperty* Property = GetClass()->PropertyLink; Property; Property = Property->PropertyLinkNext)
	{
		FName AttributeName = FName(*Property->GetName());
		if (ReplicatedAttributeBlackList.Contains(AttributeName) || AttributeName == FName("ReplicatedAttributeBlackList"))
		{
			continue;
		}

		FStructProperty* StructProperty = CastField<FStructProperty>(Property);
		if (StructProperty && StructProperty->Struct 
			&& StructProperty->Struct->IsChildOf(FAngelscriptGameplayAttributeData::StaticStruct())
			&& StructProperty->HasAnyPropertyFlags(EPropertyFlags::CPF_Net))
		{
			RegisterReplicatedLifetimeProperty(Property, OutLifetimeProps, FDoRepLifetimeParams());
		}
	}
}

void UAngelscriptAttributeSet::PostInitProperties()
{
	Super::PostInitProperties();

	for (FProperty* Property = GetClass()->PropertyLink; Property; Property = Property->PropertyLinkNext)
	{
		FName AttributeName = FName(*Property->GetName());

		FStructProperty* StructProperty = CastField<FStructProperty>(Property);
		if (StructProperty && StructProperty->Struct && StructProperty->Struct->IsChildOf(FAngelscriptGameplayAttributeData::StaticStruct()))
		{
			// Set the name in our FAngelscriptGameplayAttributeData
			FAngelscriptGameplayAttributeData* AttributePtr = StructProperty->ContainerPtrToValuePtr<FAngelscriptGameplayAttributeData>(this);
			if (AttributePtr)
			{
				AttributePtr->AttributeName = AttributeName;
			}
		}
	}
}

void UAngelscriptAttributeSet::OnRep_Attribute(FAngelscriptGameplayAttributeData& OldAttributeData)
{
	if (ReplicatedAttributeBlackList.Contains(OldAttributeData.AttributeName) || !GetOwningAbilitySystemComponent())
	{
		return;
	}

	FStructProperty* AttributeProperty = CastField<FStructProperty>(FindFieldChecked<FProperty>(GetClass(), OldAttributeData.AttributeName));
	if (AttributeProperty && AttributeProperty->Struct && AttributeProperty->Struct->IsChildOf(FAngelscriptGameplayAttributeData::StaticStruct()))
	{
		FAngelscriptGameplayAttributeData* AttributeDataPtr = AttributeProperty->ContainerPtrToValuePtr<FAngelscriptGameplayAttributeData>(this);
		if (AttributeDataPtr)
		{
			GetOwningAbilitySystemComponent()->SetBaseAttributeValueFromReplication(FGameplayAttribute(AttributeProperty), *AttributeDataPtr, OldAttributeData);
		}
	}
}

AActor* UAngelscriptAttributeSet::BP_GetOwningActor()
{
	return GetOwningActor();
}

UAngelscriptAbilitySystemComponent* UAngelscriptAttributeSet::BP_GetOwningAbilitySystemComponent() const
{
	return Cast<UAngelscriptAbilitySystemComponent>(GetOwningAbilitySystemComponent());
}

FGameplayAbilityActorInfo& UAngelscriptAttributeSet::BP_GetActorInfo() const
{
	return *GetActorInfo();
}

bool UAngelscriptAttributeSet::TrySetAttributeBaseValue(FName AttributeName, float NewBaseValue)
{
	UAngelscriptAbilitySystemComponent* AbilitySystemComponent = BP_GetOwningAbilitySystemComponent();
	if (AbilitySystemComponent)
	{
		return AbilitySystemComponent->TrySetAttributeBaseValue(GetClass(), AttributeName, NewBaseValue);
	}

	return false;
}

bool UAngelscriptAttributeSet::TryGetAttributeCurrentValue(FName AttributeName, float& OutCurrentValue)
{
	UAngelscriptAbilitySystemComponent* AbilitySystemComponent = BP_GetOwningAbilitySystemComponent();
	if (AbilitySystemComponent)
	{
		return AbilitySystemComponent->TryGetAttributeCurrentValue(GetClass(), AttributeName, OutCurrentValue);
	}

	return false;
}

bool UAngelscriptAttributeSet::TryGetAttributeBaseValue(FName AttributeName, float& OutBaseValue)
{
	UAngelscriptAbilitySystemComponent* AbilitySystemComponent = BP_GetOwningAbilitySystemComponent();
	if (AbilitySystemComponent)
	{
		return AbilitySystemComponent->TryGetAttributeBaseValue(GetClass(), AttributeName, OutBaseValue);
	}

	return false;
}

FGameplayAttribute UAngelscriptAttributeSet::GetGameplayAttribute(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName)
{
	FGameplayAttribute Attribute;
	ensureMsgf(TryGetGameplayAttribute(AttributeSetClass, AttributeName, Attribute), TEXT("Attribute access failed! Make sure attribute class >%s< and attribute name >%s< are valid!"), *AttributeSetClass->GetName(), *AttributeName.ToString());
	return Attribute;
}

bool UAngelscriptAttributeSet::TryGetGameplayAttribute(TSubclassOf<UAngelscriptAttributeSet> AttributeSetClass, FName AttributeName, FGameplayAttribute& OutGameplayAttribute)
{
	if (AttributeSetClass.Get())
	{
		FProperty* Property = AttributeSetClass->FindPropertyByName(AttributeName);
		if (Property)
		{
			OutGameplayAttribute = FGameplayAttribute(Property);
			return true;
		}
	}

	return false;
}

bool UAngelscriptAttributeSet::CompareGameplayAttributes(const FGameplayAttribute& First, const FGameplayAttribute& Second)
{
	return First == Second;
}
