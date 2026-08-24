// Theme: Language.Preprocessor. Positive UCLASS: implicit UPROPERTY follows BlueprintReadOnly settings.
// C++: AngelscriptPreprocessorPropertyTests.cpp::DefaultBlueprintAccessUsesSettings
// sha256=2d5e421212debcc2a270ee1ba3431827286680e4f3ba5a095ddea5e32ec19d97; lines 177-184.
// Oracle: ImplicitAccess readable not writable; ExplicitAccess BlueprintReadWrite. Keep those UPROPERTY names.
// Extra: default ints are 0. DefaultSafe.

UCLASS()
class UBlueprintAccessDefaultSpecifierCarrier : UObject
{
	UPROPERTY() int ImplicitAccess;
	UPROPERTY(BlueprintReadWrite) int ExplicitAccess;
}

bool Observe_ImplicitAccess_DefaultEmpty()
{
	UBlueprintAccessDefaultSpecifierCarrier Carrier =
		Cast<UBlueprintAccessDefaultSpecifierCarrier>(
			NewObject(GetTransientPackage(), UBlueprintAccessDefaultSpecifierCarrier::StaticClass(), n"BlueprintAccessDefaultSpecifierCarrier"));
	if (Carrier == nullptr)
	{
		throw("TS-LANG-0351 setup: NewObject returned null");
	}
	return Carrier.ImplicitAccess == 0;
}

bool Observe_ExplicitAccess_DefaultEmpty()
{
	UBlueprintAccessDefaultSpecifierCarrier Carrier =
		Cast<UBlueprintAccessDefaultSpecifierCarrier>(
			NewObject(GetTransientPackage(), UBlueprintAccessDefaultSpecifierCarrier::StaticClass(), n"BlueprintAccessDefaultSpecifierCarrierExplicit"));
	if (Carrier == nullptr)
	{
		throw("TS-LANG-0351 setup: NewObject returned null");
	}
	return Carrier.ExplicitAccess == 0;
}

bool Observe_AccessFields_CopyIndependence()
{
	UBlueprintAccessDefaultSpecifierCarrier First =
		Cast<UBlueprintAccessDefaultSpecifierCarrier>(
			NewObject(GetTransientPackage(), UBlueprintAccessDefaultSpecifierCarrier::StaticClass(), n"BlueprintAccessDefaultSpecifierCarrierFirst"));
	UBlueprintAccessDefaultSpecifierCarrier Second =
		Cast<UBlueprintAccessDefaultSpecifierCarrier>(
			NewObject(GetTransientPackage(), UBlueprintAccessDefaultSpecifierCarrier::StaticClass(), n"BlueprintAccessDefaultSpecifierCarrierSecond"));
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-LANG-0351 setup: NewObject returned null");
	}
	First.ImplicitAccess = 7;
	First.ExplicitAccess = 9;
	return First.ImplicitAccess == 7 && First.ExplicitAccess == 9 && Second.ImplicitAccess == 0 && Second.ExplicitAccess == 0;
}
