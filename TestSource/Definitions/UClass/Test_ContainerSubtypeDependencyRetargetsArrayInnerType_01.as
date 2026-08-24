// Theme: Definitions.UClass. Reload version pair 01 (initial). Positive TArray inner-type dependency.
// C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::ContainerSubtypeDependencyRetargetsArrayInnerType InitialSource.
// Oracle: Item.Value defaults to 1; live Container.Items is empty (Num 0).
// Retained after reload: Item/Container types and Items. Replaced in 02: Item.AddedValue.
// Extra: empty Items is the default vector; mutating one item does not write the other.
// FixtureIsolated. Object handles are runner-owned when non-null.

UCLASS()
class UClassGeneratorPropagationItem : UObject
{
	UPROPERTY()
	int Value = 1;
}

UCLASS()
class UClassGeneratorPropagationContainer : UObject
{
	UPROPERTY()
	TArray<UClassGeneratorPropagationItem> Items;
}

int Observe_ContainerInitial_ItemDefaultValue(UClassGeneratorPropagationItem Item)
{
	return Item.Value;
}

int Observe_ContainerInitial_ItemsEmptyDefault(UClassGeneratorPropagationContainer Container)
{
	return Container.Items.Num();
}

int Observe_ContainerInitial_ItemEmptyValueBoundary(UClassGeneratorPropagationItem Item)
{
	Item.Value = 0;
	return Item.Value;
}

bool Observe_ContainerInitial_CopyIndependent(UClassGeneratorPropagationItem First, UClassGeneratorPropagationItem Second)
{
	First.Value = 9;
	return Second.Value == 1;
}
