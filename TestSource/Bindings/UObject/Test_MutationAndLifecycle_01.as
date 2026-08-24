// Purpose: Observe UObject root, transactional flag, config reload, string
// Append, and LoadObject.
// Runner owns mutation fixtures. LoadObject is the lookup API under test.
// AS-facing API: void UObject.AddToRoot(); void UObject.RemoveFromRoot();
// void UObject.SetTransactional(bool bTransactional);
// void UObject.SaveConfig(); void UObject.LoadConfig();
// Text.Append(Object); UObject LoadObject(UObject Outer, const FString& Name);
// Inputs: Runner-owned UObject, prefix "obj:", LoadObject of that object's
// path, a missing path, and empty name.
// Expected observations: AddToRoot makes GetIsRooted true; RemoveFromRoot
// restores false. SaveConfig/LoadConfig leave the object valid. Append grows
// the string. LoadObject of the live path returns that object; missing names
// return null.
// Boundary/ownership: Rooting keeps the object alive for GC. LoadObject uses
// Outer as resolution context. SetupOwner=Runner.

namespace TS_UObject_MutationAndLifecycle_01
{
	bool Observe_AddToRoot_Nominal(UObject Object)
	{
		if (Object is null)
		{
			throw("TS_UObject_MutationAndLifecycle_01 setup: required Object is null");
		}
		bool bBefore = Object.GetIsRooted();
		Object.AddToRoot();
		bool bAfter = Object.GetIsRooted();
		Object.AddToRoot();
		bool bRepeat = Object.GetIsRooted();
		if (!bBefore)
		{
			Object.RemoveFromRoot();
		}
		return !bBefore && bAfter && bRepeat;
	}

	bool Observe_RemoveFromRoot_Nominal(UObject Object)
	{
		if (Object is null)
		{
			throw("TS_UObject_MutationAndLifecycle_01 setup: required Object is null");
		}
		bool bBefore = Object.GetIsRooted();
		Object.AddToRoot();
		Object.RemoveFromRoot();
		bool bAfterRemove = Object.GetIsRooted();
		Object.RemoveFromRoot();
		bool bRepeat = Object.GetIsRooted();
		if (bBefore)
		{
			Object.AddToRoot();
		}
		return !bAfterRemove && !bRepeat;
	}

	bool Observe_SetTransactional_Nominal(UObject Object)
	{
		if (Object is null)
		{
			throw("TS_UObject_MutationAndLifecycle_01 setup: required Object is null");
		}
		UClass Before = Object.GetClass();
		Object.SetTransactional(true);
		Object.SetTransactional(true);
		Object.SetTransactional(false);
		return Object.GetClass() == Before && IsValid(Object);
	}

	bool Observe_SaveConfig_Nominal(UObject Object)
	{
		if (Object is null)
		{
			throw("TS_UObject_MutationAndLifecycle_01 setup: required Object is null");
		}
		UClass Before = Object.GetClass();
		Object.SaveConfig();
		Object.SaveConfig();
		return Object.GetClass() == Before && IsValid(Object);
	}

	bool Observe_LoadConfig_Nominal(UObject Object)
	{
		if (Object is null)
		{
			throw("TS_UObject_MutationAndLifecycle_01 setup: required Object is null");
		}
		UClass Before = Object.GetClass();
		Object.LoadConfig();
		Object.LoadConfig();
		return Object.GetClass() == Before && IsValid(Object);
	}

	bool Observe_Append_Nominal(UObject Object)
	{
		if (Object is null)
		{
			throw("TS_UObject_MutationAndLifecycle_01 setup: required Object is null");
		}
		FString Text = "obj:";
		int32 Before = Text.Len();
		Text.Append(Object);
		int32 AfterFirst = Text.Len();
		Text.Append(Object);
		int32 AfterRepeat = Text.Len();
		FString NullText = "null:";
		UObject NullObject = nullptr;
		NullText.Append(NullObject);
		return AfterFirst > Before && AfterRepeat > AfterFirst && NullText.Len() > 5;
	}

	bool Observe_LoadObject_Nominal(UObject Object)
	{
		if (Object is null)
		{
			throw("TS_UObject_MutationAndLifecycle_01 setup: required Object is null");
		}
		UObject Outer = Object.GetOuter();
		FString PathName = Object.GetPathName();
		UObject Loaded = LoadObject(Outer, PathName);
		UObject Missing = LoadObject(Outer, "DefinitelyMissingObject");
		UObject Empty = LoadObject(Outer, "");
		return Loaded == Object && Missing is null && Empty is null;
	}
}
