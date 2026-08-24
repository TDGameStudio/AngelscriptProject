// Theme: Feature.DefaultComponent. WorldStory native UStaticMeshComponent root plus billboard.
// C++: AngelscriptComponentTests.cpp::NativeTypes
// Oracle after spawn: Billboard attach parent is the native mesh root.
// Extra: empty actor is null; Mesh/Billboard default handles are null. FixtureIsolated.

UCLASS()
class ATestDefaultComponentNativeTypes : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent Mesh;

	UPROPERTY(DefaultComponent, Attach = Mesh)
	UBillboardComponent Billboard;
}

bool Observe_NativeTypesActor_EmptyDefaultIsNull()
{
	ATestDefaultComponentNativeTypes Actor;
	return Actor == nullptr;
}

bool Observe_NativeTypes_MeshDefaultIsNull(ATestDefaultComponentNativeTypes Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0192 setup: required ATestDefaultComponentNativeTypes is null");
	}
	return Actor.Mesh == nullptr;
}

bool Observe_NativeTypes_BillboardDefaultIsNull(ATestDefaultComponentNativeTypes Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0192 setup: required ATestDefaultComponentNativeTypes is null");
	}
	return Actor.Billboard == nullptr;
}
