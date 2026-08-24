// Theme: Feature.Mixin. Positive UAssetManager script mixin probes.
// C++: AngelscriptAssetManagerFunctionLibraryTests.cpp::ScriptMixinCallsFromAngelscript
// Oracle after initial scan: each Run*Probe returns 1; CallbackCount==1.
// Extra: null AssetManager returns 10; null ProbeObject returns 20. DefaultSafe.
// Keep CallbackCount and every Run*Probe / MissingAssetId / MissingAssetType.

UCLASS()
class UAssetManagerScriptCallProbe : UObject
{
	UPROPERTY()
	int CallbackCount;

	UFUNCTION()
	void OnInitialScanComplete()
	{
		CallbackCount += 1;
	}

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
}

bool Observe_AssetMixin_EmptyHandleIsNull()
{
	UAssetManagerScriptCallProbe Probe;
	return Probe == nullptr;
}

int Observe_AssetMixin_DefaultCallbackCount(UAssetManagerScriptCallProbe Probe)
{
	if (Probe == nullptr)
	{
		throw("TS-FEAT-0228 setup: required UAssetManagerScriptCallProbe is null");
	}
	return Probe.CallbackCount;
}

int Observe_AssetMixin_NullAssetManagerData(UAssetManagerScriptCallProbe Probe)
{
	if (Probe == nullptr)
	{
		throw("TS-FEAT-0228 setup: required UAssetManagerScriptCallProbe is null");
	}
	return Probe.RunGetPrimaryAssetDataProbe(null);
}

int Observe_AssetMixin_NullProbeObject(UAssetManagerScriptCallProbe Probe, UAssetManager AssetManager)
{
	if (Probe == nullptr)
	{
		throw("TS-FEAT-0228 setup: required UAssetManagerScriptCallProbe is null");
	}
	return Probe.RunGetPrimaryAssetIdForObjectProbe(AssetManager, null);
}

int Observe_AssetMixin_GetPrimaryAssetData(UAssetManagerScriptCallProbe Probe, UAssetManager AssetManager)
{
	if (Probe == nullptr)
	{
		throw("TS-FEAT-0228 setup: required UAssetManagerScriptCallProbe is null");
	}
	return Probe.RunGetPrimaryAssetDataProbe(AssetManager);
}

int Observe_AssetMixin_GetPrimaryAssetDataList(UAssetManagerScriptCallProbe Probe, UAssetManager AssetManager)
{
	if (Probe == nullptr)
	{
		throw("TS-FEAT-0228 setup: required UAssetManagerScriptCallProbe is null");
	}
	return Probe.RunGetPrimaryAssetDataListProbe(AssetManager);
}

int Observe_AssetMixin_GetPrimaryAssetObject(UAssetManagerScriptCallProbe Probe, UAssetManager AssetManager)
{
	if (Probe == nullptr)
	{
		throw("TS-FEAT-0228 setup: required UAssetManagerScriptCallProbe is null");
	}
	return Probe.RunGetPrimaryAssetObjectProbe(AssetManager);
}

int Observe_AssetMixin_GetPrimaryAssetIdForObject(UAssetManagerScriptCallProbe Probe, UAssetManager AssetManager, UObject ProbeObject)
{
	if (Probe == nullptr)
	{
		throw("TS-FEAT-0228 setup: required UAssetManagerScriptCallProbe is null");
	}
	return Probe.RunGetPrimaryAssetIdForObjectProbe(AssetManager, ProbeObject);
}

int Observe_AssetMixin_GetPrimaryAssetIdList(UAssetManagerScriptCallProbe Probe, UAssetManager AssetManager)
{
	if (Probe == nullptr)
	{
		throw("TS-FEAT-0228 setup: required UAssetManagerScriptCallProbe is null");
	}
	return Probe.RunGetPrimaryAssetIdListProbe(AssetManager);
}

int Observe_AssetMixin_InitialScanCallback(UAssetManagerScriptCallProbe Probe, UAssetManager AssetManager)
{
	if (Probe == nullptr)
	{
		throw("TS-FEAT-0228 setup: required UAssetManagerScriptCallProbe is null");
	}
	return Probe.RunInitialScanCallbackProbe(AssetManager);
}
