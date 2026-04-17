#include "AngelscriptContentBrowserDataSource.h"
#include "AngelscriptEngine.h"
#include "AssetThumbnail.h"

void UAngelscriptContentBrowserDataSource::Initialize()
{
	Super::Initialize(true);
}

struct FAngelscriptContentBrowserPayload : IContentBrowserItemDataPayload
{
	FString Path;
	TWeakObjectPtr<UObject> Asset;
};

FContentBrowserItemData UAngelscriptContentBrowserDataSource::CreateAssetItem(UObject* Asset)
{
	auto Payload = MakeShared<FAngelscriptContentBrowserPayload>();
	Payload->Path = Asset->GetPathName();
	Payload->Asset = Asset;

	FString DisplayName = Asset->GetName();
	DisplayName.RemoveFromStart(TEXT("Asset_"));

	return FContentBrowserItemData(
		this,
		EContentBrowserItemFlags::Type_File | EContentBrowserItemFlags::Category_Asset,
		*(TEXT("/All/Angelscript/") + Asset->GetName()), Asset->GetFName(), FText::FromString(DisplayName), Payload, *Payload->Path);
}

void UAngelscriptContentBrowserDataSource::CompileFilter(const FName InPath, const FContentBrowserDataFilter& InFilter, FContentBrowserDataCompiledFilter& OutCompiledFilter)
{
	const FContentBrowserDataClassFilter* ClassFilter = InFilter.ExtraFilters.FindFilter<FContentBrowserDataClassFilter>();

	FContentBrowserDataFilterList& FilterList = OutCompiledFilter.CompiledFilters.FindOrAdd(this);
	FContentBrowserAngelscriptFilter& ScriptFilter = FilterList.FindOrAddFilter<FContentBrowserAngelscriptFilter>();
	ScriptFilter.IncludeClasses.Reset();
	ScriptFilter.ExcludeClasses.Reset();

	const bool bIncludeFiles = EnumHasAnyFlags(InFilter.ItemTypeFilter, EContentBrowserItemTypeFilter::IncludeFiles);
	const bool bIncludeAssets = EnumHasAnyFlags(InFilter.ItemCategoryFilter, EContentBrowserItemCategoryFilter::IncludeAssets);

	if (!bIncludeFiles || !bIncludeAssets)
		return;

	if (InPath != "/")
		return;

	if (ClassFilter == nullptr)
		return;

	for (const FString& ClassName : ClassFilter->ClassNamesToInclude)
	{
		UClass* LoadedClass = FindObject<UClass>(nullptr, *ClassName);
		if (LoadedClass != nullptr)
			ScriptFilter.IncludeClasses.Add(LoadedClass);
	}

	for (const FString& ClassName : ClassFilter->ClassNamesToExclude)
	{
		UClass* LoadedClass = FindObject<UClass>(nullptr, *ClassName);
		if (LoadedClass != nullptr)
			ScriptFilter.ExcludeClasses.Add(LoadedClass);
	}
}

void UAngelscriptContentBrowserDataSource::EnumerateItemsMatchingFilter(const FContentBrowserDataCompiledFilter& InFilter, TFunctionRef<bool(FContentBrowserItemData&&)> InCallback)
{
	const FContentBrowserDataFilterList* FilterList = InFilter.CompiledFilters.Find(this);
	if (!FilterList)
		return;
	
	const FContentBrowserAngelscriptFilter* ScriptFilter = FilterList->FindFilter<FContentBrowserAngelscriptFilter>();
	if (!ScriptFilter)
		return;

	if (ScriptFilter->IncludeClasses.IsEmpty())
		return;

	if (EnumHasAnyFlags(InFilter.ItemTypeFilter, EContentBrowserItemTypeFilter::IncludeFiles)
		&& EnumHasAnyFlags(InFilter.ItemCategoryFilter, EContentBrowserItemCategoryFilter::IncludeAssets))
	{
		TArray<UObject*> Assets;
		GetObjectsWithOuter(FAngelscriptEngine::Get().AssetsPackage, Assets);

		for (UObject* Object : Assets)
		{
			if (Object == nullptr)
				continue;

			bool bMatchesIncludes = false;
			for (UClass* Class : ScriptFilter->IncludeClasses)
			{
				if (Object->IsA(Class))
				{
					bMatchesIncludes = true;
					break;
				}
			}

			if (!bMatchesIncludes)
				continue;

			bool bMatchesExcludes = false;
			for (UClass* Class : ScriptFilter->ExcludeClasses)
			{
				if (Object->IsA(Class))
				{
					bMatchesExcludes = true;
					break;
				}
			}

			if (bMatchesExcludes)
				continue;


			if (!InCallback(CreateAssetItem(Object)))
			{
				return;
			}
		}
	}
}

void UAngelscriptContentBrowserDataSource::EnumerateItemsAtPath(const FName InPath, const EContentBrowserItemTypeFilter InItemTypeFilter, TFunctionRef<bool(FContentBrowserItemData&&)> InCallback)
{
}

bool UAngelscriptContentBrowserDataSource::EnumerateItemsForObjects(const TArrayView<UObject*> InObjects, TFunctionRef<bool(FContentBrowserItemData&&)> InCallback)
{
	return false;
}

bool UAngelscriptContentBrowserDataSource::DoesItemPassFilter(const FContentBrowserItemData& InItem, const FContentBrowserDataCompiledFilter& InFilter)
{
	const FContentBrowserDataFilterList* FilterList = InFilter.CompiledFilters.Find(this);
	if (FilterList == nullptr)
	{
		return false;
	}

	const FContentBrowserAngelscriptFilter* ScriptFilter = FilterList->FindFilter<FContentBrowserAngelscriptFilter>();
	if (ScriptFilter == nullptr)
	{
		return false;
	}

	if (InItem.GetOwnerDataSource() != this || !InItem.IsFile())
	{
		return false;
	}

	if (!EnumHasAnyFlags(InFilter.ItemTypeFilter, EContentBrowserItemTypeFilter::IncludeFiles)
		|| !EnumHasAnyFlags(InFilter.ItemCategoryFilter, EContentBrowserItemCategoryFilter::IncludeAssets)
		|| ScriptFilter->IncludeClasses.IsEmpty())
	{
		return false;
	}

	const TSharedPtr<const FAngelscriptContentBrowserPayload> Payload = StaticCastSharedPtr<const FAngelscriptContentBrowserPayload>(InItem.GetPayload());
	UObject* Asset = Payload.IsValid() ? Payload->Asset.Get() : nullptr;
	if (Asset == nullptr)
	{
		return false;
	}

	bool bMatchesIncludes = false;
	for (UClass* Class : ScriptFilter->IncludeClasses)
	{
		if (Asset->IsA(Class))
		{
			bMatchesIncludes = true;
			break;
		}
	}

	if (!bMatchesIncludes)
	{
		return false;
	}

	for (UClass* Class : ScriptFilter->ExcludeClasses)
	{
		if (Asset->IsA(Class))
		{
			return false;
		}
	}

	return true;
}

bool UAngelscriptContentBrowserDataSource::GetItemAttribute(const FContentBrowserItemData& InItem, const bool InIncludeMetaData, const FName InAttributeKey, FContentBrowserItemDataAttributeValue& OutAttributeValue)
{
	if (InItem.GetOwnerDataSource() == this && InItem.IsFile())
	{
		auto Payload = StaticCastSharedPtr<const FAngelscriptContentBrowserPayload>(InItem.GetPayload());
		UObject* Asset = Payload->Asset.Get();
		if (Asset == nullptr)
			return false;

		static const FName NAME_Type = "Type";

		if (InAttributeKey == ContentBrowserItemAttributes::ItemTypeName || InAttributeKey == NAME_Class || InAttributeKey == NAME_Type || InAttributeKey == ContentBrowserItemAttributes::ItemTypeDisplayName)
		{
			OutAttributeValue.SetValue(INVTEXT("Script Asset"));
			return true;
		}

		if (InAttributeKey == ContentBrowserItemAttributes::ItemIsEngineContent)
		{
			OutAttributeValue.SetValue(false);
			return true;
		}

		if (InAttributeKey == ContentBrowserItemAttributes::ItemIsProjectContent)
		{
			OutAttributeValue.SetValue(true);
			return true;
		}

		if (InAttributeKey == ContentBrowserItemAttributes::ItemIsPluginContent)
		{
			OutAttributeValue.SetValue(false);
			return true;
		}
	}

	return false;
}

bool UAngelscriptContentBrowserDataSource::GetItemAttributes(const FContentBrowserItemData& InItem, const bool InIncludeMetaData, FContentBrowserItemDataAttributeValues& OutAttributeValues)
{
	return false;
}

bool UAngelscriptContentBrowserDataSource::GetItemPhysicalPath(const FContentBrowserItemData& InItem, FString& OutDiskPath)
{
	return false;
}

bool UAngelscriptContentBrowserDataSource::CanEditItem(const FContentBrowserItemData& InItem, FText* OutErrorMsg)
{
	return false;
}

bool UAngelscriptContentBrowserDataSource::EditItem(const FContentBrowserItemData& InItem)
{
	return false;
}

bool UAngelscriptContentBrowserDataSource::BulkEditItems(TArrayView<const FContentBrowserItemData> InItems)
{
	return false;
}

bool UAngelscriptContentBrowserDataSource::AppendItemReference(const FContentBrowserItemData& InItem, FString& InOutStr)
{
	return false;
}

bool UAngelscriptContentBrowserDataSource::UpdateThumbnail(const FContentBrowserItemData& InItem, FAssetThumbnail& InThumbnail)
{
	if (InItem.GetOwnerDataSource() == this && InItem.IsFile())
	{
		auto Payload = StaticCastSharedPtr<const FAngelscriptContentBrowserPayload>(InItem.GetPayload());
		UObject* Asset = Payload->Asset.Get();
		if (Asset == nullptr)
			return false;

		auto AssetData = FAssetData(Asset, FAssetData::ECreationFlags::SkipAssetRegistryTagsGathering);
		InThumbnail.SetAsset(AssetData);
		return true;
	}

	return false;
}

bool UAngelscriptContentBrowserDataSource::TryGetCollectionId(const FContentBrowserItemData& InItem, FSoftObjectPath& OutCollectionId)
{
	return false;
}

bool UAngelscriptContentBrowserDataSource::Legacy_TryGetPackagePath(const FContentBrowserItemData& InItem, FName& OutPackagePath)
{
	if (InItem.GetOwnerDataSource() == this && InItem.IsFile())
	{
		auto Payload = StaticCastSharedPtr<const FAngelscriptContentBrowserPayload>(InItem.GetPayload());
		OutPackagePath = *Payload->Path;
		return true;
	}

	return false;
}

bool UAngelscriptContentBrowserDataSource::Legacy_TryGetAssetData(const FContentBrowserItemData& InItem, FAssetData& OutAssetData)
{
	if (InItem.GetOwnerDataSource() == this && InItem.IsFile())
	{
		auto Payload = StaticCastSharedPtr<const FAngelscriptContentBrowserPayload>(InItem.GetPayload());
		UObject* Asset = Payload->Asset.Get();
		if (Asset == nullptr)
			return false;

		OutAssetData = FAssetData(Asset, FAssetData::ECreationFlags::SkipAssetRegistryTagsGathering);
		return true;
	}

	return false;
}

bool UAngelscriptContentBrowserDataSource::Legacy_TryConvertPackagePathToVirtualPath(const FName InPackagePath, FName& OutPath)
{
	return false;
}

bool UAngelscriptContentBrowserDataSource::Legacy_TryConvertAssetDataToVirtualPath(const FAssetData& InAssetData, const bool InUseFolderPaths, FName& OutPath)
{
	return false;
}
