// Theme: Containers.TSoftObjectPtr. WorldStory: TSoftObjectPtr UPROPERTY declaration.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TSoftObjectPtr_Positive AssertCompiles ASSyntaxSPSoftDecl.
// Oracle: MeshAsset default is null. Extra: assignment vs a second instance stays independent.
// FixtureIsolated. Source owns locals.

class AActorSPSoftDecl : AActor
{
	UPROPERTY()
	TSoftObjectPtr<UStaticMesh> MeshAsset;
}

bool Observe_SoftDecl_DefaultNull(AActorSPSoftDecl Actor)
{
	if (Actor is null)
	{
		throw("Test_TSoftObjectPtr_Positive_01 setup: required Actor is null");
	}
	return Actor.MeshAsset.IsNull();
}

bool Observe_SoftDecl_CopyIndependence(AActorSPSoftDecl First, AActorSPSoftDecl Second)
{
	if (First is null)
	{
		throw("Test_TSoftObjectPtr_Positive_01 setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_TSoftObjectPtr_Positive_01 setup: required Second is null");
	}
	TSoftObjectPtr<UStaticMesh> Empty;
	First.MeshAsset = Empty;
	return First.MeshAsset.IsNull() && Second.MeshAsset.IsNull();
}
