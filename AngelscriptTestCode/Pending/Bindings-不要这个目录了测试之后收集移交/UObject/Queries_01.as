/**
 * @version v1
 * @summary Observe UObject root/flag, class, outer, package, and world queries.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe UObject root/flag, class, outer, package, and world queries.
 * @topic Baseline
 */
// Runner owns the Object fixture and teardown. A null Object is setup failure.
// AS-facing API: bool UObject.GetIsRooted() const;
// bool UObject.IsTransient() const; bool UObject.IsEditorOnly() const;
// bool UObject.IsSupportedForNetworking() const;
// UClass UObject.GetClass() const; UObject UObject.GetOuter() const;
// UObject UObject.GetTypedOuter(const TSubclassOf<UObject>& Target) const;
// UPackage UObject.GetOutermost() const; UPackage UObject.GetPackage() const;
// UWorld UObject.GetWorld() const;
// Inputs: Runner-supplied UObject, expected class/outer/package/world, and
// typed-outer parent/child.
// Expected observations: returned bool is the exact comparison.
// Boundary/ownership: Outer/package/class handles are borrowed.
// SetupOwner=Runner. CleanupOwner=Runner. FixtureIsolated.

namespace TS_UObject_Queries_01
{
	bool Observe_GetIsRooted_Nominal(UObject Object, bool bExpectRooted)
	{
		if (Object is null)
		{
			throw("TS_UObject_Queries_01 setup: required Object is null");
		}
		return Object.GetIsRooted() == bExpectRooted;
	}

	bool Observe_IsTransient_Nominal(UObject Object, bool bExpectTransient)
	{
		if (Object is null)
		{
			throw("TS_UObject_Queries_01 setup: required Object is null");
		}
		return Object.IsTransient() == bExpectTransient;
	}

	bool Observe_IsEditorOnly_Nominal(UObject Object, bool bExpectEditorOnly)
	{
		if (Object is null)
		{
			throw("TS_UObject_Queries_01 setup: required Object is null");
		}
		return Object.IsEditorOnly() == bExpectEditorOnly;
	}

	bool Observe_IsSupportedForNetworking_Nominal(UObject Object, bool bExpectSupported)
	{
		if (Object is null)
		{
			throw("TS_UObject_Queries_01 setup: required Object is null");
		}
		return Object.IsSupportedForNetworking() == bExpectSupported;
	}

	bool Observe_GetClass_Nominal(UObject Object, UClass Expected)
	{
		if (Object is null)
		{
			throw("TS_UObject_Queries_01 setup: required Object is null");
		}
		return Object.GetClass() == Expected;
	}

	bool Observe_GetOuter_Nominal(UObject Object, UObject Expected)
	{
		if (Object is null)
		{
			throw("TS_UObject_Queries_01 setup: required Object is null");
		}
		return Object.GetOuter() == Expected;
	}

	bool Observe_GetTypedOuter_Nominal(UObject Child, UObject Parent)
	{
		if (Child is null)
		{
			throw("TS_UObject_Queries_01 setup: required Child is null");
		}
		if (Parent is null)
		{
			throw("TS_UObject_Queries_01 setup: required Parent is null");
		}
		UObject TypedTexture = Child.GetTypedOuter(UTexture2D::StaticClass());
		UObject TypedPackage = Child.GetTypedOuter(UPackage::StaticClass());
		UObject Missing = Child.GetTypedOuter(AActor::StaticClass());
		return TypedTexture == Parent && TypedPackage != nullptr && Missing is null;
	}

	bool Observe_GetOutermost_Nominal(UObject Object, UPackage Expected)
	{
		if (Object is null)
		{
			throw("TS_UObject_Queries_01 setup: required Object is null");
		}
		if (Expected is null)
		{
			throw("TS_UObject_Queries_01 setup: required Expected package is null");
		}
		return Object.GetOutermost() == Expected;
	}

	bool Observe_GetPackage_Nominal(UObject Object, UPackage Expected)
	{
		if (Object is null)
		{
			throw("TS_UObject_Queries_01 setup: required Object is null");
		}
		if (Expected is null)
		{
			throw("TS_UObject_Queries_01 setup: required Expected package is null");
		}
		return Object.GetPackage() == Expected;
	}

	bool Observe_GetWorld_Nominal(UObject Object, UWorld Expected)
	{
		if (Object is null)
		{
			throw("TS_UObject_Queries_01 setup: required Object is null");
		}
		return Object.GetWorld() == Expected;
	}
}
/** @end */
