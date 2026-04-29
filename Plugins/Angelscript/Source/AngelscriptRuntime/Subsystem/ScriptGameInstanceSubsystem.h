#pragma once
#include "CoreMinimal.h"
#include "Subsystems/GameInstanceSubsystem.h"
#include "AngelscriptEngine.h"
#include "ClassGenerator/ASClass.h"
#include "ScriptGameInstanceSubsystem.generated.h"

UCLASS(Blueprintable, Abstract)
class ANGELSCRIPTRUNTIME_API UScriptGameInstanceSubsystem : public UGameInstanceSubsystem, public FTickableGameObject
{
	GENERATED_BODY()

public:

	bool bInitialized = false;

	virtual bool ShouldCreateSubsystem(UObject* Outer) const override
	{
		if (IsUnreachable() || !Super::ShouldCreateSubsystem(Outer))
			return false;
		if (GetClass()->HasAnyClassFlags(CLASS_NewerVersionExists))
			return false;
		if (FAngelscriptEngine::TryGetCurrentEngine() == nullptr)
			return false;

		return BP_ShouldCreateSubsystem(Outer);
	}

	bool CanCallScriptFunctions() const
	{
		FAngelscriptEngine* CurrentEngine = FAngelscriptEngine::TryGetCurrentEngine();
		if (IsUnreachable() || CurrentEngine == nullptr)
			return false;
		if (const UASClass* ASClass = Cast<UASClass>(GetClass()))
			return ASClass->OwnerScriptEngine != nullptr
				&& ASClass->OwnerScriptEngine == CurrentEngine->GetScriptEngine();
		return true;
	}

	virtual void Initialize(FSubsystemCollectionBase& Collection) override
	{
		Super::Initialize(Collection);
		bInitialized = true;

		if (CanCallScriptFunctions())
			BP_Initialize();
	}

	virtual void Deinitialize() override
	{
		if (CanCallScriptFunctions())
			BP_Deinitialize();

		Super::Deinitialize();
		bInitialized = false;
	}

	UFUNCTION(BlueprintNativeEvent)
	bool BP_ShouldCreateSubsystem(UObject* Outer) const;
	bool BP_ShouldCreateSubsystem_Implementation(UObject* Outer) const { return true; }

	UFUNCTION(BlueprintImplementableEvent)
	void BP_Initialize();

	UFUNCTION(BlueprintImplementableEvent)
	void BP_Deinitialize();

	UFUNCTION(BlueprintImplementableEvent)
	void BP_Tick(float DeltaTime);

	UFUNCTION(BlueprintPure, Category = "Game Instance Subsystem")
	UGameInstance* BP_GetGameInstance() const
	{
		return GetGameInstance();
	}

	// FTickableGameObject implementation Begin
	virtual UWorld* GetTickableGameObjectWorld() const override
	{
		return nullptr;
	}

	virtual ETickableTickType GetTickableTickType() const override
	{
		return IsTemplate() ? ETickableTickType::Never : FTickableGameObject::GetTickableTickType(); 
	}

	virtual bool IsAllowedToTick() const override final
	{
		return !IsTemplate() && bInitialized;
	}

	virtual void Tick(float DeltaTime) override
	{
		if (CanCallScriptFunctions())
			BP_Tick(DeltaTime);
	}

	virtual TStatId GetStatId() const override 
	{
		return GetStatID();
	}
	// FTickableGameObject implementation End

};