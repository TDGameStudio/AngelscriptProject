#pragma once
#include "CoreMinimal.h"
#include "Framework/Commands/UICommandList.h"
#include "AssetRegistry/AssetData.h"
#include "ToolMenuDelegates.h"
#include "ToolMenuSection.h"
#include "ScriptEditorMenuExtension.generated.h"

UENUM(BlueprintType)
enum class EScriptEditorMenuExtensionLocation : uint8
{
	ToolMenu,
	LevelViewport_ContextMenu,
	LevelViewport_DragDropContextMenu,
	LevelViewport_OptionsMenu,
	LevelViewport_ShowMenu,
	LevelViewport_ViewMenu,
	LevelViewport_BuildMenu,
	LevelViewport_CompileMenu,
	LevelViewport_SourceControlMenu,
	LevelViewport_CreateMenu,
	LevelViewport_PlayMenu,
	LevelViewport_BlueprintsMenu,
	LevelViewport_CinematicsMenu,
	LevelViewport_LevelMenu,
	ContentBrowser_AssetContextMenu,
	ContentBrowser_PathViewContextMenu,
	ContentBrowser_CollectionListContextMenu,
	ContentBrowser_CollectionViewContextMenu,
	ContentBrowser_AssetViewContextMenu,
	ContentBrowser_AssetViewViewMenu,
};

UENUM(BlueprintType)
enum class EScriptEditorMenuExtensionOrder : uint8
{
	Before,
	After,
	First,
};

UCLASS(BlueprintType)
class UScriptEditorMenuExtension : public UObject
{
	GENERATED_BODY()

#if WITH_DEV_AUTOMATION_TESTS
	friend struct FAngelscriptEditorMenuExtensionTestAccess;
#endif

public:

	virtual UWorld* GetWorld() const override;

	UPROPERTY(EditDefaultsOnly, Category = "Menu Extension")
	EScriptEditorMenuExtensionLocation ExtensionMenu = EScriptEditorMenuExtensionLocation::ToolMenu;

	UPROPERTY(EditDefaultsOnly, Category = "Menu Extension")
	FName ExtensionPoint = "MainFrame.MainMenu.Tools";

	UPROPERTY(EditDefaultsOnly, Category = "Menu Extension")
	EScriptEditorMenuExtensionOrder ExtensionOrder = EScriptEditorMenuExtensionOrder::After;

	UPROPERTY(EditDefaultsOnly, Category = "Menu Extension")
	EToolMenuInsertType ToolMenuInsertType = EToolMenuInsertType::Default;

	UPROPERTY(EditDefaultsOnly, Category = "Menu Extension")
	EToolMenuSectionAlign ToolMenuSectionAlign = EToolMenuSectionAlign::Default;

	UPROPERTY(EditDefaultsOnly, Category = "Menu Extension")
	FName ToolMenuInsertPosition;

	UPROPERTY(EditDefaultsOnly, Category = "Menu Extension")
	FText MenuSectionHeader;

	UPROPERTY(EditDefaultsOnly, Category = "Menu Extension")
	bool bAddSeparatorBeforeOptions = false;

	UPROPERTY(EditDefaultsOnly, Category = "Menu Extension")
	bool bAddSeparatorAfterOptions = false;

	UFUNCTION(BlueprintNativeEvent)
	bool ShouldExtend() const;
	bool ShouldExtend_Implementation() const { return true; }

	UFUNCTION(BlueprintCallable, Meta = (DeterminesOutputType = "ContextClass"))
	UObject* GetToolMenuContext(TSubclassOf<UObject> ContextClass) const;

	static void InitializeExtensions();

	struct FRegisteredExtensionSnapshot
	{
		EScriptEditorMenuExtensionLocation Location;
		FName ExtensionPoint;
		FName SectionName;
	};

	static TArray<FRegisteredExtensionSnapshot> GetRegisteredExtensionSnapshots();

protected:

	struct FExtenderSelection
	{
		TArray<UObject*> SelectedObjects;
		TArray<FAssetData> SelectedAssets;
	};

	mutable FExtenderSelection CurrentSelection;

	virtual TArray<UFunction*> GatherExtensionFunctions() const;
	virtual void CallFunctionOnSelection(UFunction* Function, FExtenderSelection Selection) const;

	virtual FName GetExtensionPointOrDefault() const;

private:

	struct FRegisteredExtender
	{
		EScriptEditorMenuExtensionLocation Location;
		FDelegateHandle DelegateHandle;
		TSharedPtr<class FExtender> Extender;
		FName ExtensionPoint;
		FName SectionName;
	};

	static TArray<FRegisteredExtender> RegisteredExtensions;
	mutable const struct FToolMenuContext* ActiveToolMenuContext = nullptr;

	TSharedRef<class FExtender> Extend(const TSharedRef<FUICommandList> CommandList, FExtenderSelection Selection) const;
	void BuildMenu(class FMenuBuilder& MenuBuilder, TArray<UFunction*> Functions, FExtenderSelection Selection) const;
	void AddMenuEntry(class FMenuBuilder& MenuBuilder, UFunction* Function, FExtenderSelection Selection) const;

	void BuildToolMenuSection(struct FToolMenuSection& MenuSection, FExtenderSelection Selection, bool bIsMenu) const;
	void AddToolMenuEntry(struct FToolMenuSection& MenuSection, UFunction* Function, FExtenderSelection Selection) const;
	void AddToolMenuButton(struct FToolMenuSection& MenuSection, UFunction* Function, FExtenderSelection Selection) const;

	FUIAction CreateUIAction(UFunction* Function, FExtenderSelection Selection) const;
	FToolUIAction CreateToolUIAction(UFunction* Function, FExtenderSelection Selection) const;

	static void UnregisterExtensions();
	static void RegisterExtension(UScriptEditorMenuExtension* Extension);
	static void RegisterExtensions();
};

#if WITH_DEV_AUTOMATION_TESTS
struct FAngelscriptEditorMenuExtensionTestAccess
{
	static FUIAction CreateUIAction(const UScriptEditorMenuExtension* Extension, UFunction* Function)
	{
		UScriptEditorMenuExtension::FExtenderSelection Selection;
		return Extension->CreateUIAction(Function, Selection);
	}

	static void BuildMenu(const UScriptEditorMenuExtension* Extension, FMenuBuilder& MenuBuilder)
	{
		UScriptEditorMenuExtension::FExtenderSelection Selection;
		Extension->BuildMenu(MenuBuilder, Extension->GatherExtensionFunctions(), Selection);
	}

	static void BuildToolMenuSection(const UScriptEditorMenuExtension* Extension, FToolMenuSection& MenuSection, bool bIsMenu)
	{
		UScriptEditorMenuExtension::FExtenderSelection Selection;
		Extension->BuildToolMenuSection(MenuSection, Selection, bIsMenu);
	}

	static FToolUIAction CreateToolUIAction(const UScriptEditorMenuExtension* Extension, UFunction* Function)
	{
		UScriptEditorMenuExtension::FExtenderSelection Selection;
		return Extension->CreateToolUIAction(Function, Selection);
	}

	static EUserInterfaceActionType GetActionType(UFunction* Function);
	static void SetShiftModifierOverride(TFunction<bool()> InOverride);
	static void ResetShiftModifierOverride();
	static void SetNavigateToFunctionOverride(TFunction<bool(const UFunction*)> InOverride);
	static void ResetNavigateToFunctionOverride();
	static void SetNavigateToClassOverride(TFunction<void(const UClass*)> InOverride);
	static void ResetNavigateToClassOverride();

	static void RegisterExtensions()
	{
		UScriptEditorMenuExtension::RegisterExtensions();
	}

	static void UnregisterExtensions()
	{
		UScriptEditorMenuExtension::UnregisterExtensions();
	}

	static void RegisterExtension(UScriptEditorMenuExtension* Extension)
	{
		UScriptEditorMenuExtension::RegisterExtension(Extension);
	}
};
#endif
