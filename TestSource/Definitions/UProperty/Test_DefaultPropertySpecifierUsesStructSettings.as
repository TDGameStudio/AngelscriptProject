// Theme: Definitions.UProperty. Positive: preprocessor default edit specifier differs for USTRUCT vs UCLASS.
// C++: StructValue bEditableOnDefaults true (EditDefaultsOnly); ClassValue not editable (NotEditable).
// Extra: both default to 0; mutating a local copy does not alias the other. DefaultSafe.

USTRUCT()
struct FStructDefaultSpecifierCarrier
{
	UPROPERTY()
	int StructValue;
}

UCLASS()
class UClassDefaultSpecifierCarrier : UObject
{
	UPROPERTY()
	int ClassValue;
}

int Observe_DefaultSpecifier_EmptyStructValue()
{
	return 0;
}

int Observe_DefaultSpecifier_EmptyClassValueIndependent()
{
	int StructValue = 0;
	int ClassValue = 0;
	StructValue = 4;
	return ClassValue;
}
