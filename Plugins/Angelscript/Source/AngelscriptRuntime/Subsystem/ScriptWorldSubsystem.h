#pragma once
#include "CoreMinimal.h"
#include "Streaming/StreamingWorldSubsystemInterface.h"
#include "Subsystems/WorldSubsystem.h"
#include "AngelscriptEngine.h"
#include "ClassGenerator/ASClass.h"
#include "ScriptWorldSubsystem.generated.h"

UCLASS(Blueprintable, Abstract)
class ANGELSCRIPTRUNTIME_API UScriptWorldSubsystem : public UWorldSubsystem, public FTickableGameObject, public IStreamingWorldSubsystemInterface
{
	GENERATED_BODY()

	bool bInitialized = false;

public:

	// Create this subsystem for worlds representing levels loaded in the editor
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "World Subsystem")
	bool bCreateForLevelEditorWorlds = false;

	// Create this subsystem for worlds in gameplay (including Play-In-Editor)
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "World Subsystem")
	bool bCreateForGameWorlds = true;

	// Whether this subsystem should continue ticking when the game is paused
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "World Subsystem")
	bool bTickWhenPaused = false;

	virtual bool ShouldCreateSubsystem(UObject* Outer) const override
	{
		if (IsUnreachable() || !Super::ShouldCreateSubsystem(Outer))
			return false;
		if (GetClass()->HasAnyClassFlags(CLASS_NewerVersionExists))
			return false;
		if (FAngelscriptEngine::TryGetCurrentEngine() == nullptr)
			return false;

		UWorld* World = Cast<UWorld>(Outer);
		switch (World->WorldType)
		{
		case EWorldType::Game:
		case EWorldType::PIE:
			if (!bCreateForGameWorlds)
				return false;
		break;
		case EWorldType::Editor:
			if (!bCreateForLevelEditorWorlds)
				return false;
		break;
		default:
			return false;
		break;
		}

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
		if (bInitialized && CanCallScriptFunctions())
			BP_Deinitialize();
		bInitialized = false;
		Super::Deinitialize();
	}

	virtual void PostInitialize() override
	{
		Super::PostInitialize();

		if (CanCallScriptFunctions())
			BP_PostInitialize();
	}

	virtual void Tick(float DeltaTime) override
	{
		if (CanCallScriptFunctions())
			BP_Tick(DeltaTime);
	}

	virtual void OnWorldBeginPlay(UWorld& InWorld) override
	{
		Super::OnWorldBeginPlay(InWorld);

		if (CanCallScriptFunctions())
			BP_OnWorldBeginPlay();
	}

	virtual void OnWorldComponentsUpdated(UWorld& InWorld) override
	{
		Super::OnWorldComponentsUpdated(InWorld);

		if (CanCallScriptFunctions())
			BP_OnWorldComponentsUpdated();
	}

	virtual void OnUpdateStreamingState() override
	{
		if (CanCallScriptFunctions())
			BP_UpdateStreamingState();
	}

	UFUNCTION(BlueprintNativeEvent)
	bool BP_ShouldCreateSubsystem(UObject* Outer) const;
	bool BP_ShouldCreateSubsystem_Implementation(UObject* Outer) const { return true; }

	UFUNCTION(BlueprintImplementableEvent)
	void BP_Initialize();

	UFUNCTION(BlueprintImplementableEvent)
	void BP_Deinitialize();

	UFUNCTION(BlueprintImplementableEvent)
	void BP_PostInitialize();

	UFUNCTION(BlueprintImplementableEvent)
	void BP_OnWorldBeginPlay();

	UFUNCTION(BlueprintImplementableEvent)
	void BP_OnWorldComponentsUpdated();

	UFUNCTION(BlueprintImplementableEvent)
	void BP_UpdateStreamingState();

	UFUNCTION(BlueprintImplementableEvent)
	void BP_Tick(float DeltaTime);

	virtual UWorld* GetTickableGameObjectWorld() const override { return GetWorld(); }

	virtual ETickableTickType GetTickableTickType() const override
	{
		return IsTemplate() ? ETickableTickType::Never : FTickableGameObject::GetTickableTickType(); 
	}

	virtual bool IsAllowedToTick() const override final
	{
		return !IsTemplate() && bInitialized;
	}

	virtual TStatId GetStatId() const override
	{
		return GetStatID();
	}

	virtual bool IsTickableInEditor() const override
	{
		return bCreateForLevelEditorWorlds;
	}

	virtual bool IsTickableWhenPaused() const override
	{
		return bTickWhenPaused;
	}

};
