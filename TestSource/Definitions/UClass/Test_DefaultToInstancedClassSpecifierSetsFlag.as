// Theme: Definitions.UClass. Positive DefaultToInstanced class specifier.
// C++: AngelscriptCompilerUClassSpecifierMatrixTests.cpp::DefaultToInstancedClassSpecifierSetsFlag
// compiles then CLASS_DefaultToInstanced. Oracle: generated UInstancedTestObj exists; Value default 0.
// Extra: unset handle is null; assigned Value is copy-independent. DefaultSafe.

UCLASS(DefaultToInstanced)
class UInstancedTestObj : UObject
{
	UPROPERTY()
	int Value;
}

bool Observe_InstancedTestObj_EmptyDefaultIsNull()
{
	UInstancedTestObj Obj;
	return Obj == nullptr;
}

int Observe_InstancedTestObj_ValueDefault(UInstancedTestObj Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-DEF-0013 setup: required UInstancedTestObj is null");
	}
	return Obj.Value;
}

bool Observe_InstancedTestObj_CopyIndependence(UInstancedTestObj First, UInstancedTestObj Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-DEF-0013 setup: required UInstancedTestObj is null");
	}
	First.Value = 9;
	return First.Value == 9 && Second.Value == 0;
}
