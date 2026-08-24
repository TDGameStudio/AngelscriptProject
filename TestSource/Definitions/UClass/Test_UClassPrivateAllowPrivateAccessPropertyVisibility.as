// Theme: Definitions.UClass. Positive AllowPrivateAccess vs hidden private UPROPERTY visibility.
// C++: AngelscriptCoverageUClassTests.cpp::UClassPrivateAllowPrivateAccessPropertyVisibility
// Oracle: AllowPrivateAccess Blueprint visible; hidden private not BlueprintVisible; ReadValues=37+41+43=121.
// Extra: unset handle is null; ReadValues default 121; copy independence of private fields via ReadValues. DefaultSafe.

UCLASS()
class UCoverageUClassPrivatePropertyVisibilityObject : UObject
{
	UPROPERTY(BlueprintReadWrite, meta=(AllowPrivateAccess))
	private int AllowedPrivateValue = 37;

	UPROPERTY(BlueprintReadWrite)
	private int HiddenPrivateValue = 41;

	UPROPERTY(BlueprintReadOnly, meta=(AllowPrivateAccess))
	private int ReadOnlyPrivateValue = 43;

	UFUNCTION(BlueprintCallable)
	int ReadValues()
	{
		return AllowedPrivateValue + HiddenPrivateValue + ReadOnlyPrivateValue;
	}
}

bool Observe_PrivateVisibility_EmptyDefaultIsNull()
{
	UCoverageUClassPrivatePropertyVisibilityObject Obj;
	return Obj == nullptr;
}

int Observe_PrivateVisibility_ReadValuesDefault(UCoverageUClassPrivatePropertyVisibilityObject Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-DEF-0149 setup: required UCoverageUClassPrivatePropertyVisibilityObject is null");
	}
	return Obj.ReadValues();
}

bool Observe_PrivateVisibility_CopyIndependence(UCoverageUClassPrivatePropertyVisibilityObject First, UCoverageUClassPrivatePropertyVisibilityObject Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-DEF-0149 setup: required UCoverageUClassPrivatePropertyVisibilityObject is null");
	}
	return First.ReadValues() == 121 && Second.ReadValues() == 121;
}
