#pragma once

#include "Editor.h"
#include "Components/StaticMeshComponent.h"
#include "Engine/StaticMesh.h"
#include "Engine/StaticMeshActor.h"
#include "GameFramework/Actor.h"
#include "ISettingsModule.h"
#include "Modules/ModuleManager.h"
#include "Settings/LevelEditorViewportSettings.h"

#include "EditorStatics.generated.h"


/**
 * Creates an Editor:: namespace in script with static functions that
 * aren't exposed to Blueprint, and therefore not bound by Angelscript.
 */
UCLASS()
class UEditorStatics : public UObject
{
	GENERATED_BODY()

public:
	/** Returns the size (cm) of the current location grid selected in the editor */
	//UFUNCTION(ScriptCallable)
	UFUNCTION(BlueprintCallable)
	static float GetGridSize()
	{
		if (GEditor)
		{
			return GEditor->GetGridSize();
		}
		return 0.f;
	}

	//UFUNCTION(ScriptCallable)
	UFUNCTION(BlueprintCallable)
	static bool IsGridEnabled()
	{
		if (GEditor)
		{
			return GetDefault<ULevelEditorViewportSettings>()->GridEnabled;
		}
		return false;
	}

	//UFUNCTION(ScriptCallable)
	UFUNCTION(BlueprintCallable)
	static bool IsPlaying()
	{
		if (GEditor)
		{
			return (GEditor->PlayWorld || GIsPlayInEditorWorld);
		}
		return false;
	}

	UFUNCTION(BlueprintCallable, Category = "Editor Scripting | Level Utility")
	static void DuplicateSelected(bool bOffsetLocations = false)
	{
		if (GEditor)
		{
			UWorld* World = GEditor->GetEditorWorldContext().World();
			ULevel* CurrentLevel = World->GetCurrentLevel();
			if (CurrentLevel)
			{
				GEditor->edactDuplicateSelected(CurrentLevel, bOffsetLocations);
			}
		}
	}

	UFUNCTION(BlueprintCallable, Category = "Editor Scripting | Level Utility")
	static AActor* SpawnActorDirect(UClass* ActorClass, const FVector& Location, const FRotator& Rotation, bool bTransient = false)
	{
		if (GEditor == nullptr || ActorClass == nullptr || !ActorClass->IsChildOf(AActor::StaticClass()))
		{
			return nullptr;
		}

		UWorld* World = GEditor->GetEditorWorldContext().World();
		if (World == nullptr)
		{
			return nullptr;
		}

		ULevel* CurrentLevel = World->GetCurrentLevel();
		if (CurrentLevel == nullptr)
		{
			return nullptr;
		}

		FActorSpawnParameters SpawnParameters;
		SpawnParameters.OverrideLevel = CurrentLevel;
		SpawnParameters.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
		SpawnParameters.ObjectFlags = RF_Transactional;
		if (bTransient)
		{
			SpawnParameters.ObjectFlags |= RF_Transient;
		}

		World->Modify();
		CurrentLevel->Modify();
		AActor* Actor = World->SpawnActor(ActorClass, &Location, &Rotation, SpawnParameters);
		if (Actor != nullptr)
		{
			Actor->InvalidateLightingCache();
			Actor->PostEditMove(true);
			Actor->MarkPackageDirty();
			CurrentLevel->MarkPackageDirty();
		}
		return Actor;
	}

	UFUNCTION(BlueprintCallable, Category = "Editor Scripting | Level Utility")
	static AStaticMeshActor* SpawnStaticMeshActorDirect(UStaticMesh* StaticMesh, const FVector& Location, const FRotator& Rotation, bool bTransient = false)
	{
		AStaticMeshActor* Actor = Cast<AStaticMeshActor>(SpawnActorDirect(AStaticMeshActor::StaticClass(), Location, Rotation, bTransient));
		if (Actor == nullptr || StaticMesh == nullptr)
		{
			return Actor;
		}

		UStaticMeshComponent* StaticMeshComponent = Actor->GetStaticMeshComponent();
		if (StaticMeshComponent != nullptr)
		{
			StaticMeshComponent->SetStaticMesh(StaticMesh);
		}
		return Actor;
	}

	//UFUNCTION(ScriptCallable)
	UFUNCTION(BlueprintCallable)
	static void OpenSettings(const FName& ContainerName, const FName& CategoryName, const FName& SectionName)
	{
		if (ISettingsModule* SettingsModule = FModuleManager::GetModulePtr<ISettingsModule>("Settings"))
		{
			SettingsModule->ShowViewer(ContainerName, CategoryName, SectionName);
		}
	}
};
