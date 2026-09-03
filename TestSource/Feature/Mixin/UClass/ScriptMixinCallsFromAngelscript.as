/**
 * UAssetManager script mixin probes. C++ expects each Run*Probe to return 1
 * after the initial scan, and CallbackCount==1. The observers cover a null
 * probe handle, default CallbackCount, a null AssetManager, and a null
 * ProbeObject.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.ScriptMixinCallsFromAngelscript
 * @Harness UClass
 * @Tag Feature.Mixin.ScriptMixinCallsFromAngelscript
 * @Provenance Theme: Feature.Mixin. Positive UAssetManager script mixin probes.
 * @Provenance C++: AngelscriptAssetManagerFunctionLibraryTests.cpp::ScriptMixinCallsFromAngelscript
 * @Provenance Oracle after initial scan: each Run*Probe returns 1; CallbackCount==1.
 * @Provenance Extra: null AssetManager returns 10; null ProbeObject returns 20. DefaultSafe.
 * @Provenance Keep CallbackCount and every Run*Probe / MissingAssetId / MissingAssetType.
 */

UCLASS()
class UAssetManagerScriptCallProbe : UObject
{
	UPROPERTY()
	int CallbackCount;

	/**
	 * Initial-scan callback that increments CallbackCount.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.ScriptMixinCallsFromAngelscript
	 * @Inputs none
	 * @Return void; CallbackCount increases by 1
	 */
	UFUNCTION()
	void OnInitialScanComplete()
	{
		CallbackCount += 1;
	}

	/**
	 * Probe GetPrimaryAssetData for a missing asset id.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.ScriptMixinCallsFromAngelscript
	 * @Inputs an AssetManager and MissingAssetId
	 * @Param AssetManager the manager; null returns 10
	 * @Return 1 when the missing id is not found; 10 if AssetManager is null; 30 if found
	 */
	UFUNCTION()
	int RunGetPrimaryAssetDataProbe(UAssetManager AssetManager)
	{
		Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.GetPrimaryAssetData: begin");

		if (AssetManager == null)
		{
			Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.GetPrimaryAssetData: AssetManager is null, result=10");
			return 10;
		}

		FPrimaryAssetId MissingAssetId("ASAssetManagerMissingType:ASAssetManagerMissingName");
		FAssetData AssetData;
		bool bFoundAssetData = AssetManager.GetPrimaryAssetData(MissingAssetId, AssetData);
		Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.GetPrimaryAssetData: found=" + bFoundAssetData);
		return bFoundAssetData ? 30 : 1;
	}

	/**
	 * Probe GetPrimaryAssetDataList for a missing asset type.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.ScriptMixinCallsFromAngelscript
	 * @Inputs an AssetManager and MissingAssetType
	 * @Param AssetManager the manager; null returns 10
	 * @Return 1 when the list is empty; 10 if AssetManager is null; 40 if found; 41 if count is non-zero
	 */
	UFUNCTION()
	int RunGetPrimaryAssetDataListProbe(UAssetManager AssetManager)
	{
		Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.GetPrimaryAssetDataList: begin");

		if (AssetManager == null)
		{
			Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.GetPrimaryAssetDataList: AssetManager is null, result=10");
			return 10;
		}

		FPrimaryAssetType MissingAssetType(n"ASAssetManagerMissingType");
		TArray<FAssetData> AssetDataList;
		bool bFoundAssetDataList = AssetManager.GetPrimaryAssetDataList(MissingAssetType, AssetDataList);
		Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.GetPrimaryAssetDataList: found=" + bFoundAssetDataList + " count=" + AssetDataList.Num());
		if (bFoundAssetDataList)
		{
			return 40;
		}
		if (AssetDataList.Num() != 0)
		{
			return 41;
		}
		return 1;
	}

	/**
	 * Probe GetPrimaryAssetObject for a missing asset id.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.ScriptMixinCallsFromAngelscript
	 * @Inputs an AssetManager and MissingAssetId
	 * @Param AssetManager the manager; null returns 10
	 * @Return 1 when the object is null; 10 if AssetManager is null; 50 if found
	 */
	UFUNCTION()
	int RunGetPrimaryAssetObjectProbe(UAssetManager AssetManager)
	{
		Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.GetPrimaryAssetObject: begin");

		if (AssetManager == null)
		{
			Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.GetPrimaryAssetObject: AssetManager is null, result=10");
			return 10;
		}

		FPrimaryAssetId MissingAssetId("ASAssetManagerMissingType:ASAssetManagerMissingName");
		UObject FoundObject = AssetManager.GetPrimaryAssetObject(MissingAssetId);
		Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.GetPrimaryAssetObject: isValid=" + (FoundObject != null));
		return FoundObject != null ? 50 : 1;
	}

	/**
	 * Probe GetPrimaryAssetIdForObject for a non-primary object.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.ScriptMixinCallsFromAngelscript
	 * @Inputs an AssetManager and a probe object
	 * @Param AssetManager the manager; null returns 10
	 * @Param ProbeObject the object to look up; null returns 20
	 * @Return 1 when the id is invalid; 10 if AssetManager is null; 20 if ProbeObject is null; 60 if valid
	 */
	UFUNCTION()
	int RunGetPrimaryAssetIdForObjectProbe(UAssetManager AssetManager, UObject ProbeObject)
	{
		Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.GetPrimaryAssetIdForObject: begin");

		if (AssetManager == null)
		{
			Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.GetPrimaryAssetIdForObject: AssetManager is null, result=10");
			return 10;
		}

		if (ProbeObject == null)
		{
			Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.GetPrimaryAssetIdForObject: ProbeObject is null, result=20");
			return 20;
		}

		FPrimaryAssetId ObjectAssetId = AssetManager.GetPrimaryAssetIdForObject(ProbeObject);
		bool bObjectAssetIdValid = ObjectAssetId.IsValid();
		Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.GetPrimaryAssetIdForObject: isValid=" + bObjectAssetIdValid);
		return bObjectAssetIdValid ? 60 : 1;
	}

	/**
	 * Probe GetPrimaryAssetIdList for a missing asset type.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.ScriptMixinCallsFromAngelscript
	 * @Inputs an AssetManager and MissingAssetType
	 * @Param AssetManager the manager; null returns 10
	 * @Return 1 when the list is empty; 10 if AssetManager is null; 70 if found; 71 if count is non-zero
	 */
	UFUNCTION()
	int RunGetPrimaryAssetIdListProbe(UAssetManager AssetManager)
	{
		Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.GetPrimaryAssetIdList: begin");

		if (AssetManager == null)
		{
			Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.GetPrimaryAssetIdList: AssetManager is null, result=10");
			return 10;
		}

		FPrimaryAssetType MissingAssetType(n"ASAssetManagerMissingType");
		TArray<FPrimaryAssetId> PrimaryAssetIds;
		bool bFoundPrimaryAssetIds = AssetManager.GetPrimaryAssetIdList(MissingAssetType, PrimaryAssetIds);
		Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.GetPrimaryAssetIdList: found=" + bFoundPrimaryAssetIds + " count=" + PrimaryAssetIds.Num());
		if (bFoundPrimaryAssetIds)
		{
			return 70;
		}
		if (PrimaryAssetIds.Num() != 0)
		{
			return 71;
		}
		return 1;
	}

	/**
	 * Probe CallOrRegister_OnCompletedInitialScan and expect CallbackCount==1.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.ScriptMixinCallsFromAngelscript
	 * @Inputs an AssetManager
	 * @Param AssetManager the manager; null returns 10
	 * @Return 1 when CallbackCount is 1; 10 if AssetManager is null; 80 otherwise
	 */
	UFUNCTION()
	int RunInitialScanCallbackProbe(UAssetManager AssetManager)
	{
		Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.InitialScanCallback: begin");

		if (AssetManager == null)
		{
			Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.InitialScanCallback: AssetManager is null, result=10");
			return 10;
		}

		Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.InitialScanCallback: callback count before=" + CallbackCount);
		AssetManager.CallOrRegister_OnCompletedInitialScan(this, n"OnInitialScanComplete");
		int Result = CallbackCount == 1 ? 1 : 80;
		Log(n"AssetManagerBindings", "ASAssetManagerScriptMixinCalls.InitialScanCallback: callback count after=" + CallbackCount + " result=" + Result);
		return Result;
	}

	/**
	 * Observe that an unset probe handle is null.
	 *
	 * @Kind Observe
	 * @Covers Mixin.ScriptMixinCallsFromAngelscript
	 * @Inputs an unset UAssetManagerScriptCallProbe handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UAssetManagerScriptCallProbe Probe;
		return Probe == nullptr;
	}

	/**
	 * Observe that CallbackCount starts at 0.
	 *
	 * @Kind Observe
	 * @Covers Mixin.ScriptMixinCallsFromAngelscript
	 * @Inputs this probe before any callback
	 * @Return CallbackCount
	 * @Boundary default CallbackCount
	 */
	UFUNCTION()
	int DefaultCallbackCount()
	{
		return CallbackCount;
	}

	/**
	 * Observe that a null AssetManager returns 10 from GetPrimaryAssetData.
	 *
	 * @Kind Observe
	 * @Covers Mixin.ScriptMixinCallsFromAngelscript
	 * @Inputs this probe and a null AssetManager
	 * @Return RunGetPrimaryAssetDataProbe(null)
	 * @Boundary null AssetManager
	 */
	UFUNCTION()
	int NullAssetManagerData()
	{
		return RunGetPrimaryAssetDataProbe(null);
	}

	/**
	 * Observe that a null ProbeObject returns 20 from GetPrimaryAssetIdForObject.
	 *
	 * @Kind Observe
	 * @Covers Mixin.ScriptMixinCallsFromAngelscript
	 * @Inputs this probe, an AssetManager, and a null ProbeObject
	 * @Param AssetManager the manager passed through
	 * @Return RunGetPrimaryAssetIdForObjectProbe(AssetManager, null)
	 * @Boundary null ProbeObject
	 */
	UFUNCTION()
	int NullProbeObject(UAssetManager AssetManager)
	{
		return RunGetPrimaryAssetIdForObjectProbe(AssetManager, null);
	}
}
