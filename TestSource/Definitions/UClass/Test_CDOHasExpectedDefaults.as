// Theme: Definitions.UClass. WorldStory CDO and spawned-instance defaults.
// C++: AngelscriptScriptClassCreationTests.cpp::CDOHasExpectedDefaults
// Oracle: DefaultCounter=21, bDefaultFlag=true, DefaultLabel="CDOStable" on CDO and spawn.
// Extra: nullptr actor is the empty handle; mutating First does not write Second.
// FixtureIsolated. Runner owns CDO and spawned actor. Keep DefaultCounter/bDefaultFlag/DefaultLabel.

UCLASS()
class ATestScriptClassCDOHasExpectedDefaults : AActor
{
	UPROPERTY()
	int DefaultCounter = 21;

	UPROPERTY()
	bool bDefaultFlag = true;

	UPROPERTY()
	FString DefaultLabel = "CDOStable";
}

bool Observe_CDODefaults_Nominal(ATestScriptClassCDOHasExpectedDefaults Actor)
{
	return Actor.DefaultCounter == 21 && Actor.bDefaultFlag && Actor.DefaultLabel == "CDOStable";
}

bool Observe_CDODefaults_NullDefault()
{
	ATestScriptClassCDOHasExpectedDefaults Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_CDODefaults_CopyIndependent(
	ATestScriptClassCDOHasExpectedDefaults First,
	ATestScriptClassCDOHasExpectedDefaults Second)
{
	First.DefaultCounter = 0;
	First.bDefaultFlag = false;
	First.DefaultLabel = "";
	return Second.DefaultCounter == 21 && Second.bDefaultFlag && Second.DefaultLabel == "CDOStable";
}
