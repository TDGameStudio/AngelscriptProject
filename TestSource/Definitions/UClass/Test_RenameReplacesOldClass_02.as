// Theme: Definitions.UClass. WorldStory rename pair AFTER replacement.
// C++: AngelscriptScriptClassCreationTests.cpp::RenameReplacesOldClass block 2
// Oracle: ATestScriptClassRenameNew Version=2 on the renamed CDO. Old name is replaced.
// Extra: nullptr actor is the empty handle; mutating First does not write Second.
// FixtureIsolated. Pair with Test_RenameReplacesOldClass_01.as. Keep Version.

UCLASS()
class ATestScriptClassRenameNew : AActor
{
	UPROPERTY()
	int Version = 2;
}

bool Observe_RenameNew_Nominal(ATestScriptClassRenameNew Actor)
{
	return Actor.Version == 2;
}

bool Observe_RenameNew_NullDefault()
{
	ATestScriptClassRenameNew Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_RenameNew_CopyIndependent(ATestScriptClassRenameNew First, ATestScriptClassRenameNew Second)
{
	First.Version = 0;
	return Second.Version == 2;
}
