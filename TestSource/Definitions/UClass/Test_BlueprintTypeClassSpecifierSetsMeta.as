// Theme: Definitions.UClass. Positive: UCLASS(BlueprintType) publishes BlueprintType meta.
// C++: AngelscriptCompilerUClassSpecifierMatrixTests.cpp::BlueprintTypeClassSpecifierSetsMeta
// Oracle: Value default 0; write 0 stays 0; second instance independent. DefaultSafe.

UCLASS(BlueprintType)
class UBlueprintTypeTestObj : UObject
{
	UPROPERTY()
	int Value;
}

int Observe_BlueprintTypeClass_ValueDefault()
{
	UBlueprintTypeTestObj Obj = Cast<UBlueprintTypeTestObj>(NewObject(GetTransientPackage(), UBlueprintTypeTestObj::StaticClass()));
	if (Obj == nullptr)
	{
		throw("TS-DEF-0012 setup: NewObject failed");
	}
	return Obj.Value;
}

int Observe_BlueprintTypeClass_ZeroBoundary()
{
	UBlueprintTypeTestObj Obj = Cast<UBlueprintTypeTestObj>(NewObject(GetTransientPackage(), UBlueprintTypeTestObj::StaticClass()));
	if (Obj == nullptr)
	{
		throw("TS-DEF-0012 setup: NewObject failed");
	}
	Obj.Value = 0;
	return Obj.Value;
}

bool Observe_BlueprintTypeClass_CopyIndependence()
{
	UBlueprintTypeTestObj First = Cast<UBlueprintTypeTestObj>(NewObject(GetTransientPackage(), UBlueprintTypeTestObj::StaticClass()));
	UBlueprintTypeTestObj Second = Cast<UBlueprintTypeTestObj>(NewObject(GetTransientPackage(), UBlueprintTypeTestObj::StaticClass()));
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-DEF-0012 setup: NewObject failed");
	}
	First.Value = 7;
	return First.Value == 7 && Second.Value == 0;
}
