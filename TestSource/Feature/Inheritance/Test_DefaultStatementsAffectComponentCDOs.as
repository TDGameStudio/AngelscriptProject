// Theme: Feature.Inheritance. WorldStory default statements write DefaultComponent CDO values.
// C++: AngelscriptComponentDefaultPropertyOverrideTests.cpp::DefaultStatementsAffectComponentCDOs
// Oracle: Sphere.SphereRadius==128; Mesh bHiddenInGame true; CastShadow false; relative yaw 45.
// Extra: empty handle null; SphereRadius 0 mutation is copy-independent. FixtureIsolated.
// Keep Sphere/Mesh.

UCLASS()
class AFunctionalDefaultOverrideActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY(DefaultComponent, Attach = Sphere)
	UStaticMeshComponent Mesh;

	default Sphere.SphereRadius = 128.0;
	default Mesh.SetHiddenInGame(true);
	default Mesh.SetCastShadow(false);
	default Mesh.SetRelativeRotation(FRotator(0.0f, 45.0f, 0.0f));
}

bool Observe_DefaultComponentCDO_EmptyHandleIsNull()
{
	AFunctionalDefaultOverrideActor Actor;
	return Actor == nullptr;
}

float Observe_DefaultComponentCDO_SphereRadius(AFunctionalDefaultOverrideActor Actor)
{
	if (Actor == nullptr || Actor.Sphere == nullptr)
	{
		throw("TS-FEAT-0183 setup: required Sphere component is null");
	}
	return Actor.Sphere.SphereRadius;
}

float Observe_DefaultComponentCDO_MeshYaw(AFunctionalDefaultOverrideActor Actor)
{
	if (Actor == nullptr || Actor.Mesh == nullptr)
	{
		throw("TS-FEAT-0183 setup: required Mesh component is null");
	}
	return Actor.Mesh.GetRelativeRotation().Yaw;
}

bool Observe_DefaultComponentCDO_CopyIndependence(
	AFunctionalDefaultOverrideActor First,
	AFunctionalDefaultOverrideActor Second)
{
	if (First == nullptr || Second == nullptr || First.Sphere == nullptr || Second.Sphere == nullptr)
	{
		throw("TS-FEAT-0183 setup: required actors are null");
	}
	First.Sphere.SphereRadius = 0.0;
	return Math::Abs(Second.Sphere.SphereRadius - 128.0) < 0.001
		&& Math::Abs(First.Sphere.SphereRadius) < 0.001;
}
