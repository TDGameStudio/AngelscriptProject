// Theme: Definitions.UClass. Positive Config/DefaultConfig/DefaultToInstanced/EditInlineNew/HideDropdown.
// C++: AngelscriptCoverageUClassTests.cpp::UClassConfigAndInlineCreationSpecifiers
// Oracle: CLASS_Config/DefaultConfig/DefaultToInstanced/EditInlineNew/HideDropDown; ClassConfigName=Game;
// ConfigValue default 7; EditorValue default 11. Extra: unset null; ConfigValue 0 boundary. DefaultSafe.

UCLASS(Config=Game, DefaultConfig, DefaultToInstanced, EditInlineNew, HideDropdown)
class UCoverageUClassConfigInlineObject : UObject
{
	UPROPERTY(Config)
	int ConfigValue = 7;
}

UCLASS(Config=Editor)
class UCoverageUClassEditorConfigObject : UObject
{
	UPROPERTY(Config)
	int EditorValue = 11;
}

bool Observe_ConfigInline_EmptyDefaultIsNull()
{
	UCoverageUClassConfigInlineObject Obj;
	return Obj == nullptr;
}

int Observe_ConfigInline_ConfigValueDefault(UCoverageUClassConfigInlineObject Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-DEF-0141 setup: required UCoverageUClassConfigInlineObject is null");
	}
	return Obj.ConfigValue;
}

int Observe_ConfigInline_ConfigValueZeroBoundary(UCoverageUClassConfigInlineObject Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-DEF-0141 setup: required UCoverageUClassConfigInlineObject is null");
	}
	Obj.ConfigValue = 0;
	return Obj.ConfigValue;
}

int Observe_EditorConfig_EditorValueDefault(UCoverageUClassEditorConfigObject Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-DEF-0141 setup: required UCoverageUClassEditorConfigObject is null");
	}
	return Obj.EditorValue;
}
