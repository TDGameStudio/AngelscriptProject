/**
 * @version v1
 * @summary Observe AssetRegistry::AssetCreated notifying the registry of a newly created object.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe AssetRegistry::AssetCreated notifying the registry of a newly created object.
 * @topic Baseline
 */
// the same object, and a null NewAsset as the empty handle.
// Expected observations: AssetCreated returns for a live object. Repeating
// the notify is accepted. A null handle is the empty-input boundary.
// Boundary/ownership: The registry borrows NewAsset; the caller remains the
// object's outer/owner. A null NewObject result is setup failure.

namespace TS_AssetRegistry_ConversionAndFormatting_01
{
	bool Observe_AssetCreated_Nominal()
	{
		UObject NewAsset = NewObject(GetTransientPackage(), UTexture2D::StaticClass(), n"TSAssetRegistryCreated", true);
		if (NewAsset is null)
		{
			throw("TS_AssetRegistry_ConversionAndFormatting_01 setup: required NewAsset is null");
		}
		AssetRegistry::AssetCreated(NewAsset);
		AssetRegistry::AssetCreated(NewAsset);
		UObject NullAsset = nullptr;
		AssetRegistry::AssetCreated(NullAsset);
		return NewAsset.GetName() == "TSAssetRegistryCreated";
	}
}
/** @end */
