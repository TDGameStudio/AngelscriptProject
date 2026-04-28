#pragma once
#include "CoreMinimal.h"
#include "Engine/AssetManager.h"
#include "UAssetManagerMixinLibrary.generated.h"

//UCLASS(MinimalAPI, Meta = (ScriptMixin = "UAssetManager"))
UCLASS(MinimalAPI, Meta = ())
class UAssetManagerMixinLibrary : public UObject
{
	GENERATED_BODY()

public:
	/** Gets the FAssetData for a primary asset with the specified type/name, will only work for once that have been scanned for already. Returns true if it found a valid data */
	//UFUNCTION(ScriptCallable)
	UFUNCTION(BlueprintCallable)
	static bool GetPrimaryAssetData(UAssetManager* AssetManager, const FPrimaryAssetId& PrimaryAssetId, FAssetData& AssetData)
	{
		if (AssetManager == nullptr)
		{
			AssetData = FAssetData();
			return false;
		}

		const bool bFoundAssetData = AssetManager->GetPrimaryAssetData(PrimaryAssetId, AssetData);
		if (!bFoundAssetData)
		{
			AssetData = FAssetData();
		}

		return bFoundAssetData;
	}

	/** Gets list of all FAssetData for a primary asset type, returns true if any were found */
	//UFUNCTION(ScriptCallable)
	UFUNCTION(BlueprintCallable)
	static bool GetPrimaryAssetDataList(UAssetManager* AssetManager, FPrimaryAssetType PrimaryAssetType, TArray<FAssetData>& AssetDataList)
	{
		if (AssetManager == nullptr)
		{
			AssetDataList.Reset();
			return false;
		}

		AssetDataList.Reset();
		const bool bFoundAssetDataList = AssetManager->GetPrimaryAssetDataList(PrimaryAssetType, AssetDataList);
		if (!bFoundAssetDataList)
		{
			AssetDataList.Reset();
		}

		return bFoundAssetDataList;
	}

	/** Gets the in-memory UObject for a primary asset id, returning nullptr if it's not in memory. Will return blueprint class for blueprint assets. This works even if the asset wasn't loaded explicitly */
	//UFUNCTION(ScriptCallable)
	UFUNCTION(BlueprintCallable)
	static UObject* GetPrimaryAssetObject(UAssetManager* AssetManager, const FPrimaryAssetId& PrimaryAssetId)
	{
		if (AssetManager == nullptr)
		{
			return nullptr;
		}

		return AssetManager->GetPrimaryAssetObject(PrimaryAssetId);
	}

	/** Sees if the passed in object is a registered primary asset, if so return it. Returns invalid Identifier if not found */
	//UFUNCTION(ScriptCallable)
	UFUNCTION(BlueprintCallable)
	static FPrimaryAssetId GetPrimaryAssetIdForObject(UAssetManager* AssetManager, UObject* Object)
	{
		if (AssetManager == nullptr)
		{
			return FPrimaryAssetId();
		}

		return AssetManager->GetPrimaryAssetIdForObject(Object);
	}

	/** Gets list of all FPrimaryAssetId for a primary asset type, returns true if any were found */
	//UFUNCTION(ScriptCallable)
	UFUNCTION(BlueprintCallable)
	static bool GetPrimaryAssetIdList(UAssetManager* AssetManager, FPrimaryAssetType PrimaryAssetType, TArray<FPrimaryAssetId>& PrimaryAssetIdList)
	{
		if (AssetManager == nullptr)
		{
			PrimaryAssetIdList.Reset();
			return false;
		}

		PrimaryAssetIdList.Reset();
		const bool bFoundPrimaryAssetIdList = AssetManager->GetPrimaryAssetIdList(PrimaryAssetType, PrimaryAssetIdList);
		if (!bFoundPrimaryAssetIdList)
		{
			PrimaryAssetIdList.Reset();
		}

		return bFoundPrimaryAssetIdList;
	}

	/** Gets metadata for a specific asset type, returns false if not found */
	//UFUNCTION(ScriptCallable)
	UFUNCTION()
	static bool GetPrimaryAssetTypeInfo(UAssetManager* AssetManager, FPrimaryAssetType PrimaryAssetType, FPrimaryAssetTypeInfo& AssetTypeInfo)
	{
		if (AssetManager == nullptr)
		{
			AssetTypeInfo = FPrimaryAssetTypeInfo();
			return false;
		}

		const bool bFoundAssetTypeInfo = AssetManager->GetPrimaryAssetTypeInfo(PrimaryAssetType, AssetTypeInfo);
		if (!bFoundAssetTypeInfo)
		{
			AssetTypeInfo = FPrimaryAssetTypeInfo();
		}

		return bFoundAssetTypeInfo;
	}

	/** Gets list of all primary asset types infos */
	//UFUNCTION(ScriptCallable)
	UFUNCTION()
	static void GetPrimaryAssetTypeInfoList(UAssetManager* AssetManager, TArray<FPrimaryAssetTypeInfo>& AssetTypeInfoList)
	{
		if (AssetManager == nullptr)
		{
			AssetTypeInfoList.Reset();
			return;
		}

		AssetManager->GetPrimaryAssetTypeInfoList(AssetTypeInfoList);
	}

	/** Gets the management rules for a specific asset, this will merge the type and individual values */
	//UFUNCTION(ScriptCallable)
	UFUNCTION()
	static FPrimaryAssetRules GetPrimaryAssetRules(UAssetManager* AssetManager, const FPrimaryAssetId& PrimaryAssetId)
	{
		if (AssetManager == nullptr)
		{
			return FPrimaryAssetRules();
		}

		return AssetManager->GetPrimaryAssetRules(PrimaryAssetId);
	}

	/** Register a function to call when all types are scanned at startup, if this has already happened call immediately */
	//UFUNCTION(ScriptCallable, Meta = (DelegateObjectParam = "Object", DelegateFunctionParam = "FunctionName", DelegateBindType = "FSimpleDelegate"))
	UFUNCTION(BlueprintCallable, Meta = (DelegateObjectParam = "Object", DelegateFunctionParam = "FunctionName", DelegateBindType = "FSimpleDelegate"))
	static void CallOrRegister_OnCompletedInitialScan(UAssetManager* AssetManager, UObject* Object, const FName& FunctionName)
	{
		if (AssetManager == nullptr || Object == nullptr || FunctionName.IsNone() || Object->FindFunction(FunctionName) == nullptr)
		{
			return;
		}

		AssetManager->CallOrRegister_OnCompletedInitialScan(FSimpleDelegate::CreateUFunction(Object, FunctionName));
	}
};
