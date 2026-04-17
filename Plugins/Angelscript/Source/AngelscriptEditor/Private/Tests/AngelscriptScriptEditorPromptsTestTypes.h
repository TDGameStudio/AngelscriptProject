#pragma once

#include "CoreMinimal.h"
#include "AssetRegistry/AssetData.h"
#include "UObject/Object.h"

#include "AngelscriptScriptEditorPromptsTestTypes.generated.h"

UCLASS()
class UAngelscriptScriptEditorPromptsAssetReceiver : public UObject
{
	GENERATED_BODY()

public:
	void ResetRecordedAssets();

	UFUNCTION(CallInEditor, meta = (CPP_Default_ExtraValue = "42"))
	void RecordAsset(FAssetData SelectedAsset, int32 ExtraValue = 42);

	UPROPERTY(Transient)
	int32 InvocationCount = 0;

	UPROPERTY(Transient)
	TArray<FName> RecordedAssetNames;

	UPROPERTY(Transient)
	TArray<FName> RecordedPackageNames;

	UPROPERTY(Transient)
	TArray<int32> RecordedExtraValues;
};

UCLASS()
class UAngelscriptScriptEditorPromptsBatchReceiver : public UObject
{
	GENERATED_BODY()

public:
	static void ResetBatchInvocations();
	static const TArray<FName>& GetInvocationOrder();

	UFUNCTION(CallInEditor, meta = (CPP_Default_ExtraValue = "7"))
	void RecordBatch(int32 ExtraValue = 7);

	UPROPERTY(Transient)
	FName ReceiverLabel;

	UPROPERTY(Transient)
	int32 InvocationCount = 0;

	UPROPERTY(Transient)
	int32 LastExtraValue = INDEX_NONE;
};

UCLASS()
class UAngelscriptScriptEditorPromptsUnrelatedObject : public UObject
{
	GENERATED_BODY()
};
