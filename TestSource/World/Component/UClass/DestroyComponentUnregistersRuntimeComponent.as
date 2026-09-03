/**
 * DestroyComponent on a runtime script component, which must leave it both
 * destroying and unregistered. C++ spawns the actor, calls DestroySelf and then
 * inspects the probe. The observers cover the local-construct default.
 *
 * @Theme World.Component
 * @Subject Component.DestroyComponentUnregisters
 * @Harness UClass
 * @Tag World.Component.DestroyComponentUnregistersRuntimeComponent
 * @Provenance Theme: World.Component. WorldStory: DestroyComponent unregisters a runtime script component.
 * @Provenance C++: AngelscriptComponentLifecycleExtendedTests.cpp::DestroyComponentUnregistersRuntimeComponent
 * @Provenance CompileScriptModule + spawn DefaultComponent Probe + DestroySelf()==1, then C++
 * @Provenance Probe->IsBeingDestroyed() and !Probe->IsRegistered(). Keep property name Probe.
 * @Provenance sha256=1f2d0d408b4aafab106162d23425873c90e357581d5a24d6491b80012c31e599; lines 197-215.
 * @Provenance Extra: local construct leaves Probe null; a second instance stays independent null.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

UCLASS()
class UTestComponentLifecycleDestroyProbe : UActorComponent
{
	/**
	 * Destroy this component and report that the call completed.
	 *
	 * @Kind Action
	 * @Covers Component.DestroyComponentUnregisters
	 * @Inputs none
	 * @Return 1
	 */
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

	/**
	 * Observe that a locally constructed actor has no probe component.
	 *
	 * @Kind Observe
	 * @Covers Component.DestroyComponentUnregisters
	 * @Inputs an actor that has not been spawned
	 * @Return true when Probe is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultProbeNull()
	{
		return Probe == nullptr;
	}

	/**
	 * Observe that a second instance keeps its own independent null probe.
	 *
	 * @Kind Observe
	 * @Covers Component.DestroyComponentUnregisters
	 * @Inputs this actor plus a second actor
	 * @Return true when both probes are null
	 * @Param Second the other actor, also expected to hold a null probe
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestComponentLifecycleDestroy Second)
	{
		if (Second is null)
		{
			throw("DestroyComponentUnregistersRuntimeComponent setup: required Second is null");
		}
		if (Probe != nullptr)
		{
			return false;
		}
		return Second.Probe == nullptr;
	}
}
