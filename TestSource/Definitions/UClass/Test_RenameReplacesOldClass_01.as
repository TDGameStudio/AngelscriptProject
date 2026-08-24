// Theme: Definitions.UClass. WorldStory rename pair BEFORE replacement.
// C++: AngelscriptScriptClassCreationTests.cpp::RenameReplacesOldClass block 1
// Oracle: ATestScriptClassRenameOld Version=1 is the retained-then-replaced class.
// Extra: nullptr actor is the empty handle; mutating First does not write Second.
// FixtureIsolated. Pair with Test_RenameReplacesOldClass_02.as. Keep Version.

UCLASS()
class ATestScriptClassRenameOld : AActor
{
	UPROPERTY()
	int Version = 1;
}

bool Observe_RenameOld_Nominal(ATestScriptClassRenameOld Actor)
{
	return Actor.Version == 1;
}

bool Observe_RenameOld_NullDefault()
{
	ATestScriptClassRenameOld Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_RenameOld_CopyIndependent(ATestScriptClassRenameOld First, ATestScriptClassRenameOld Second)
{
	First.Version = 0;
	return Second.Version == 1;
}
