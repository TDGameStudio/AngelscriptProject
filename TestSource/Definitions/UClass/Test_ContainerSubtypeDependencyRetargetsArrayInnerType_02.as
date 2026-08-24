// Theme: Definitions.UClass. Reload version pair 02 (item layout change). Positive TArray inner-type dependency.
// C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::ContainerSubtypeDependencyRetargetsArrayInnerType ReloadSource.
// Oracle: Item.Value stays 1; AddedValue defaults to 2; live Container.Items is still empty.
// Retained: Item/Container types, Value, Items. Replaced: Item.AddedValue = 2.
// Extra: empty Items is the default vector; mutating AddedValue on one item does not write the other.
// FixtureIsolated. Object handles are runner-owned when non-null.

UCLASS()
class UClassGeneratorPropagationItem : UObject
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int AddedValue = 2;
}

UCLASS()
class UClassGeneratorPropagationContainer : UObject
{
	UPROPERTY()
	TArray<UClassGeneratorPropagationItem> Items;
}

int Observe_ContainerReload_ItemDefaultValue(UClassGeneratorPropagationItem Item)
{
	return Item.Value;
}

int Observe_ContainerReload_AddedValueDefault(UClassGeneratorPropagationItem Item)
{
	return Item.AddedValue;
}

int Observe_ContainerReload_ItemsEmptyDefault(UClassGeneratorPropagationContainer Container)
{
	return Container.Items.Num();
}

bool Observe_ContainerReload_CopyIndependent(UClassGeneratorPropagationItem First, UClassGeneratorPropagationItem Second)
{
	First.AddedValue = 0;
	return Second.AddedValue == 2;
}
