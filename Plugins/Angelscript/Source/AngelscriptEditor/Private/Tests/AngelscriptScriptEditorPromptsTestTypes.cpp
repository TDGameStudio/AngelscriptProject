#include "Tests/AngelscriptScriptEditorPromptsTestTypes.h"

namespace AngelscriptEditor_Private_Tests_AngelscriptScriptEditorPromptsTestTypes_Private
{
	TArray<FName> GScriptEditorPromptsBatchInvocationOrder;
}

using namespace AngelscriptEditor_Private_Tests_AngelscriptScriptEditorPromptsTestTypes_Private;

void UAngelscriptScriptEditorPromptsAssetReceiver::ResetRecordedAssets()
{
	InvocationCount = 0;
	RecordedAssetNames.Reset();
	RecordedPackageNames.Reset();
	RecordedExtraValues.Reset();
}

void UAngelscriptScriptEditorPromptsAssetReceiver::RecordAsset(FAssetData SelectedAsset, int32 ExtraValue)
{
	++InvocationCount;
	RecordedAssetNames.Add(SelectedAsset.AssetName);
	RecordedPackageNames.Add(SelectedAsset.PackageName);
	RecordedExtraValues.Add(ExtraValue);
}

void UAngelscriptScriptEditorPromptsBatchReceiver::ResetBatchInvocations()
{
	GScriptEditorPromptsBatchInvocationOrder.Reset();
}

const TArray<FName>& UAngelscriptScriptEditorPromptsBatchReceiver::GetInvocationOrder()
{
	return GScriptEditorPromptsBatchInvocationOrder;
}

void UAngelscriptScriptEditorPromptsBatchReceiver::RecordBatch(int32 ExtraValue)
{
	++InvocationCount;
	LastExtraValue = ExtraValue;
	GScriptEditorPromptsBatchInvocationOrder.Add(ReceiverLabel);
}
