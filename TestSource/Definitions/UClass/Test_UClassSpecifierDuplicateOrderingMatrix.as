// Theme: Definitions.UClass. Positive duplicate Config/metadata last-wins ordering.
// C++: AngelscriptCoverageUClassTests.cpp::UClassSpecifierDuplicateOrderingMatrix
// Oracle: Config=Game then Config=Editor => ClassConfigName=Editor; reverse => Game;
// EditorConfigValue default 31; GameConfigValue default 37.
// Extra: unset handles are null; EditorConfigValue 0 boundary. DefaultSafe.

UCLASS(Config=Game, Config=Editor, DefaultConfig)
class UCoverageUClassConfigLastWinsEditorObject : UObject
{
	UPROPERTY(Config)
	int EditorConfigValue = 31;
}

UCLASS(Config=Editor, Config=Game, DefaultConfig)
class UCoverageUClassConfigLastWinsGameObject : UObject
{
	UPROPERTY(Config)
	int GameConfigValue = 37;
}

UCLASS(ClassGroup="FirstGroup", ClassGroup="SecondGroup", HideCategories="Rendering", HideCategories="Input", meta=(DisplayName="First Display", DisplayName="Second Display", ShortTooltip="First Short", ShortTooltip="Second Short", ToolTip="First ToolTip", ToolTip="Second ToolTip"))
class UCoverageUClassDuplicateMetadataObject : UObject
{
}

UCLASS(Blueprintable, NotBlueprintable, Blueprintable, BlueprintType)
class UCoverageUClassRepeatedBlueprintSpecifiersObject : UObject
{
}

bool Observe_ConfigLastWinsEditor_EmptyDefaultIsNull()
{
	UCoverageUClassConfigLastWinsEditorObject Obj;
	return Obj == nullptr;
}

int Observe_ConfigLastWinsEditor_ValueDefault(UCoverageUClassConfigLastWinsEditorObject Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-DEF-0159 setup: required UCoverageUClassConfigLastWinsEditorObject is null");
	}
	return Obj.EditorConfigValue;
}

int Observe_ConfigLastWinsEditor_ValueZeroBoundary(UCoverageUClassConfigLastWinsEditorObject Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-DEF-0159 setup: required UCoverageUClassConfigLastWinsEditorObject is null");
	}
	Obj.EditorConfigValue = 0;
	return Obj.EditorConfigValue;
}

int Observe_ConfigLastWinsGame_ValueDefault(UCoverageUClassConfigLastWinsGameObject Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-DEF-0159 setup: required UCoverageUClassConfigLastWinsGameObject is null");
	}
	return Obj.GameConfigValue;
}

bool Observe_DuplicateMetadata_EmptyDefaultIsNull()
{
	UCoverageUClassDuplicateMetadataObject Obj;
	return Obj == nullptr;
}

bool Observe_RepeatedBlueprintSpecifiers_EmptyDefaultIsNull()
{
	UCoverageUClassRepeatedBlueprintSpecifiersObject Obj;
	return Obj == nullptr;
}
