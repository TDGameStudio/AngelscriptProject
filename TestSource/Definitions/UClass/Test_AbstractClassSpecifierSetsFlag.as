// Theme: Definitions.UClass. Positive: UCLASS(Abstract) sets CLASS_Abstract.
// C++: AngelscriptCompilerUClassSpecifierMatrixTests.cpp::AbstractClassSpecifierSetsFlag
// Oracle: UAbstractTestObj is abstract; default handle is null. Extra: Value is an exposed UPROPERTY.
// DefaultSafe. Do not instantiate the abstract class.

UCLASS(Abstract)
class UAbstractTestObj : UObject
{
	UPROPERTY()
	int Value;
}

int Observe_AbstractClass_EmptyDefaultIsNull()
{
	UAbstractTestObj Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
