// Theme: Definitions.UClass. Positive HideCategories="Rendering" specifier.
// C++: AngelscriptCompilerUClassSpecifierMatrixTests.cpp::HideCategoriesClassSpecifierSetsMeta
// compiles then HideCategories metadata. Oracle: generated UHideCategoriesTestObj exists; Value default 0.
// Extra: unset handle is null; assigned Value is copy-independent. DefaultSafe.

UCLASS(HideCategories = "Rendering")
class UHideCategoriesTestObj : UObject
{
	UPROPERTY()
	int Value;
}

bool Observe_HideCategoriesTestObj_EmptyDefaultIsNull()
{
	UHideCategoriesTestObj Obj;
	return Obj == nullptr;
}

int Observe_HideCategoriesTestObj_ValueDefault(UHideCategoriesTestObj Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-DEF-0015 setup: required UHideCategoriesTestObj is null");
	}
	return Obj.Value;
}

bool Observe_HideCategoriesTestObj_CopyIndependence(UHideCategoriesTestObj First, UHideCategoriesTestObj Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-DEF-0015 setup: required UHideCategoriesTestObj is null");
	}
	First.Value = 9;
	return First.Value == 9 && Second.Value == 0;
}
