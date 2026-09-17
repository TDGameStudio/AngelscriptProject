/**
 * @version v1
 * @summary UObject host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic UObject
 *
 * modify
 * mark-package-dirty
 * implements-interface
 * reload-config
 * copy-script-properties-from
 * canonical-null-equals-nullptr
 * new-object
 * create-literal-asset
 * post-literal-asset-setup
 * assignment
 * add-assign
 * to-string
 * add-to-root
 * remove-from-root
 * set-transactional
 * save-config
 * load-config
 * append
 * load-object
 * static-class
 * addition
 * get-is-rooted
 * is-transient
 * is-editor-only
 * is-supported-for-networking
 * get-class
 * get-outer
 * get-typed-outer
 * get-outermost
 * get-package
 * get-world
 * get-name
 * get-full-name
 * get-path-name
 * is-a
 * is-valid
 * get-default-object
 * get-source-file-path
 * get-script-module-name
 * get-script-type-declaration
 * is-function-implemented-in-script
 * find-function-by-name
 * is-child-of
 * is-abstract
 * get-super-class
 * find-class
 * get-all-classes
 * get-all-subclasses-of
 * UObject-Queries_03-get-source-file-path
 * get-source-line-number
 * get-script-function-declaration
 * get-angelscript-package
 * UObject-Queries_04-find-class
 * UObject-Queries_04-get-all-classes
 * find-object
 */
/**
 * @begin modify
 * @summary UObject.Modify records a transaction snapshot.
 * @topic Unreal
 */
/**
 * @function ObserveModifyNominal
 * @summary UObject.Modify records a transaction snapshot.
 * @covers UObject.modify
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveModifyNominal(UObject Object, bool bExpectDefault, bool bExpectAlways, bool bExpectNotAlways)
{
	if (Object is null)
	{
		throw("TS_UObject_Behavior_01 setup: required Object is null");
	}
	return Object.Modify() == bExpectDefault && Object.Modify(true) == bExpectAlways && Object.Modify(false) == bExpectNotAlways;
}
/** @end */
/**
 * @begin mark-package-dirty
 * @summary MarkPackageDirty returns whether the package newly became dirty.
 * @topic Unreal
 */
/**
 * @function ObserveMarkPackageDirtyNominal
 * @summary MarkPackageDirty returns whether the package newly became dirty.
 * @covers UObject.mark-package-dirty
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveMarkPackageDirtyNominal(UObject Object, bool bExpectFirst, bool bExpectSecond)
{
	if (Object is null)
	{
		throw("TS_UObject_Behavior_01 setup: required Object is null");
	}
	bool bFirst = Object.MarkPackageDirty();
	bool bSecond = Object.MarkPackageDirty();
	return bFirst == bExpectFirst && bSecond == bExpectSecond;
}
/** @end */
/**
 * @begin implements-interface
 * @summary ImplementsInterface is false for UInterface and UObject on a plain UObject.
 * @topic Unreal
 */
/**
 * @function ObserveImplementsInterfaceNominal
 * @summary ImplementsInterface is false for UInterface and UObject on a plain UObject.
 * @covers UObject.implements-interface
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveImplementsInterfaceNominal(UObject Object)
{
	if (Object is null)
	{
		throw("TS_UObject_Behavior_01 setup: required Object is null");
	}
	return !Object.ImplementsInterface(UInterface::StaticClass()) && !Object.ImplementsInterface(UObject::StaticClass());
}
/** @end */
/**
 * @begin reload-config
 * @summary ReloadConfig returns after reload.
 * @topic Unreal
 */
/**
 * @function ObserveReloadConfigNominal
 * @summary ReloadConfig returns after reload.
 * @covers UObject.reload-config
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveReloadConfigNominal(UObject Object)
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
/** @end */
/**
 * @begin copy-script-properties-from
 * @summary CopyScriptPropertiesFrom copies StoredValue from Source onto Target.
 * @topic Unreal
 */
/**
 * @function ObserveCopyScriptPropertiesFromNominal
 * @summary CopyScriptPropertiesFrom copies StoredValue from Source onto Target.
 * @covers UObject.copy-script-properties-from
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveCopyScriptPropertiesFromNominal(UTSObjectBehaviorCarrier Source, UTSObjectBehaviorCarrier Target)
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
/** @end */
/**
 * @begin canonical-null-equals-nullptr
 * @summary Canonical null equals nullptr and fails IsValid.
 * @topic Unreal
 */
/**
 * @function ObserveSurface047Nominal
 * @summary Canonical null equals nullptr and fails IsValid.
 * @covers UObject.canonical-null-equals-nullptr
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface047Nominal()
{
	UObject CanonicalNull = null;
	UObject ExplicitNull = nullptr;
	return CanonicalNull is null && CanonicalNull == ExplicitNull && !IsValid(null);
}
/** @end */
/**
 * @begin new-object
 * @summary NewObject returns a live object of the requested class and name.
 * @topic Unreal
 */
/**
 * @function ObserveNewObjectNominal
 * @summary NewObject returns a live object of the requested class and name.
 * @covers UObject.new-object
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveNewObjectNominal()
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
/** @end */
/**
 * @begin create-literal-asset
 * @summary __CreateLiteralAsset returns a live asset.
 * @topic Unreal
 */
/**
 * @function ObserveCreateLiteralAssetNominal
 * @summary __CreateLiteralAsset returns a live asset.
 * @covers UObject.create-literal-asset
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveCreateLiteralAssetNominal()
{
	UObject Asset = __CreateLiteralAsset(UTexture2D::StaticClass(), "TSObjectLiteralAsset");
	UObject Repeat = __CreateLiteralAsset(UTexture2D::StaticClass(), "TSObjectLiteralAsset");
	return Asset != nullptr && Repeat == Asset && Asset.GetClass() == UTexture2D::StaticClass();
}
/** @end */
/**
 * @begin post-literal-asset-setup
 * @summary __PostLiteralAssetSetup returns after setup on a live literal asset.
 * @topic Unreal
 */
/**
 * @function ObservePostLiteralAssetSetupNominal
 * @summary __PostLiteralAssetSetup returns after setup on a live literal asset.
 * @covers UObject.post-literal-asset-setup
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObservePostLiteralAssetSetupNominal()
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
/** @end */
/**
 * @begin assignment
 * @summary representation into the existing FString.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary representation into the existing FString.
 * @covers UObject.assignment
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal(UObject Object)
{
	if (Object is null)
	{
		throw("TS_UObject_ConstructionAndAssignment_01 setup: required Object is null");
	}
	UTexture2D Texture = Cast<UTexture2D>(Object);
	UClass AsClass = Cast<UClass>(Object);
	UTexture2D FromNull = Cast<UTexture2D>(nullptr);
	UObject NullObject = nullptr;
	UTexture2D FromNullObject = Cast<UTexture2D>(NullObject);
	return Texture != nullptr && Texture == Object && AsClass is null && FromNull is null && FromNullObject is null;
}
/** @end */
/**
 * @begin add-assign
 * @summary representation into the existing FString.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary representation into the existing FString.
 * @covers UObject.add-assign
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal(UObject Object)
{
	if (Object is null)
	{
		throw("TS_UObject_ConstructionAndAssignment_01 setup: required Object is null");
	}
	FString Text = "obj:";
	int32 Before = Text.Len();
	Text += Object;
	int32 AfterFirst = Text.Len();
	Text += Object;
	int32 AfterRepeat = Text.Len();
	FString NullText = "null:";
	UObject NullObject = nullptr;
	NullText += NullObject;
	return AfterFirst > Before && AfterRepeat > AfterFirst && NullText.Len() > 5;
}
/** @end */
/**
 * @begin to-string
 * @summary UObject.
 * @topic Unreal
 */
/**
 * @function ObserveToStringNominal
 * @summary UObject.
 * @covers UObject.to-string
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToStringNominal(UObject Object, const FString& ExpectedName)
{
	if (Object is null)
	{
		throw("TS_UObject_ConversionAndFormatting_01 setup: required Object is null");
	}
	FString Text = Object.ToString();
	FString Repeated = Object.ToString();
	return Text.Len() > 0 && Text.Contains(ExpectedName) && Repeated == Text;
}
/** @end */
/**
 * @begin add-to-root
 * @summary Text.Append(Object);
 * @topic Unreal
 */
/**
 * @function ObserveAddToRootNominal
 * @summary Text.Append(Object);
 * @covers UObject.add-to-root
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// Text.Append(Object);

 UObject LoadObject(UObject Outer, const FString& Name);
// Inputs: Runner-owned UObject, prefix "obj:", LoadObject of that object's
// path, a missing path, and empty name.
// Expected observations: AddToRoot makes GetIsRooted true; RemoveFromRoot
// restores false. SaveConfig/LoadConfig leave the object valid. Append grows
// the string. LoadObject of the live path returns that object; missing names
// return null.
// Boundary/ownership: Rooting keeps the object alive for GC. LoadObject uses
// Outer as resolution context. SetupOwner=Runner.
bool ObserveAddToRootNominal(UObject Object)
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
/** @end */
/**
 * @begin remove-from-root
 * @summary Outer as resolution context.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveFromRootNominal
 * @summary Outer as resolution context.
 * @covers UObject.remove-from-root
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// Text.Append(Object);

bool ObserveRemoveFromRootNominal(UObject Object)
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
/** @end */
/**
 * @begin set-transactional
 * @summary Outer as resolution context.
 * @topic Unreal
 */
/**
 * @function ObserveSetTransactionalNominal
 * @summary Outer as resolution context.
 * @covers UObject.set-transactional
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// Text.Append(Object);

bool ObserveSetTransactionalNominal(UObject Object)
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
/** @end */
/**
 * @begin save-config
 * @summary Outer as resolution context.
 * @topic Unreal
 */
/**
 * @function ObserveSaveConfigNominal
 * @summary Outer as resolution context.
 * @covers UObject.save-config
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// Text.Append(Object);

bool ObserveSaveConfigNominal(UObject Object)
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
/** @end */
/**
 * @begin load-config
 * @summary Outer as resolution context.
 * @topic Unreal
 */
/**
 * @function ObserveLoadConfigNominal
 * @summary Outer as resolution context.
 * @covers UObject.load-config
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// Text.Append(Object);

bool ObserveLoadConfigNominal(UObject Object)
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
/** @end */
/**
 * @begin append
 * @summary Outer as resolution context.
 * @topic Unreal
 */
/**
 * @function ObserveAppendNominal
 * @summary Outer as resolution context.
 * @covers UObject.append
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// Text.Append(Object);

bool ObserveAppendNominal(UObject Object)
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
/** @end */
/**
 * @begin load-object
 * @summary Outer as resolution context.
 * @topic Unreal
 */
/**
 * @function ObserveLoadObjectNominal
 * @summary Outer as resolution context.
 * @covers UObject.load-object
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// Text.Append(Object);

bool ObserveLoadObjectNominal(UObject Object)
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
/** @end */
/**
 * @begin static-class
 * @summary DefaultSafe.
 * @topic Unreal
 */
/**
 * @function ObserveStaticClassNominal
 * @summary DefaultSafe.
 * @covers UObject.static-class
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveStaticClassNominal()
{
	UClass ObjectClass = UClass::__StaticClass("UObject");
	UClass TextureClass = UClass::__StaticClass("Texture2D");
	UClass ScriptClass = UClass::__StaticClass("UTSObjectStaticClassCarrier");
	UClass Missing = UClass::__StaticClass("DefinitelyMissingClass");
	UClass Empty = UClass::__StaticClass("");
	return ObjectClass == UObject::StaticClass() && TextureClass == UTexture2D::StaticClass() && ScriptClass == UTSObjectStaticClassCarrier::StaticClass() && Missing is null && Empty is null;
}
/** @end */
/**
 * @begin addition
 * @summary or take ownership of it.
 * @topic Unreal
 */
/**
 * @function ObserveAdditionNominal
 * @summary or take ownership of it.
 * @covers UObject.addition
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAdditionNominal(UObject Object)
{
	if (Object is null)
	{
		throw("TS_UObject_Operators_01 setup: required Object is null");
	}
	FString Prefix = "obj:";
	FString Combined = Prefix + Object;
	FString FromEmpty = "" + Object;
	UObject NullObject = nullptr;
	FString WithNull = Prefix + NullObject;
	return Prefix == "obj:" && Combined.Len() > Prefix.Len() && FromEmpty.Len() > 0 && WithNull.Len() > Prefix.Len();
}
/** @end */
/**
 * @begin get-is-rooted
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveGetIsRootedNominal
 * @summary SetupOwner=Runner.
 * @covers UObject.get-is-rooted
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetIsRootedNominal(UObject Object, bool bExpectRooted)
{
	if (Object is null)
	{
		throw("TS_UObject_Queries_01 setup: required Object is null");
	}
	return Object.GetIsRooted() == bExpectRooted;
}
/** @end */
/**
 * @begin is-transient
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveIsTransientNominal
 * @summary SetupOwner=Runner.
 * @covers UObject.is-transient
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsTransientNominal(UObject Object, bool bExpectTransient)
{
	if (Object is null)
	{
		throw("TS_UObject_Queries_01 setup: required Object is null");
	}
	return Object.IsTransient() == bExpectTransient;
}
/** @end */
/**
 * @begin is-editor-only
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveIsEditorOnlyNominal
 * @summary SetupOwner=Runner.
 * @covers UObject.is-editor-only
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsEditorOnlyNominal(UObject Object, bool bExpectEditorOnly)
{
	if (Object is null)
	{
		throw("TS_UObject_Queries_01 setup: required Object is null");
	}
	return Object.IsEditorOnly() == bExpectEditorOnly;
}
/** @end */
/**
 * @begin is-supported-for-networking
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveIsSupportedForNetworkingNominal
 * @summary SetupOwner=Runner.
 * @covers UObject.is-supported-for-networking
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsSupportedForNetworkingNominal(UObject Object, bool bExpectSupported)
{
	if (Object is null)
	{
		throw("TS_UObject_Queries_01 setup: required Object is null");
	}
	return Object.IsSupportedForNetworking() == bExpectSupported;
}
/** @end */
/**
 * @begin get-class
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveGetClassNominal
 * @summary SetupOwner=Runner.
 * @covers UObject.get-class
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetClassNominal(UObject Object, UClass Expected)
{
	if (Object is null)
	{
		throw("TS_UObject_Queries_01 setup: required Object is null");
	}
	return Object.GetClass() == Expected;
}
/** @end */
/**
 * @begin get-outer
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveGetOuterNominal
 * @summary SetupOwner=Runner.
 * @covers UObject.get-outer
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetOuterNominal(UObject Object, UObject Expected)
{
	if (Object is null)
	{
		throw("TS_UObject_Queries_01 setup: required Object is null");
	}
	return Object.GetOuter() == Expected;
}
/** @end */
/**
 * @begin get-typed-outer
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveGetTypedOuterNominal
 * @summary SetupOwner=Runner.
 * @covers UObject.get-typed-outer
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTypedOuterNominal(UObject Child, UObject Parent)
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
/** @end */
/**
 * @begin get-outermost
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveGetOutermostNominal
 * @summary SetupOwner=Runner.
 * @covers UObject.get-outermost
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetOutermostNominal(UObject Object, UPackage Expected)
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
/** @end */
/**
 * @begin get-package
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveGetPackageNominal
 * @summary SetupOwner=Runner.
 * @covers UObject.get-package
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetPackageNominal(UObject Object, UPackage Expected)
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
/** @end */
/**
 * @begin get-world
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveGetWorldNominal
 * @summary SetupOwner=Runner.
 * @covers UObject.get-world
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetWorldNominal(UObject Object, UWorld Expected)
{
	if (Object is null)
	{
		throw("TS_UObject_Queries_01 setup: required Object is null");
	}
	return Object.GetWorld() == Expected;
}
/** @end */
/**
 * @begin get-name
 * @summary UClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetNameNominal
 * @summary UClass is the invalid-class diagnostic path.
 * @covers UObject.get-name
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// bool UObject.IsA(const UClass Class) const;

bool ObserveGetNameNominal(UObject Object, const FName& Expected)
{
	if (Object is null)
	{
		throw("TS_UObject_Queries_02 setup: required Object is null");
	}
	return Object.GetName() == Expected;
}
/** @end */
/**
 * @begin get-full-name
 * @summary UClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetFullNameNominal
 * @summary UClass is the invalid-class diagnostic path.
 * @covers UObject.get-full-name
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// bool UObject.IsA(const UClass Class) const;

bool ObserveGetFullNameNominal(UObject Object, UObject StopOuter, const FString& ExpectedName)
{
	if (Object is null)
	{
		throw("TS_UObject_Queries_02 setup: required Object is null");
	}
	FString Full = Object.GetFullName();
	FString Stopped = Object.GetFullName(StopOuter);
	FString WithNullStop = Object.GetFullName(nullptr);
	return Full.Contains(ExpectedName) && Stopped.Len() > 0 && WithNullStop.Len() > 0;
}
/** @end */
/**
 * @begin get-path-name
 * @summary UClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetPathNameNominal
 * @summary UClass is the invalid-class diagnostic path.
 * @covers UObject.get-path-name
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// bool UObject.IsA(const UClass Class) const;

bool ObserveGetPathNameNominal(UObject Object, UObject StopOuter, const FString& ExpectedName)
{
	if (Object is null)
	{
		throw("TS_UObject_Queries_02 setup: required Object is null");
	}
	FString Path = Object.GetPathName();
	FString Stopped = Object.GetPathName(StopOuter);
	FString WithNullStop = Object.GetPathName(nullptr);
	return Path.Contains(ExpectedName) && Stopped.Len() > 0 && WithNullStop.Len() > 0;
}
/** @end */
/**
 * @begin is-a
 * @summary UClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveIsANominal
 * @summary UClass is the invalid-class diagnostic path.
 * @covers UObject.is-a
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// bool UObject.IsA(const UClass Class) const;

bool ObserveIsANominal(UObject Object, UClass Matching, UClass NonMatching)
{
	if (Object is null)
	{
		throw("TS_UObject_Queries_02 setup: required Object is null");
	}
	if (Matching is null)
	{
		throw("TS_UObject_Queries_02 setup: required Matching class is null");
	}
	if (NonMatching is null)
	{
		throw("TS_UObject_Queries_02 setup: required NonMatching class is null");
	}
	return Object.IsA(Matching) && Object.IsA(UObject::StaticClass()) && !Object.IsA(NonMatching);
}
/** @end */
/**
 * @begin is-valid
 * @summary UClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveIsValidNominal
 * @summary UClass is the invalid-class diagnostic path.
 * @covers UObject.is-valid
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// bool UObject.IsA(const UClass Class) const;

bool ObserveIsValidNominal(UObject Object)
{
	if (Object is null)
	{
		throw("TS_UObject_Queries_02 setup: required Object is null");
	}
	UObject NullObject = nullptr;
	return IsValid(Object) && !IsValid(NullObject) && !IsValid(null);
}
/** @end */
/**
 * @begin get-default-object
 * @summary UClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetDefaultObjectNominal
 * @summary UClass is the invalid-class diagnostic path.
 * @covers UObject.get-default-object
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// bool UObject.IsA(const UClass Class) const;

bool ObserveGetDefaultObjectNominal(UClass Class)
{
	if (Class is null)
	{
		throw("TS_UObject_Queries_02 setup: required Class is null");
	}
	UObject Cdo = Class.GetDefaultObject();
	UClass ScriptClass = UTSObjectQueries02Carrier::StaticClass();
	if (ScriptClass is null)
	{
		throw("TS_UObject_Queries_02 setup: required ScriptClass is null");
	}
	UObject ScriptCdo = ScriptClass.GetDefaultObject();
	return Cdo != nullptr && Cdo.IsA(Class) && ScriptCdo != nullptr;
}
/** @end */
/**
 * @begin get-source-file-path
 * @summary UClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetSourceFilePathNominal
 * @summary UClass is the invalid-class diagnostic path.
 * @covers UObject.get-source-file-path
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// bool UObject.IsA(const UClass Class) const;

bool ObserveGetSourceFilePathNominal()
{
	UClass NativeClass = UTexture2D::StaticClass();
	if (NativeClass is null)
	{
		throw("TS_UObject_Queries_02 setup: required NativeClass is null");
	}
	FString NativePath = NativeClass.GetSourceFilePath();
	UClass ScriptClass = UTSObjectQueries02Carrier::StaticClass();
	if (ScriptClass is null)
	{
		throw("TS_UObject_Queries_02 setup: required ScriptClass is null");
	}
	FString ScriptPath = ScriptClass.GetSourceFilePath();
	return NativePath.Len() == 0 && ScriptPath.Len() > 0;
}
/** @end */
/**
 * @begin get-script-module-name
 * @summary UClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetScriptModuleNameNominal
 * @summary UClass is the invalid-class diagnostic path.
 * @covers UObject.get-script-module-name
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// bool UObject.IsA(const UClass Class) const;

bool ObserveGetScriptModuleNameNominal()
{
	UClass NativeClass = UTexture2D::StaticClass();
	if (NativeClass is null)
	{
		throw("TS_UObject_Queries_02 setup: required NativeClass is null");
	}
	FString NativeModule = NativeClass.GetScriptModuleName();
	UClass ScriptClass = UTSObjectQueries02Carrier::StaticClass();
	if (ScriptClass is null)
	{
		throw("TS_UObject_Queries_02 setup: required ScriptClass is null");
	}
	FString ScriptModule = ScriptClass.GetScriptModuleName();
	return NativeModule.Len() == 0 && ScriptModule.Len() > 0;
}
/** @end */
/**
 * @begin get-script-type-declaration
 * @summary UClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetScriptTypeDeclarationNominal
 * @summary UClass is the invalid-class diagnostic path.
 * @covers UObject.get-script-type-declaration
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// bool UObject.IsA(const UClass Class) const;

bool ObserveGetScriptTypeDeclarationNominal()
{
	UClass NativeClass = UTexture2D::StaticClass();
	if (NativeClass is null)
	{
		throw("TS_UObject_Queries_02 setup: required NativeClass is null");
	}
	FString NativeDecl = NativeClass.GetScriptTypeDeclaration();
	UClass ScriptClass = UTSObjectQueries02Carrier::StaticClass();
	if (ScriptClass is null)
	{
		throw("TS_UObject_Queries_02 setup: required ScriptClass is null");
	}
	FString ScriptDecl = ScriptClass.GetScriptTypeDeclaration();
	return NativeDecl.Len() == 0 && ScriptDecl.Len() > 0 && ScriptDecl.Contains("UTSObjectQueries02Carrier");
}
/** @end */
/**
 * @begin is-function-implemented-in-script
 * @summary UClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveIsFunctionImplementedInScriptNominal
 * @summary UClass is the invalid-class diagnostic path.
 * @covers UObject.is-function-implemented-in-script
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// bool UObject.IsA(const UClass Class) const;

bool ObserveIsFunctionImplementedInScriptNominal()
{
	UClass NativeClass = UTexture2D::StaticClass();
	if (NativeClass is null)
	{
		throw("TS_UObject_Queries_02 setup: required NativeClass is null");
	}
	bool bNativeImplemented = NativeClass.IsFunctionImplementedInScript(n"ReadStoredValue");
	UClass ScriptClass = UTSObjectQueries02Carrier::StaticClass();
	if (ScriptClass is null)
	{
		throw("TS_UObject_Queries_02 setup: required ScriptClass is null");
	}
	bool bScriptImplemented = ScriptClass.IsFunctionImplementedInScript(n"ReadStoredValue");
	bool bMissingImplemented = ScriptClass.IsFunctionImplementedInScript(n"MissingFunction");
	bool bNoneImplemented = ScriptClass.IsFunctionImplementedInScript(NAME_None);
	return !bNativeImplemented && bScriptImplemented && !bMissingImplemented && !bNoneImplemented;
}
/** @end */
/**
 * @begin find-function-by-name
 * @summary UClass handles.
 * @topic Unreal
 */
/**
 * @function ObserveFindFunctionByNameNominal
 * @summary UClass handles.
 * @covers UObject.find-function-by-name
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSObjectQueries03Carrier : UObject
{

bool ObserveFindFunctionByNameNominal()
{
	UClass ScriptClass = UTSObjectQueries03Carrier::StaticClass();
	if (ScriptClass is null)
	{
		throw("TS_UObject_Queries_03 setup: required ScriptClass is null");
	}
	UFunction Found = ScriptClass.FindFunctionByName(n"ReadStoredValue");
	UFunction Missing = ScriptClass.FindFunctionByName(n"MissingFunction");
	UFunction NoneFunction = ScriptClass.FindFunctionByName(NAME_None);
	return Found != nullptr && Missing is null && NoneFunction is null;
}
/** @end */
/**
 * @begin is-child-of
 * @summary UClass handles.
 * @topic Unreal
 */
/**
 * @function ObserveIsChildOfNominal
 * @summary UClass handles.
 * @covers UObject.is-child-of
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSObjectQueries03Carrier : UObject
{

bool ObserveIsChildOfNominal()
{
	UClass PawnClass = APawn::StaticClass();
	UClass ActorClass = AActor::StaticClass();
	UClass ObjectClass = UObject::StaticClass();
	UClass TextureClass = UTexture2D::StaticClass();
	if (PawnClass is null)
	{
		throw("TS_UObject_Queries_03 setup: required PawnClass is null");
	}
	if (ActorClass is null)
	{
		throw("TS_UObject_Queries_03 setup: required ActorClass is null");
	}
	if (ObjectClass is null)
	{
		throw("TS_UObject_Queries_03 setup: required ObjectClass is null");
	}
	if (TextureClass is null)
	{
		throw("TS_UObject_Queries_03 setup: required TextureClass is null");
	}
	return PawnClass.IsChildOf(ActorClass) && PawnClass.IsChildOf(PawnClass) && PawnClass.IsChildOf(ObjectClass) && !PawnClass.IsChildOf(TextureClass);
}
/** @end */
/**
 * @begin is-abstract
 * @summary UClass handles.
 * @topic Unreal
 */
/**
 * @function ObserveIsAbstractNominal
 * @summary UClass handles.
 * @covers UObject.is-abstract
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSObjectQueries03Carrier : UObject
{

bool ObserveIsAbstractNominal(UClass Class, bool bExpectAbstract)
{
	if (Class is null)
	{
		throw("TS_UObject_Queries_03 setup: required Class is null");
	}
	UClass TextureClass = UTexture2D::StaticClass();
	UClass ScriptClass = UTSObjectQueries03Carrier::StaticClass();
	if (TextureClass is null)
	{
		throw("TS_UObject_Queries_03 setup: required TextureClass is null");
	}
	if (ScriptClass is null)
	{
		throw("TS_UObject_Queries_03 setup: required ScriptClass is null");
	}
	return Class.IsAbstract() == bExpectAbstract && !TextureClass.IsAbstract() && !ScriptClass.IsAbstract();
}
/** @end */
/**
 * @begin get-super-class
 * @summary UClass handles.
 * @topic Unreal
 */
/**
 * @function ObserveGetSuperClassNominal
 * @summary UClass handles.
 * @covers UObject.get-super-class
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSObjectQueries03Carrier : UObject
{

bool ObserveGetSuperClassNominal()
{
	UClass ScriptClass = UTSObjectQueries03Carrier::StaticClass();
	if (ScriptClass is null)
	{
		throw("TS_UObject_Queries_03 setup: required ScriptClass is null");
	}
	UClass ScriptSuper = ScriptClass.GetSuperClass();
	UClass PawnClass = APawn::StaticClass();
	if (PawnClass is null)
	{
		throw("TS_UObject_Queries_03 setup: required PawnClass is null");
	}
	UClass PawnSuper = PawnClass.GetSuperClass();
	UClass ObjectClass = UObject::StaticClass();
	if (ObjectClass is null)
	{
		throw("TS_UObject_Queries_03 setup: required ObjectClass is null");
	}
	UClass ObjectSuper = ObjectClass.GetSuperClass();
	return ScriptSuper == UObject::StaticClass() && PawnSuper != nullptr && ObjectSuper is null;
}
/** @end */
/**
 * @begin find-class
 * @summary UClass handles.
 * @topic Unreal
 */
/**
 * @function ObserveFindClassNominal
 * @summary UClass handles.
 * @covers UObject.find-class
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSObjectQueries03Carrier : UObject
{

bool ObserveFindClassNominal()
{
	UClass ActorClass = UClass::FindClass("Actor");
	UClass TextureClass = UClass::FindClass("Texture2D");
	UClass Missing = UClass::FindClass("DefinitelyMissingClass");
	UClass Empty = UClass::FindClass("");
	return ActorClass != nullptr && TextureClass != nullptr && Missing is null && Empty is null;
}
/** @end */
/**
 * @begin get-all-classes
 * @summary UClass handles.
 * @topic Unreal
 */
/**
 * @function ObserveGetAllClassesNominal
 * @summary UClass handles.
 * @covers UObject.get-all-classes
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSObjectQueries03Carrier : UObject
{

bool ObserveGetAllClassesNominal()
{
	TArray<UClass> OutClasses;
	int32 Before = OutClasses.Num();
	UClass::GetAllClasses(OutClasses);
	int32 After = OutClasses.Num();
	bool bContainsObject = false;
	for (int32 Index = 0; Index < OutClasses.Num(); ++Index)
	{
		if (OutClasses[Index] == UObject::StaticClass())
		{
			bContainsObject = true;
			break;
		}
	}
	return Before == 0 && After > 0 && bContainsObject;
}
/** @end */
/**
 * @begin get-all-subclasses-of
 * @summary UClass handles.
 * @topic Unreal
 */
/**
 * @function ObserveGetAllSubclassesOfNominal
 * @summary UClass handles.
 * @covers UObject.get-all-subclasses-of
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSObjectQueries03Carrier : UObject
{

bool ObserveGetAllSubclassesOfNominal()
{
	UClass ActorClass = AActor::StaticClass();
	if (ActorClass is null)
	{
		throw("TS_UObject_Queries_03 setup: required ActorClass is null");
	}
	TArray<UClass> Concrete = UClass::GetAllSubclassesOf(ActorClass);
	TArray<UClass> WithAbstract = UClass::GetAllSubclassesOf(ActorClass, true);
	TArray<UClass> WithoutAbstract = UClass::GetAllSubclassesOf(ActorClass, false);
	return Concrete.Num() > 0 && WithAbstract.Num() >= WithoutAbstract.Num();
}
/** @end */
/**
 * @begin UObject-Queries_03-get-source-file-path
 * @summary UClass handles.
 * @topic Unreal
 */
/**
 * @function ObserveGetSourceFilePathNominal
 * @summary UClass handles.
 * @covers UObject.get-source-file-path
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSObjectQueries03Carrier : UObject
{

bool ObserveGetSourceFilePathNominal()
{
	UClass ScriptClass = UTSObjectQueries03Carrier::StaticClass();
	if (ScriptClass is null)
	{
		throw("TS_UObject_Queries_03 setup: required ScriptClass is null");
	}
	UFunction ScriptFunction = ScriptClass.FindFunctionByName(n"ReadStoredValue");
	if (ScriptFunction is null)
	{
		throw("TS_UObject_Queries_03 setup: required ScriptFunction is null");
	}
	FString ScriptPath = ScriptFunction.GetSourceFilePath();
	return ScriptPath.Len() > 0;
}
/** @end */
/**
 * @begin get-source-line-number
 * @summary UClass handles.
 * @topic Unreal
 */
/**
 * @function ObserveGetSourceLineNumberNominal
 * @summary UClass handles.
 * @covers UObject.get-source-line-number
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSObjectQueries03Carrier : UObject
{

bool ObserveGetSourceLineNumberNominal()
{
	UClass ScriptClass = UTSObjectQueries03Carrier::StaticClass();
	if (ScriptClass is null)
	{
		throw("TS_UObject_Queries_03 setup: required ScriptClass is null");
	}
	UFunction ScriptFunction = ScriptClass.FindFunctionByName(n"ReadStoredValue");
	if (ScriptFunction is null)
	{
		throw("TS_UObject_Queries_03 setup: required ScriptFunction is null");
	}
	int ScriptLine = ScriptFunction.GetSourceLineNumber();
	return ScriptLine > 0;
}
/** @end */
/**
 * @begin get-script-function-declaration
 * @summary UClass handles.
 * @topic Unreal
 */
/**
 * @function ObserveGetScriptFunctionDeclarationNominal
 * @summary UClass handles.
 * @covers UObject.get-script-function-declaration
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSObjectQueries03Carrier : UObject
{

bool ObserveGetScriptFunctionDeclarationNominal()
{
	UClass ScriptClass = UTSObjectQueries03Carrier::StaticClass();
	if (ScriptClass is null)
	{
		throw("TS_UObject_Queries_03 setup: required ScriptClass is null");
	}
	UFunction ScriptFunction = ScriptClass.FindFunctionByName(n"ReadStoredValue");
	if (ScriptFunction is null)
	{
		throw("TS_UObject_Queries_03 setup: required ScriptFunction is null");
	}
	FString ScriptDecl = ScriptFunction.GetScriptFunctionDeclaration();
	return ScriptDecl.Len() > 0 && ScriptDecl.Contains("ReadStoredValue");
}
/** @end */
/**
 * @begin get-angelscript-package
 * @summary handles.
 * @topic Unreal
 */
/**
 * @function ObserveGetAngelscriptPackageNominal
 * @summary handles.
 * @covers UObject.get-angelscript-package
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveGetAngelscriptPackageNominal()
{
	UPackage ScriptPackage = GetAngelscriptPackage();
	return ScriptPackage != nullptr && ScriptPackage != GetTransientPackage();
}
/** @end */
/**
 * @begin UObject-Queries_04-find-class
 * @summary handles.
 * @topic Unreal
 */
/**
 * @function ObserveFindClassNominal
 * @summary handles.
 * @covers UObject.find-class
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveFindClassNominal()
{
	UClass TextureClass = FindClass("Texture2D");
	UClass ObjectClass = FindClass("UObject");
	UClass Missing = FindClass("DefinitelyMissingClass");
	UClass Empty = FindClass("");
	return TextureClass == UTexture2D::StaticClass() && ObjectClass == UObject::StaticClass() && Missing is null && Empty is null;
}
/** @end */
/**
 * @begin UObject-Queries_04-get-all-classes
 * @summary handles.
 * @topic Unreal
 */
/**
 * @function ObserveGetAllClassesNominal
 * @summary handles.
 * @covers UObject.get-all-classes
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveGetAllClassesNominal()
{
	TArray<UClass> OutClasses;
	int32 Before = OutClasses.Num();
	GetAllClasses(OutClasses);
	int32 After = OutClasses.Num();
	bool bContainsTexture = false;
	for (int32 Index = 0; Index < OutClasses.Num(); ++Index)
	{
		if (OutClasses[Index] == UTexture2D::StaticClass())
		{
			bContainsTexture = true;
			break;
		}
	}
	return Before == 0 && After > 0 && bContainsTexture;
}
/** @end */
/**
 * @begin find-object
 * @summary handles.
 * @topic Unreal
 */
/**
 * @function ObserveFindObjectNominal
 * @summary handles.
 * @covers UObject.find-object
 * @inputs UObject values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveFindObjectNominal(UObject Object)
{
	if (Object is null)
	{
		throw("TS_UObject_Queries_04 setup: required Object is null");
	}
	UObject Outer = Object.GetOuter();
	FString PathName = Object.GetPathName();
	FString ShortName = Object.GetName().GetPlainNameString();
	UObject ByPath = FindObject(PathName);
	UObject ByOuterAndName = FindObject(Outer, ShortName);
	UObject Missing = FindObject("DefinitelyMissingObject");
	UObject MissingInOuter = FindObject(Outer, "DefinitelyMissingObject");
	UObject Empty = FindObject("");
	return ByPath == Object && ByOuterAndName == Object && Missing is null && MissingInOuter is null && Empty is null;
}
/** @end */
