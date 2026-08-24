// Theme: World.Component. WorldStory: DestroyComponent unregisters a runtime script component.
// C++: AngelscriptComponentLifecycleExtendedTests.cpp::DestroyComponentUnregistersRuntimeComponent
// CompileScriptModule + spawn DefaultComponent Probe + DestroySelf()==1, then C++
// Probe->IsBeingDestroyed() and !Probe->IsRegistered(). Keep property name Probe.
// sha256=1f2d0d408b4aafab106162d23425873c90e357581d5a24d6491b80012c31e599; lines 197-215.
// Extra: local construct leaves Probe null; a second instance stays independent null.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class UTestComponentLifecycleDestroyProbe : UActorComponent
{
	UFUNCTION()
	int DestroySelf()
	{
		DestroyComponent();
		return 1;
	}
}

UCLASS()
class ATestComponentLifecycleDestroy : AActor
{
	UPROPERTY(DefaultComponent)
	UTestComponentLifecycleDestroyProbe Probe;
}

bool Observe_DestroyComponent_DefaultProbeNull(ATestComponentLifecycleDestroy Actor)
{
	if (Actor is null)
	{
		throw("Test_DestroyComponentUnregistersRuntimeComponent setup: required Actor is null");
	}
	return Actor.Probe == nullptr;
}

bool Observe_DestroyComponent_CopyIndependence(ATestComponentLifecycleDestroy First, ATestComponentLifecycleDestroy Second)
{
	if (First is null)
	{
		throw("Test_DestroyComponentUnregistersRuntimeComponent setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_DestroyComponentUnregistersRuntimeComponent setup: required Second is null");
	}
	return First.Probe == nullptr && Second.Probe == nullptr;
}
