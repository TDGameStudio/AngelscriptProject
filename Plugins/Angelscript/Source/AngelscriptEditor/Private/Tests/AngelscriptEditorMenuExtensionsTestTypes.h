#pragma once

#include "CoreMinimal.h"
#include "AssetRegistry/AssetData.h"
#include "EditorMenuExtensions/ScriptActorMenuExtension.h"
#include "EditorMenuExtensions/ScriptAssetMenuExtension.h"
#include "Curves/CurveFloat.h"
#include "ToolMenuContext.h"

#include "AngelscriptEditorMenuExtensionsTestTypes.generated.h"

UCLASS()
class UAngelscriptEditorMenuExtensionTestShim : public UScriptEditorMenuExtension
{
	GENERATED_BODY()

public:
	TArray<FName> GatheredFunctionNames() const;
	FName ResolveExtensionPoint() const;

	UFUNCTION(CallInEditor)
	void IncludedCommand();

	UFUNCTION(CallInEditor)
	void IncludedSecondaryCommand();

	UFUNCTION(CallInEditor)
	int32 ExcludedReturnsValue() const;

	UFUNCTION()
	void ExcludedWithoutCallInEditor();
};

UCLASS()
class UAngelscriptEditorMenuExtensionActionTestShim : public UScriptEditorMenuExtension
{
	GENERATED_BODY()

public:
	static void ResetRecordedState();
	static void ConfigureActionResponses(bool bInCanExecute, bool bInVisible, bool bInChecked);
	static int32 GetPromptInvocationCount();
	static FName GetLastPromptFunctionName();
	static int32 GetCanExecuteEvaluationCount();
	static int32 GetVisibleEvaluationCount();
	static int32 GetCheckedEvaluationCount();

	UFUNCTION(CallInEditor, meta = (ActionCanExecute = "CanExecuteMetadata", ActionIsVisible = "IsVisibleMetadata", ActionIsChecked = "IsCheckedMetadata", ActionType = "ToggleButton"))
	void MetadataDrivenCommand();

	UFUNCTION()
	bool CanExecuteMetadata() const;

	UFUNCTION()
	bool IsVisibleMetadata() const;

	UFUNCTION()
	bool IsCheckedMetadata() const;

protected:
	virtual void CallFunctionOnSelection(UFunction* Function, FExtenderSelection Selection) const override;
};

UCLASS()
class UAngelscriptEditorMenuExtensionToolMenuContextObject : public UToolMenuContextBase
{
	GENERATED_BODY()

public:
	UPROPERTY(Transient)
	int32 Marker = 0;
};

UCLASS()
class UAngelscriptEditorMenuExtensionMissingToolMenuContextObject : public UToolMenuContextBase
{
	GENERATED_BODY()
};

UCLASS()
class UAngelscriptEditorMenuExtensionContextTestShim : public UScriptEditorMenuExtension
{
	GENERATED_BODY()

public:
	static void ResetRecordedState();
	static UObject* GetLastCanExecuteContextObject();
	static bool WasLastCanExecuteMissingContextNull();
	static int32 GetCanExecuteInvocationCount();
	static UObject* GetLastCommandContextObject();
	static bool WasLastCommandMissingContextNull();
	static int32 GetCommandInvocationCount();
	static FName GetLastCommandFunctionName();

	UFUNCTION(CallInEditor, meta = (ActionCanExecute = "CanExecuteWithToolMenuContext"))
	void ContextAwareCommand();

	UFUNCTION()
	bool CanExecuteWithToolMenuContext() const;

protected:
	virtual void CallFunctionOnSelection(UFunction* Function, FExtenderSelection Selection) const override;
};

UCLASS()
class UAngelscriptEditorMenuExtensionCategoryTestShim : public UScriptEditorMenuExtension
{
	GENERATED_BODY()

public:
	UFUNCTION(CallInEditor, meta = (SortOrder = "5"))
	void TopLevelCommand();

	UFUNCTION(CallInEditor, meta = (Category = "Tools|Audit", SortOrder = "15"))
	void AuditCommand();

	UFUNCTION(CallInEditor, meta = (Category = "Tools|Bake", SortOrder = "20"))
	void BakeLaterCommand();

	UFUNCTION(CallInEditor, meta = (Category = "Tools|Bake", SortOrder = "10"))
	void BakeSoonerCommand();
};

UCLASS()
class UAngelscriptActorMenuExtensionTestShim : public UScriptActorMenuExtension
{
	GENERATED_BODY()

public:
	TArray<FName> GatheredFunctionNamesForSelection(const TArray<UObject*>& SelectedObjects) const;
	void InvokeSelectionFunction(FName FunctionName, const TArray<UObject*>& SelectedObjects);
	FName ResolveExtensionPoint() const;
	void ResetRecordedActors();

	UFUNCTION(CallInEditor)
	void RecordActor(AActor* Actor);

	UFUNCTION(CallInEditor)
	void RecordStaticMeshActor(AStaticMeshActor* Actor);

	UPROPERTY(Transient)
	TArray<FName> RecordedActorNames;

	UPROPERTY(Transient)
	TArray<FName> RecordedStaticMeshActorNames;
};

UCLASS()
class UAngelscriptAssetMenuExtensionTestShim : public UScriptAssetMenuExtension
{
	GENERATED_BODY()

public:
	TArray<FName> GatheredFunctionNamesForSelection(const TArray<FAssetData>& SelectedAssets) const;
	void InvokeSelectionFunction(FName FunctionName, const TArray<FAssetData>& SelectedAssets);
	FName ResolveExtensionPoint() const;
	void ResetRecordedAssets();

	UFUNCTION(CallInEditor)
	void RecordAssetObject(UCurveFloat* Asset);

	UFUNCTION(CallInEditor)
	void RecordAssetData(FAssetData AssetData);

	UPROPERTY(Transient)
	TArray<FName> RecordedObjectAssetNames;

	UPROPERTY(Transient)
	TArray<FName> RecordedStructAssetNames;
};
