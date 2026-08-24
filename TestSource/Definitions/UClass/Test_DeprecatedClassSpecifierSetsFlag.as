// Theme: Definitions.UClass. Positive Deprecated class specifier.
// C++: AngelscriptCompilerUClassSpecifierMatrixTests.cpp::DeprecatedClassSpecifierSetsFlag
// compiles then CLASS_Deprecated. Oracle: generated UDeprecatedTestObj exists; Value default 0.
// Extra: unset handle is null; assigned Value is copy-independent. DefaultSafe.

UCLASS(Deprecated)
class UDeprecatedTestObj : UObject
{
	UPROPERTY()
	int Value;
}

bool Observe_DeprecatedTestObj_EmptyDefaultIsNull()
{
	UDeprecatedTestObj Obj;
	return Obj == nullptr;
}

int Observe_DeprecatedTestObj_ValueDefault(UDeprecatedTestObj Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-DEF-0014 setup: required UDeprecatedTestObj is null");
	}
	return Obj.Value;
}

bool Observe_DeprecatedTestObj_CopyIndependence(UDeprecatedTestObj First, UDeprecatedTestObj Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-DEF-0014 setup: required UDeprecatedTestObj is null");
	}
	First.Value = 9;
	return First.Value == 9 && Second.Value == 0;
}
