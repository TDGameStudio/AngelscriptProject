#include "Tests/AngelscriptEditorMenuExtensionsTestTypes.h"

#include "Engine/StaticMeshActor.h"

namespace AngelscriptEditor_Private_Tests_AngelscriptEditorMenuExtensionsTestTypes_Private
{
	bool GMenuExtensionActionCanExecute = true;
	bool GMenuExtensionActionVisible = true;
	bool GMenuExtensionActionChecked = false;
	int32 GMenuExtensionPromptInvocationCount = 0;
	FName GMenuExtensionLastPromptFunctionName = NAME_None;
	int32 GMenuExtensionCanExecuteEvaluationCount = 0;
	int32 GMenuExtensionVisibleEvaluationCount = 0;
	int32 GMenuExtensionCheckedEvaluationCount = 0;
	TWeakObjectPtr<UObject> GMenuExtensionContextCanExecuteObject;
	bool GMenuExtensionContextCanExecuteMissingWasNull = true;
	int32 GMenuExtensionContextCanExecuteInvocationCount = 0;
	TWeakObjectPtr<UObject> GMenuExtensionContextCommandObject;
	bool GMenuExtensionContextCommandMissingWasNull = true;
	int32 GMenuExtensionContextCommandInvocationCount = 0;
	FName GMenuExtensionContextLastCommandFunctionName = NAME_None;
}

using namespace AngelscriptEditor_Private_Tests_AngelscriptEditorMenuExtensionsTestTypes_Private;

TArray<FName> UAngelscriptEditorMenuExtensionTestShim::GatheredFunctionNames() const
{
	TArray<FName> Names;
	for (UFunction* Function : GatherExtensionFunctions())
	{
		Names.Add(Function->GetFName());
	}
	return Names;
}

FName UAngelscriptEditorMenuExtensionTestShim::ResolveExtensionPoint() const
{
	return GetExtensionPointOrDefault();
}

void UAngelscriptEditorMenuExtensionTestShim::IncludedCommand()
{
}

void UAngelscriptEditorMenuExtensionTestShim::IncludedSecondaryCommand()
{
}

int32 UAngelscriptEditorMenuExtensionTestShim::ExcludedReturnsValue() const
{
	return 1;
}

void UAngelscriptEditorMenuExtensionTestShim::ExcludedWithoutCallInEditor()
{
}

void UAngelscriptEditorMenuExtensionActionTestShim::ResetRecordedState()
{
	GMenuExtensionActionCanExecute = true;
	GMenuExtensionActionVisible = true;
	GMenuExtensionActionChecked = false;
	GMenuExtensionPromptInvocationCount = 0;
	GMenuExtensionLastPromptFunctionName = NAME_None;
	GMenuExtensionCanExecuteEvaluationCount = 0;
	GMenuExtensionVisibleEvaluationCount = 0;
	GMenuExtensionCheckedEvaluationCount = 0;
}

void UAngelscriptEditorMenuExtensionActionTestShim::ConfigureActionResponses(bool bInCanExecute, bool bInVisible, bool bInChecked)
{
	GMenuExtensionActionCanExecute = bInCanExecute;
	GMenuExtensionActionVisible = bInVisible;
	GMenuExtensionActionChecked = bInChecked;
}

int32 UAngelscriptEditorMenuExtensionActionTestShim::GetPromptInvocationCount()
{
	return GMenuExtensionPromptInvocationCount;
}

FName UAngelscriptEditorMenuExtensionActionTestShim::GetLastPromptFunctionName()
{
	return GMenuExtensionLastPromptFunctionName;
}

int32 UAngelscriptEditorMenuExtensionActionTestShim::GetCanExecuteEvaluationCount()
{
	return GMenuExtensionCanExecuteEvaluationCount;
}

int32 UAngelscriptEditorMenuExtensionActionTestShim::GetVisibleEvaluationCount()
{
	return GMenuExtensionVisibleEvaluationCount;
}

int32 UAngelscriptEditorMenuExtensionActionTestShim::GetCheckedEvaluationCount()
{
	return GMenuExtensionCheckedEvaluationCount;
}

void UAngelscriptEditorMenuExtensionActionTestShim::MetadataDrivenCommand()
{
}

bool UAngelscriptEditorMenuExtensionActionTestShim::CanExecuteMetadata() const
{
	++GMenuExtensionCanExecuteEvaluationCount;
	return GMenuExtensionActionCanExecute;
}

bool UAngelscriptEditorMenuExtensionActionTestShim::IsVisibleMetadata() const
{
	++GMenuExtensionVisibleEvaluationCount;
	return GMenuExtensionActionVisible;
}

bool UAngelscriptEditorMenuExtensionActionTestShim::IsCheckedMetadata() const
{
	++GMenuExtensionCheckedEvaluationCount;
	return GMenuExtensionActionChecked;
}

void UAngelscriptEditorMenuExtensionActionTestShim::CallFunctionOnSelection(UFunction* Function, FExtenderSelection Selection) const
{
	++GMenuExtensionPromptInvocationCount;
	GMenuExtensionLastPromptFunctionName = Function != nullptr ? Function->GetFName() : NAME_None;
}

void UAngelscriptEditorMenuExtensionContextTestShim::ResetRecordedState()
{
	GMenuExtensionContextCanExecuteObject.Reset();
	GMenuExtensionContextCanExecuteMissingWasNull = true;
	GMenuExtensionContextCanExecuteInvocationCount = 0;
	GMenuExtensionContextCommandObject.Reset();
	GMenuExtensionContextCommandMissingWasNull = true;
	GMenuExtensionContextCommandInvocationCount = 0;
	GMenuExtensionContextLastCommandFunctionName = NAME_None;
}

UObject* UAngelscriptEditorMenuExtensionContextTestShim::GetLastCanExecuteContextObject()
{
	return GMenuExtensionContextCanExecuteObject.Get();
}

bool UAngelscriptEditorMenuExtensionContextTestShim::WasLastCanExecuteMissingContextNull()
{
	return GMenuExtensionContextCanExecuteMissingWasNull;
}

int32 UAngelscriptEditorMenuExtensionContextTestShim::GetCanExecuteInvocationCount()
{
	return GMenuExtensionContextCanExecuteInvocationCount;
}

UObject* UAngelscriptEditorMenuExtensionContextTestShim::GetLastCommandContextObject()
{
	return GMenuExtensionContextCommandObject.Get();
}

bool UAngelscriptEditorMenuExtensionContextTestShim::WasLastCommandMissingContextNull()
{
	return GMenuExtensionContextCommandMissingWasNull;
}

int32 UAngelscriptEditorMenuExtensionContextTestShim::GetCommandInvocationCount()
{
	return GMenuExtensionContextCommandInvocationCount;
}

FName UAngelscriptEditorMenuExtensionContextTestShim::GetLastCommandFunctionName()
{
	return GMenuExtensionContextLastCommandFunctionName;
}

void UAngelscriptEditorMenuExtensionContextTestShim::ContextAwareCommand()
{
	++GMenuExtensionContextCommandInvocationCount;
	GMenuExtensionContextCommandObject = GetToolMenuContext(UAngelscriptEditorMenuExtensionToolMenuContextObject::StaticClass());
	GMenuExtensionContextCommandMissingWasNull = GetToolMenuContext(UAngelscriptEditorMenuExtensionMissingToolMenuContextObject::StaticClass()) == nullptr;
}

bool UAngelscriptEditorMenuExtensionContextTestShim::CanExecuteWithToolMenuContext() const
{
	++GMenuExtensionContextCanExecuteInvocationCount;
	GMenuExtensionContextCanExecuteObject = GetToolMenuContext(UAngelscriptEditorMenuExtensionToolMenuContextObject::StaticClass());
	GMenuExtensionContextCanExecuteMissingWasNull = GetToolMenuContext(UAngelscriptEditorMenuExtensionMissingToolMenuContextObject::StaticClass()) == nullptr;
	return GMenuExtensionContextCanExecuteObject.IsValid();
}

void UAngelscriptEditorMenuExtensionContextTestShim::CallFunctionOnSelection(UFunction* Function, FExtenderSelection Selection) const
{
	GMenuExtensionContextLastCommandFunctionName = Function != nullptr ? Function->GetFName() : NAME_None;
	if (Function != nullptr)
	{
		const_cast<UAngelscriptEditorMenuExtensionContextTestShim*>(this)->ProcessEvent(Function, nullptr);
	}
}

void UAngelscriptEditorMenuExtensionCategoryTestShim::TopLevelCommand()
{
}

void UAngelscriptEditorMenuExtensionCategoryTestShim::AuditCommand()
{
}

void UAngelscriptEditorMenuExtensionCategoryTestShim::BakeLaterCommand()
{
}

void UAngelscriptEditorMenuExtensionCategoryTestShim::BakeSoonerCommand()
{
}

TArray<FName> UAngelscriptActorMenuExtensionTestShim::GatheredFunctionNamesForSelection(const TArray<UObject*>& SelectedObjects) const
{
	FExtenderSelection Selection;
	Selection.SelectedObjects = SelectedObjects;

	TGuardValue<FExtenderSelection> ScopeSelection(CurrentSelection, Selection);

	TArray<FName> Names;
	for (UFunction* Function : GatherExtensionFunctions())
	{
		Names.Add(Function->GetFName());
	}
	return Names;
}

void UAngelscriptActorMenuExtensionTestShim::InvokeSelectionFunction(FName FunctionName, const TArray<UObject*>& SelectedObjects)
{
	FExtenderSelection Selection;
	Selection.SelectedObjects = SelectedObjects;
	CallFunctionOnSelection(FindFunctionChecked(FunctionName), Selection);
}

FName UAngelscriptActorMenuExtensionTestShim::ResolveExtensionPoint() const
{
	return GetExtensionPointOrDefault();
}

void UAngelscriptActorMenuExtensionTestShim::ResetRecordedActors()
{
	RecordedActorNames.Reset();
	RecordedStaticMeshActorNames.Reset();
}

void UAngelscriptActorMenuExtensionTestShim::RecordActor(AActor* Actor)
{
	if (Actor != nullptr)
	{
		RecordedActorNames.Add(Actor->GetFName());
	}
}

void UAngelscriptActorMenuExtensionTestShim::RecordStaticMeshActor(AStaticMeshActor* Actor)
{
	if (Actor != nullptr)
	{
		RecordedStaticMeshActorNames.Add(Actor->GetFName());
	}
}

TArray<FName> UAngelscriptAssetMenuExtensionTestShim::GatheredFunctionNamesForSelection(const TArray<FAssetData>& SelectedAssets) const
{
	FExtenderSelection Selection;
	Selection.SelectedAssets = SelectedAssets;

	TGuardValue<FExtenderSelection> ScopeSelection(CurrentSelection, Selection);

	TArray<FName> Names;
	for (UFunction* Function : GatherExtensionFunctions())
	{
		Names.Add(Function->GetFName());
	}
	return Names;
}

void UAngelscriptAssetMenuExtensionTestShim::InvokeSelectionFunction(FName FunctionName, const TArray<FAssetData>& SelectedAssets)
{
	FExtenderSelection Selection;
	Selection.SelectedAssets = SelectedAssets;
	CallFunctionOnSelection(FindFunctionChecked(FunctionName), Selection);
}

FName UAngelscriptAssetMenuExtensionTestShim::ResolveExtensionPoint() const
{
	return GetExtensionPointOrDefault();
}

void UAngelscriptAssetMenuExtensionTestShim::ResetRecordedAssets()
{
	RecordedObjectAssetNames.Reset();
	RecordedStructAssetNames.Reset();
}

void UAngelscriptAssetMenuExtensionTestShim::RecordAssetObject(UCurveFloat* Asset)
{
	if (Asset != nullptr)
	{
		RecordedObjectAssetNames.Add(Asset->GetFName());
	}
}

void UAngelscriptAssetMenuExtensionTestShim::RecordAssetData(FAssetData AssetData)
{
	if (AssetData.IsValid())
	{
		RecordedStructAssetNames.Add(AssetData.AssetName);
	}
}
