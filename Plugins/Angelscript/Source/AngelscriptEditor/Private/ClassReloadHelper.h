#pragma once
#include "CoreMinimal.h"
#include "Editor.h"

#include "GameFramework/Volume.h"

#include "BlueprintActionDatabase.h"
#include "Kismet2/EnumEditorUtils.h"

#include "ComponentTypeRegistry.h"

#include "ClassGenerator/AngelscriptClassGenerator.h"
#include "ClassReloadHelper.generated.h"

class UBlueprint;

UCLASS()
class UAngelscriptReferenceReplacementHelper : public UObject
{
	GENERATED_BODY()
public:

	static void AddReferencedObjects(UObject* InThis, FReferenceCollector& Collector);
	virtual void Serialize(FStructuredArchive::FRecord Record) override;
};

#if WITH_DEV_AUTOMATION_TESTS
struct FClassReloadHelperClassReloadTestHooks
{
	TFunction<void(UClass*)> RefreshClassActions;
	TFunction<void(UClass*)> InvalidateComponentClass;
};

struct FClassReloadHelperPostReloadTestHooks
{
	TFunction<void()> RefreshAllActions;
	TFunction<void()> InvalidateComponentRegistry;
	TFunction<void(UWorld*, const TCHAR*)> ExecCommand;
};

struct FClassReloadHelperPerformReinstanceTestHooks
{
	TFunction<bool()> EnterPerformReinstanceBody;
	TFunction<void()> NotifyCustomizationModuleChanged;
	TFunction<void(UEnum*)> RefreshAssetActions;
	TFunction<void()> AddActorFactory;
	TFunction<void()> BroadcastAllPlaceableAssetsChanged;
	TFunction<void()> BroadcastPlaceableItemFilteringChanged;
	TFunction<void(UBlueprint*)> QueueBlueprintForCompilation;
	TFunction<void()> FlushCompilationQueueAndReinstance;
};

struct FClassReloadHelperTestAccess
{
	static void SetClassReloadTestHooks(FClassReloadHelperClassReloadTestHooks InHooks);
	static void ResetClassReloadTestHooks();
	static bool HandleRefreshClassActions(UClass* Class);
	static bool HandleInvalidateComponentClass(UClass* Class);
	static void SetPostReloadTestHooks(FClassReloadHelperPostReloadTestHooks InHooks);
	static void ResetPostReloadTestHooks();
	static bool HandleRefreshAllActions();
	static bool HandleInvalidateComponentRegistry();
	static bool HandleExecCommand(UWorld* World, const TCHAR* Command);
	static void SetPerformReinstanceTestHooks(FClassReloadHelperPerformReinstanceTestHooks InHooks);
	static void ResetPerformReinstanceTestHooks();
};
#endif

struct FClassReloadHelper
{
	struct FReloadState
	{
		bool bRefreshAllActions = false;
		bool bReloadedVolume = false;

		TMap<UClass*, UClass*> ReloadClasses;
		TMap<UObject*, UObject*> ReloadAssets;
		TSet<UClass*> NewClasses;
		TSet<UEnum*> ReloadEnums;
		TSet<UEnum*> NewEnums;
		TMap<UScriptStruct*, UScriptStruct*> ReloadStructs;
		TMap<UDelegateFunction*, UDelegateFunction*> ReloadDelegates;
		TSet<UDelegateFunction*> NewDelegates;

		void PerformReinstance();
	};

	static FReloadState& ReloadState()
	{
		static FReloadState State;
		return State;
	}

	static void Init()
	{
		FAngelscriptClassGenerator::OnStructReload.AddLambda(
		[](UScriptStruct* OldStruct, UScriptStruct* NewStruct)
		{
			ReloadState().ReloadStructs.Add(OldStruct, NewStruct);
			ReloadState().bRefreshAllActions = true;
		});

		FAngelscriptClassGenerator::OnClassReload.AddLambda(
		[](UClass* OldClass, UClass* NewClass)
		{
			if (OldClass != nullptr)
				ReloadState().ReloadClasses.Add(OldClass, NewClass);
			else
				ReloadState().NewClasses.Add(NewClass);

			const bool bTouchesInterfaceReload =
				(OldClass != nullptr && (OldClass->HasAnyClassFlags(CLASS_Interface) || OldClass->Interfaces.Num() > 0))
				|| (NewClass != nullptr && (NewClass->HasAnyClassFlags(CLASS_Interface) || NewClass->Interfaces.Num() > 0));
			if (bTouchesInterfaceReload)
			{
				ReloadState().bRefreshAllActions = true;
			}

			bool bRefreshedAll = false;
			if (ReloadState().bRefreshAllActions)
				bRefreshedAll = true;

			if (OldClass != nullptr)
			{
				if (!bRefreshedAll && GEngine != nullptr)
				{
#if WITH_DEV_AUTOMATION_TESTS
					if (!FClassReloadHelperTestAccess::HandleRefreshClassActions(OldClass))
#endif
					{
						auto& Database = FBlueprintActionDatabase::Get();
						Database.RefreshClassActions(OldClass);
					}
				}
			}

			if (NewClass != nullptr)
			{
				if (!bRefreshedAll && GEngine != nullptr)
				{
#if WITH_DEV_AUTOMATION_TESTS
					if (!FClassReloadHelperTestAccess::HandleRefreshClassActions(NewClass))
#endif
					{
						auto& Database = FBlueprintActionDatabase::Get();
						Database.RefreshClassActions(NewClass);
					}
				}

				if (NewClass->IsChildOf(UActorComponent::StaticClass()))
				{
#if WITH_DEV_AUTOMATION_TESTS
					if (!FClassReloadHelperTestAccess::HandleInvalidateComponentClass(NewClass))
#endif
					{
						FComponentTypeRegistry::Get().InvalidateClass(NewClass);
					}
				}

				if (NewClass->IsChildOf(AVolume::StaticClass()))
					ReloadState().bReloadedVolume = true;
			}
		});

		FAngelscriptClassGenerator::OnDelegateReload.AddLambda(
		[](UDelegateFunction* OldDelegate, UDelegateFunction* NewDelegate)
		{
			ReloadState().ReloadDelegates.Add(OldDelegate, NewDelegate);
			ReloadState().NewDelegates.Add(NewDelegate);
		});
		
		FAngelscriptClassGenerator::OnLiteralAssetReload.AddLambda(
		[](UObject* OldObject, UObject* NewObject)
		{
			ReloadState().ReloadAssets.Add(OldObject, NewObject);
		});

		FAngelscriptClassGenerator::OnEnumChanged.AddLambda(
		[](UEnum* Enum, const TArray<TPair<FName, int64>>& OldNames)
		{
			ReloadState().ReloadEnums.Add(Enum);
			//WILL-EDIT
			// Need to refresh blueprints that depend on this
			//FEnumEditorUtils::BroadcastChanges((UUserDefinedEnum*)Enum, OldNames);			
		});
		
		FAngelscriptClassGenerator::OnEnumCreated.AddLambda(
		[](UEnum* Enum)
		{
			ReloadState().NewEnums.Add(Enum);
		});

		FAngelscriptClassGenerator::OnFullReload.AddLambda(
		[]()
		{
			// Do the actual reinstancing required
			ReloadState().PerformReinstance();
		});

		FAngelscriptClassGenerator::OnPostReload.AddLambda(
		[](bool bFullReload)
		{
			// Refresh action list in blueprint, this is what
			// is used to populate the right click menu.
			if (ReloadState().bRefreshAllActions && GEngine != nullptr)
			{
#if WITH_DEV_AUTOMATION_TESTS
				if (!FClassReloadHelperTestAccess::HandleRefreshAllActions())
#endif
				{
					auto& Database = FBlueprintActionDatabase::Get();
					Database.RefreshAll();
				}
			}

			// Refresh class lists by pretending we just compiled a bp
			if (bFullReload && GEditor != nullptr)
			{
				GEditor->BroadcastBlueprintCompiled();	
			}

			if (!FAngelscriptEngine::IsInitialized() || !FAngelscriptEngine::Get().IsInitialCompileFinished())
			{
#if WITH_DEV_AUTOMATION_TESTS
				if (!FClassReloadHelperTestAccess::HandleInvalidateComponentRegistry())
#endif
				{
					FComponentTypeRegistry::Get().Invalidate();
				}
			}

			// If we reloaded any volume classes, trigger a geometry rebuild
			if (ReloadState().bReloadedVolume && GEngine != nullptr)
			{
				auto* World = GEditor->GetEditorWorldContext().World();
				ULevel* CurrentLevel = World->GetCurrentLevel();

#if WITH_DEV_AUTOMATION_TESTS
				if (!FClassReloadHelperTestAccess::HandleExecCommand(World, TEXT("MAP REBUILD ALLVISIBLE")))
#endif
				{
					GEngine->Exec( World, TEXT("MAP REBUILD ALLVISIBLE") );
				}

				// Map rebuild ("Build Geometry") is currently bugged (as of 5.4.1) and resets the CurrentLevel.
				// To avoid being annoying and resetting the active level on hotreload, restore it after the rebuild
				if (IsValid(CurrentLevel) && World->GetLevels().Contains(CurrentLevel))
					World->SetCurrentLevel(CurrentLevel);
			}

			// Reset state
			ReloadState() = FReloadState();
		});
	}

	static TArray<UDataTable*> GetTablesDependentOnStruct(UStruct* Struct)
	{
		TArray<UDataTable*> Result;
		if (Struct)
		{
			TArray<UObject*> DataTables;
			GetObjectsOfClass(UDataTable::StaticClass(), DataTables);
			for (UObject* DataTableObj : DataTables)
			{
				UDataTable* DataTable = Cast<UDataTable>(DataTableObj);
				if (DataTable && (Struct == DataTable->RowStruct))
				{
					Result.Add(DataTable);
				}
			}
		}
		return Result;
	}
};
