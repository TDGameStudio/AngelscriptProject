#pragma once
#include "CoreMinimal.h"
#include "Subsystems/LocalPlayerSubsystem.h"
#include "AngelscriptEngine.h"
#include "ClassGenerator/ASClass.h"
#include "ScriptLocalPlayerSubsystem.generated.h"

UCLASS(Blueprintable, Abstract)
class ANGELSCRIPTRUNTIME_API UScriptLocalPlayerSubsystem : public ULocalPlayerSubsystem
{
	GENERATED_BODY()

public:

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
	}

	virtual void Deinitialize() override
	{
		if (CanCallScriptFunctions())
			BP_Deinitialize();

		Super::Deinitialize();
	}

	UFUNCTION(BlueprintNativeEvent)
	bool BP_ShouldCreateSubsystem(UObject* Outer) const;
	bool BP_ShouldCreateSubsystem_Implementation(UObject* Outer) const { return true; }

	UFUNCTION(BlueprintImplementableEvent)
	void BP_Initialize();

	UFUNCTION(BlueprintImplementableEvent)
	void BP_Deinitialize();

	UFUNCTION(BlueprintPure, Category = "Local Player Subsystem")
	ULocalPlayer* BP_GetLocalPlayer() const
	{
		return GetLocalPlayer<ULocalPlayer>();
	}

};