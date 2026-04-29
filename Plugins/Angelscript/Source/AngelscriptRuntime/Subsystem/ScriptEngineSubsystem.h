#pragma once
#include "CoreMinimal.h"
#include "Subsystems/EngineSubsystem.h"
#include "AngelscriptEngine.h"
#include "ClassGenerator/ASClass.h"
#include "ScriptEngineSubsystem.generated.h"

UCLASS(Blueprintable, Abstract)
class ANGELSCRIPTRUNTIME_API UScriptEngineSubsystem : public UEngineSubsystem, public FTickableGameObject
{
	GENERATED_BODY()

public:

	// Enable this subsystem to tick when paused
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Engine Subsystem")
	bool bIsTickableWhenPaused = true;

	// Enable this subsystem to tick in editor
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Engine Subsystem")
	bool bIsTickableInEditor = true;

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

		if (CanCallScriptFunctions())
			BP_Initialize();

		check(!bInitialized);
		bInitialized = true;
	}

	virtual void Deinitialize() override
	{
		if (CanCallScriptFunctions())
			BP_Deinitialize();

		Super::Deinitialize();
	}

	// FTickableGameObject implementation Begin
	virtual ETickableTickType GetTickableTickType() const override
	{ 
		// By default (if the child class doesn't override GetTickableTickType), don't let CDOs ever tick: 
		return IsTemplate() ? ETickableTickType::Never : FTickableGameObject::GetTickableTickType(); 
	}
	
	virtual bool IsAllowedToTick() const override final
	{
		// No matter what IsTickable says, don't let CDOs or uninitialized world subsystems tick :
		// Note: even if GetTickableTickType was overridden by the child class and returns something else than ETickableTickType::Never for CDOs, 
		//  it's probably a mistake, so by default, don't allow ticking. If the child class really intends its CDO to tick, he can always override IsAllowedToTick...
		return !IsTemplate() && bInitialized;
	}

	virtual bool IsTickableWhenPaused() const override
	{
		return bIsTickableWhenPaused;
	}

	virtual bool IsTickableInEditor() const override
	{
		return bIsTickableInEditor;
	}

	virtual void Tick(float DeltaTime) override
	{
		checkf(IsInitialized(), TEXT("Ticking should have been disabled for an uninitialized subsystem : remember to call IsInitialized in the subsystem's IsTickable, IsTickableInEditor and/or IsTickableWhenPaused implementation"));

		if (CanCallScriptFunctions())
			BP_Tick(DeltaTime);
	}
	
	virtual TStatId GetStatId() const override
	{
		return GetStatID();
	}
	// FTickableGameObject implementation End

	UFUNCTION(BlueprintNativeEvent)
	bool BP_ShouldCreateSubsystem(UObject* Outer) const;
	bool BP_ShouldCreateSubsystem_Implementation(UObject* Outer) const { return true; }

	UFUNCTION(BlueprintImplementableEvent)
	void BP_Initialize();

	UFUNCTION(BlueprintImplementableEvent)
	void BP_Deinitialize();

	UFUNCTION(BlueprintImplementableEvent)
	void BP_Tick(float DeltaTime);

	bool IsInitialized() const { return bInitialized; }

private:
	bool bInitialized = false;
};