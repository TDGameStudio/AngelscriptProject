// Theme: Feature.Inheritance. Positive inherited class flags, Config, HideDropdown.
// C++: AngelscriptCoverageUClassTests.cpp::UClassInheritedFlagsAndConfig
// sha256=90ff64b57fae9b153d43ee834832ca1c6aaefd561d4f953c21138aa132230c1f; lines 893-917.
// Oracle: CLASS_Config/DefaultConfig/Transient/Deprecated/DefaultToInstanced on the base;
// child Config property generated; HideDropdown base and visible child generate.
// Extra: BaseConfigValue==13; ChildConfigValue==17; zeros; two locals independent. DefaultSafe.

UCLASS(Transient, Deprecated, DefaultToInstanced, EditInlineNew, Config=Game, DefaultConfig)
class UCoverageUClassInheritedFlagBaseObject : UObject
{
	UPROPERTY(Config)
	int BaseConfigValue = 13;
}

UCLASS()
class UCoverageUClassInheritedFlagChildObject : UCoverageUClassInheritedFlagBaseObject
{
	UPROPERTY(Config)
	int ChildConfigValue = 17;
}

UCLASS(HideDropdown)
class UCoverageUClassHiddenDropdownBaseObject : UObject
{
}

UCLASS()
class UCoverageUClassVisibleDropdownChildObject : UCoverageUClassHiddenDropdownBaseObject
{
}

int Observe_InheritedFlags_BaseConfigDefault(UCoverageUClassInheritedFlagBaseObject Base)
{
	if (Base is null)
	{
		throw("Test_UClassInheritedFlagsAndConfig setup: required Base is null");
	}
	return Base.BaseConfigValue;
}

int Observe_InheritedFlags_ChildConfigDefault(UCoverageUClassInheritedFlagChildObject Child)
{
	if (Child is null)
	{
		throw("Test_UClassInheritedFlagsAndConfig setup: required Child is null");
	}
	return Child.ChildConfigValue;
}

int Observe_InheritedFlags_ZeroBoundary(UCoverageUClassInheritedFlagChildObject Child)
{
	if (Child is null)
	{
		throw("Test_UClassInheritedFlagsAndConfig setup: required Child is null");
	}
	Child.BaseConfigValue = 0;
	Child.ChildConfigValue = 0;
	return Child.BaseConfigValue + Child.ChildConfigValue;
}

bool Observe_InheritedFlags_TwoLocalsIndependent(UCoverageUClassInheritedFlagChildObject First, UCoverageUClassInheritedFlagChildObject Second)
{
	if (First is null)
	{
		throw("Test_UClassInheritedFlagsAndConfig setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_UClassInheritedFlagsAndConfig setup: required Second is null");
	}
	First.ChildConfigValue = 0;
	return First.ChildConfigValue == 0 && Second.ChildConfigValue == 17 && Second.BaseConfigValue == 13;
}

void Observe_HideDropdown_LocalConstruct()
{
	UCoverageUClassHiddenDropdownBaseObject Hidden;
	UCoverageUClassVisibleDropdownChildObject Visible;
}
