// Purpose: Observe UObject editor/config/script-copy behavior, the canonical
// null handle, NewObject, and internal asset-literal helpers.
// Runner owns mutation fixtures except NewObject / literal-asset helpers,
// which are the APIs under test.
// AS-facing API: bool UObject.Modify(bool bAlwaysMarkDirty = true);
// bool UObject.MarkPackageDirty() const;
// bool UObject.ImplementsInterface(const UClass InterfaceClass) const;
// void UObject.ReloadConfig();
// void UObject.CopyScriptPropertiesFrom(const UObject OtherObject);
// const UObject null;
// UObject NewObject(UObject Outer, const TSubclassOf<UObject>& Class, FName Name = NAME_None, bool bTransient = false);
// UObject __CreateLiteralAsset(UClass AssetClass, const FString& Name);
// void __PostLiteralAssetSetup(UObject Asset, const FString& Name);
// Inputs: Runner-owned UObject / carrier instances, default Modify omission vs
// false, UTexture2D and the script class, interface class UInterface,
// canonical null, NAME_None vs n"TSObjectNew", bTransient true/false, literal
// name "TSObjectLiteralAsset", and an empty TSubclassOf as the invalid-class
// diagnostic.
// Expected observations: returned bool is the exact comparison.
// Boundary/ownership: NewObject outer-owns the result. Empty Class throws.
// Literal helpers borrow AssetClass and copy Name. SetupOwner=Runner for
// mutation fixtures.

UCLASS()
class UTSObjectBehaviorCarrier : UObject
{
	UPROPERTY()
	int StoredValue = 7;
}

namespace TS_UObject_Behavior_01
{
	// UObject.Modify records a transaction snapshot; runner supplies the expected bools.
	bool Observe_Modify_Nominal(UObject Object, bool bExpectDefault, bool bExpectAlways, bool bExpectNotAlways)
	{
		if (Object is null)
		{
			throw("TS_UObject_Behavior_01 setup: required Object is null");
		}
		return Object.Modify() == bExpectDefault && Object.Modify(true) == bExpectAlways && Object.Modify(false) == bExpectNotAlways;
	}

	// MarkPackageDirty returns whether the package newly became dirty.
	bool Observe_MarkPackageDirty_Nominal(UObject Object, bool bExpectFirst, bool bExpectSecond)
	{
		if (Object is null)
		{
			throw("TS_UObject_Behavior_01 setup: required Object is null");
		}
		bool bFirst = Object.MarkPackageDirty();
		bool bSecond = Object.MarkPackageDirty();
		return bFirst == bExpectFirst && bSecond == bExpectSecond;
	}

	// ImplementsInterface is false for UInterface and UObject on a plain UObject.
	bool Observe_ImplementsInterface_Nominal(UObject Object)
	{
		if (Object is null)
		{
			throw("TS_UObject_Behavior_01 setup: required Object is null");
		}
		return !Object.ImplementsInterface(UInterface::StaticClass()) && !Object.ImplementsInterface(UObject::StaticClass());
	}

	// ReloadConfig returns after reload; class identity is unchanged.
	bool Observe_ReloadConfig_Nominal(UObject Object)
	{
		if (Object is null)
		{
			throw("TS_UObject_Behavior_01 setup: required Object is null");
		}
		UClass Before = Object.GetClass();
		Object.ReloadConfig();
		Object.ReloadConfig();
		return Object.GetClass() == Before && IsValid(Object);
	}

	// CopyScriptPropertiesFrom copies StoredValue from Source onto Target.
	bool Observe_CopyScriptPropertiesFrom_Nominal(UTSObjectBehaviorCarrier Source, UTSObjectBehaviorCarrier Target)
	{
		if (Source is null)
		{
			throw("TS_UObject_Behavior_01 setup: required Source is null");
		}
		if (Target is null)
		{
			throw("TS_UObject_Behavior_01 setup: required Target is null");
		}
		Source.StoredValue = 21;
		Target.StoredValue = 0;
		Target.CopyScriptPropertiesFrom(Source);
		return Target.StoredValue == 21 && Source.StoredValue == 21;
	}

	// Canonical null equals nullptr and fails IsValid.
	bool Observe_Surface047_Nominal()
	{
		UObject CanonicalNull = null;
		UObject ExplicitNull = nullptr;
		return CanonicalNull is null && CanonicalNull == ExplicitNull && !IsValid(null);
	}

	// NewObject returns a live object of the requested class and name.
	bool Observe_NewObject_Nominal()
	{
		UPackage Transient = GetTransientPackage();
		if (Transient is null)
		{
			throw("TS_UObject_Behavior_01 setup: required Transient package is null");
		}
		UObject Named = NewObject(Transient, UTexture2D::StaticClass(), n"TSObjectNew", true);
		UObject DefaultName = NewObject(Transient, UTexture2D::StaticClass());
		UObject NonTransient = NewObject(Transient, UTSObjectBehaviorCarrier::StaticClass(), n"TSObjectNewCarrier", false);
		UObject NullOuter = NewObject(nullptr, UTexture2D::StaticClass(), n"TSObjectNewNullOuter", true);
		return Named != nullptr && Named.GetName() == n"TSObjectNew" && Named.GetClass() == UTexture2D::StaticClass() && DefaultName != nullptr && NonTransient != nullptr && NullOuter != nullptr;
	}

	// __CreateLiteralAsset returns a live asset; repeating the same name reuses it.
	bool Observe___CreateLiteralAsset_Nominal()
	{
		UObject Asset = __CreateLiteralAsset(UTexture2D::StaticClass(), "TSObjectLiteralAsset");
		UObject Repeat = __CreateLiteralAsset(UTexture2D::StaticClass(), "TSObjectLiteralAsset");
		return Asset != nullptr && Repeat == Asset && Asset.GetClass() == UTexture2D::StaticClass();
	}

	// __PostLiteralAssetSetup returns after setup on a live literal asset.
	bool Observe___PostLiteralAssetSetup_Nominal()
	{
		UObject Asset = __CreateLiteralAsset(UTexture2D::StaticClass(), "TSObjectLiteralAssetSetup");
		if (Asset is null)
		{
			throw("TS_UObject_Behavior_01 setup: required literal Asset is null");
		}
		__PostLiteralAssetSetup(Asset, "TSObjectLiteralAssetSetup");
		__PostLiteralAssetSetup(Asset, "TSObjectLiteralAssetSetup");
		return Asset.GetClass() == UTexture2D::StaticClass() && IsValid(Asset);
	}

	void ExerciseExpectedFailure()
	{
		TSubclassOf<UObject> EmptyClass;
		UObject Created = NewObject(GetTransientPackage(), EmptyClass, n"TSObjectInvalidClass", true);
	}
}
