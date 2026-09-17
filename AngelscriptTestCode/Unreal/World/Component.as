/**
 * @version v1
 * @summary World component attach, tick, collision, and accessors.
 * @topic Unreal
 * @topic World
 *
 * component-query-entrypoint-smoke
 * actor-owner
 * advanced-input-component-binding-collections
 * audio-component-declaration-and-controls
 * audio-component-fade-and-filter-controls
 * audio-component-routing-and-reflection-surface
 * begin-play
 * box-component
 * camera-component
 * capsule-component
 * character-movement-component
 * component-activation
 * component-actor-multi-and-dynamic-lifecycle-ordering
 * component-basic-declaration
 * component-collision-event-dispatch
 * component-destruction
 * component-destruction-callbacks-and-state
 * component-finding
 * component-finding-by-class-and-tag
 * component-lifecycle
 * component-lifecycle-ordering
 * component-manual-new-object-registration
 * component-registration-and-activation
 * component-runtime-tick-interval-control
 * component-special-type-declarations
 * component-tags
 * component-tick-configuration-and-prerequisites
 * component-tick-control
 * component-tick-dispatch-is-exact
 * create-component
 * custom-script-component
 * custom-script-scene-component
 * destroy-component-unregisters-runtime-component
 * end-play-receives-destroyed-reason
 * enhanced-input-component-binding-events-and-removal
 * event-built-in-actor-and-component-instances
 * four-level-attach-chain-resolves
 * get-all-components
 * get-component
 * get-or-create-component
 * has-begun-play-transitions-in-world
 * interface-component-and-input
 * member-object-actor-component-references
 * multiple-shape-components
 * name-and-class-filtering-are-strict
 * primitive-collision-channel-matrix-readback
 * primitive-collision-configuration-readback
 * primitive-collision-events
 * primitive-collision-response
 * primitive-hidden-in-game
 * primitive-hit-events
 * primitive-physics
 * primitive-physics-state-readback
 * primitive-rendering
 * primitive-trace-object-query-readback
 * receive-end-play
 * return-components-to-cpp
 * scene-component-complete-transform
 * scene-component-hierarchy
 * scene-component-relative-transform
 * scene-component-tags
 * scene-component-world-transform
 * special-component-operations
 * sphere-component
 * spring-arm-component
 * static-mesh-component
 * static-typed-accessors-create-get-and-reuse
 * tick
 * timer-compile-stable-actor-and-component-call-sites
 * timer-component-callbacks-run-on-owner-world
 * timer-destroyed-component-stops-callbacks
 */
/**
 * @begin component-query-entrypoint-smoke
 * @summary Sweep and overlap entrypoints driven from a world collision function library. C++ builds the blocking, overlap and query boxes, then calls both entrypoints by name through ExpectGlobalReturn. The names are part of the.
 * @topic Component
 */
namespace ComponentTest
{
	/**
	 * Run both query entrypoints against a real query component.
	 *
	 * @Kind Observe
	 * @Covers Component.QueryEntrypointSmoke
	 * @Inputs a query component swept across and overlapped with the built boxes
	 * @Return 1 when both queries report hits and overlaps, otherwise 0
	 * @Param QueryComponent the component to query with
	 */
	UFUNCTION()
	int VerifyComponentQueryEntrypointSmoke(UPrimitiveComponent QueryComponent)
	{
		TArray<FHitResult> Hits;
		TArray<FOverlapResult> Overlaps;

		FComponentQueryParams Params = FComponentQueryParams::DefaultComponentQueryParams;
		Params.AddIgnoredComponent(QueryComponent);

		FCollisionObjectQueryParams ObjectQueryParams;
		ObjectQueryParams.AddObjectTypesToQuery(ECollisionChannel::ECC_WorldDynamic);

		const bool bSweep = System::ComponentSweepMulti(
			Hits,
			QueryComponent,
			FVector(-200.0f, 0.0f, 0.0f),
			FVector(200.0f, 0.0f, 0.0f),
			FQuat::Identity,
			Params);

		const bool bOverlap = System::ComponentOverlapMulti(
			Overlaps,
			QueryComponent,
			FVector(0.0f, 150.0f, 0.0f),
			FQuat::Identity,
			Params,
			ObjectQueryParams);

		if (!bSweep)
		{
			return 0;
		}
		if (!bOverlap)
		{
			return 0;
		}
		if (Hits.Num() <= 0)
		{
			return 0;
		}
		if (Overlaps.Num() <= 0)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Run both query entrypoints with a null component, which must be refused.
	 *
	 * @Kind Observe
	 * @Covers Component.QueryEntrypointSmoke
	 * @Inputs a null query component
	 * @Return 1 when both queries refuse and both arrays stay empty, otherwise 0
	 * @Boundary null query component
	 */
	UFUNCTION()
	int VerifyNullComponentQueryGuards()
	{
		TArray<FHitResult> Hits;
		TArray<FOverlapResult> Overlaps;

		FComponentQueryParams Params = FComponentQueryParams::DefaultComponentQueryParams;
		FCollisionObjectQueryParams ObjectQueryParams;
		ObjectQueryParams.AddObjectTypesToQuery(ECollisionChannel::ECC_WorldDynamic);

		const bool bSweep = System::ComponentSweepMulti(
			Hits,
			nullptr,
			FVector(-200.0f, 0.0f, 0.0f),
			FVector(200.0f, 0.0f, 0.0f),
			FQuat::Identity,
			Params);

		const bool bOverlap = System::ComponentOverlapMulti(
			Overlaps,
			nullptr,
			FVector(0.0f, 150.0f, 0.0f),
			FQuat::Identity,
			Params,
			ObjectQueryParams);

		if (bSweep)
		{
			return 0;
		}
		if (bOverlap)
		{
			return 0;
		}
		if (Hits.Num() != 0)
		{
			return 0;
		}
		if (Overlaps.Num() != 0)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that freshly declared result arrays are empty.
	 *
	 * @Kind Observe
	 * @Covers Component.QueryEntrypointSmoke
	 * @Inputs newly declared hit and overlap arrays
	 * @Return 1 when both are empty, otherwise 0
	 * @Boundary empty arrays
	 */
	UFUNCTION()
	int EmptyArrays()
	{
		TArray<FHitResult> Hits;
		TArray<FOverlapResult> Overlaps;

		if (Hits.Num() != 0)
		{
			return 0;
		}
		if (Overlaps.Num() != 0)
		{
			return 0;
		}
		return 1;
	}
}
/** @end */
/**
 * @begin actor-owner
 * @summary A component whose BeginPlay reads a value off its owning script actor. C++ spawns the owner, attaches the component and verifies ReadOwnerValue through its path. The observers cover the local-construct default and copy.
 * @topic Component
 */
UCLASS()
class ATestComponentOwnerActor : AActor
{
	UPROPERTY()
	int OwnerValue = 42;
}

UCLASS()
class UTestComponentActorOwner : UActorComponent
{
	UPROPERTY()
	int ReadOwnerValue = 0;

	/**
	 * WorldStory: BeginPlay reads OwnerValue off the owning script actor.
	 *
	 * @Kind WorldStory
	 * @Covers Component.ActorOwner
	 * @Inputs owning ATestComponentOwnerActor with OwnerValue 42
	 * @Return ReadOwnerValue == 42; stays 0 when the owner is not an ATestComponentOwnerActor
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ATestComponentOwnerActor OwnerActor = Cast<ATestComponentOwnerActor>(GetOwner());
		if (OwnerActor != null)
		{
			ReadOwnerValue = OwnerActor.OwnerValue;
		}
	}

	/**
	 * Observe that a locally constructed component leaves the value at zero.
	 *
	 * @Kind Observe
	 * @Covers Component.ActorOwner
	 * @Inputs a component that has not run BeginPlay against an owner
	 * @Return true when ReadOwnerValue is 0
	 * @Boundary null owner path
	 */
	UFUNCTION()
	bool DefaultReadZero()
	{
		return ReadOwnerValue == 0;
	}

	/**
	 * Observe that writing this instance leaves another instance untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.ActorOwner
	 * @Inputs this component plus a second component
	 * @Return true when this reads 42 and the other still reads 0
	 * @Param Second the other component, expected to stay at 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UTestComponentActorOwner Second)
	{
		if (Second is null)
		{
			throw("ActorOwner setup: required Second is null");
		}
		ReadOwnerValue = 42;
		if (ReadOwnerValue != 42)
		{
			return false;
		}
		return Second.ReadOwnerValue == 0;
	}
}
/** @end */
/**
 * @begin advanced-input-component-binding-collections
 * @summary A pawn whose SetupInput binds a chord, an axis key and a vector axis. C++ runs SetupInput once and counts one binding of each kind. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class AAdvancedInputBindingPawn : APawn
{
	UPROPERTY()
	int SetupCallCount = 0;

	/**
	 * WorldStory: SetupInput runs once and installs one chord, one axis key and
	 * one vector axis binding.
	 *
	 * @Kind WorldStory
	 * @Covers Component.AdvancedInputComponentBindingCollections
	 * @Inputs a player input component
	 * @Return SetupCallCount == 1; C++ counts Key/AxisKey/VectorAxis bindings = 1
	 * @Param PlayerInputComponent the component to bind against
	 */
	UFUNCTION()
	void SetupInput(UInputComponent PlayerInputComponent)
	{
		SetupCallCount++;

		FInputActionHandlerDynamicSignature ChordDelegate;
		PlayerInputComponent.BindChord(FInputChord(EKeys::LeftMouseButton, true, false, false, false), EInputEvent::IE_Pressed, ChordDelegate);

		FInputAxisHandlerDynamicSignature AxisKeyDelegate;
		PlayerInputComponent.BindAxisKey(n"MouseX", AxisKeyDelegate);

		FInputVectorAxisHandlerDynamicSignature VectorAxisDelegate;
		PlayerInputComponent.BindVectorAxis(EKeys::Tilt, VectorAxisDelegate);
	}

	/**
	 * Observe that a locally constructed pawn has not run SetupInput.
	 *
	 * @Kind Observe
	 * @Covers Component.AdvancedInputComponentBindingCollections
	 * @Inputs a pawn that has not been set up
	 * @Return the setup call count, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int DefaultCallCount()
	{
		return SetupCallCount;
	}

	/**
	 * Observe that writing this pawn leaves another pawn untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.AdvancedInputComponentBindingCollections
	 * @Inputs this pawn plus a second pawn
	 * @Return true when this counts 1 and the other still counts 0
	 * @Param Second the other pawn, expected to stay at 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(AAdvancedInputBindingPawn Second)
	{
		if (Second is null)
		{
			throw("AdvancedInputComponentBindingCollections setup: required Second is null");
		}
		SetupCallCount = 1;
		if (SetupCallCount != 1)
		{
			return false;
		}
		return Second.SetupCallCount == 0;
	}
}
/** @end */
/**
 * @begin audio-component-declaration-and-controls
 * @summary An actor whose UAudioComponent BeginPlay exercises the playback and parameter controls. C++ verifies the four outcome flags. A null audio component is the early-out vector: only the validity flag is written and the rest.
 * @topic Component
 */
UCLASS()
class ACoverageAudioComponentActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UAudioComponent Audio;

	UPROPERTY()
	bool bAudioComponentValid = false;

	UPROPERTY()
	bool bPlaybackControlsCallable = false;

	UPROPERTY()
	bool bParameterControlsCallable = false;

	UPROPERTY()
	bool bAudioRemainsStoppedWithoutSound = false;

	/**
	 * WorldStory: BeginPlay drives volume, pitch, UI sound, pause, play, stop and
	 * the three typed parameters, then records that playback stayed stopped.
	 *
	 * @Kind WorldStory
	 * @Covers Component.AudioComponentDeclarationAndControls
	 * @Inputs a default-attached UAudioComponent
	 * @Return all four flags true; with a null component only bAudioComponentValid is written
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		bAudioComponentValid = Audio != nullptr;
		if (Audio == nullptr)
		{
			return;
		}

		Audio.SetVolumeMultiplier(0.25f);
		Audio.SetPitchMultiplier(1.50f);
		Audio.SetUISound(true);
		Audio.SetPaused(true);
		Audio.SetPaused(false);
		Audio.Play(0.0f);
		Audio.Stop();
		bPlaybackControlsCallable = true;

		Audio.SetBoolParameter(n"CoverageBool", true);
		Audio.SetFloatParameter(n"CoverageFloat", 0.75f);
		Audio.SetIntParameter(n"CoverageInt", 12);
		bParameterControlsCallable = true;

		bAudioRemainsStoppedWithoutSound = !Audio.IsPlaying();
	}
}
/** @end */
/**
 * @begin audio-component-fade-and-filter-controls
 * @summary An actor whose UAudioComponent BeginPlay exercises the fade and filter controls. C++ verifies both outcome flags by path. A null audio component is the early-out vector that leaves both flags false.
 * @topic Component
 */
UCLASS()
class ACoverageAudioFadeActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UAudioComponent Audio;

	UPROPERTY()
	bool bFadeControlsCallable = false;

	UPROPERTY()
	bool bFilterControlsCallable = false;

	/**
	 * WorldStory: BeginPlay fades in, adjusts volume and fades out, then enables
	 * both the low pass and the high pass filter.
	 *
	 * @Kind WorldStory
	 * @Covers Component.AudioComponentFadeAndFilterControls
	 * @Inputs a default-attached UAudioComponent
	 * @Return both flags true; with a null component both stay false
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (Audio == nullptr)
		{
			return;
		}

		Audio.FadeIn(0.01f, 0.5f, 0.0f);
		Audio.AdjustVolume(0.01f, 0.25f);
		Audio.FadeOut(0.01f, 0.0f);
		bFadeControlsCallable = true;

		Audio.SetLowPassFilterEnabled(true);
		Audio.SetLowPassFilterFrequency(1200.0f);
		Audio.SetHighPassFilterEnabled(true);
		Audio.SetHighPassFilterFrequency(300.0f);
		bFilterControlsCallable = true;
	}
}
/** @end */
/**
 * @begin audio-component-routing-and-reflection-surface
 * @summary An actor whose UAudioComponent BeginPlay clears the sound and attenuation routing. C++ verifies the flag and reads the reflected Sound / Attenuation / Concurrency properties. A null audio component leaves the flag false.
 * @topic Component
 */
UCLASS()
class ACoverageAudioRoutingActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UAudioComponent Audio;

	UPROPERTY()
	bool bRoutingSurfaceCallable = false;

	/**
	 * WorldStory: BeginPlay clears both routing slots to nullptr.
	 *
	 * @Kind WorldStory
	 * @Covers Component.AudioComponentRoutingAndReflectionSurface
	 * @Inputs a default-attached UAudioComponent
	 * @Return bRoutingSurfaceCallable true; with a null component it stays false
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (Audio == nullptr)
		{
			return;
		}

		Audio.SetSound(nullptr);
		Audio.SetAttenuationSettings(nullptr);
		bRoutingSurfaceCallable = true;
	}
}
/** @end */
/**
 * @begin begin-play
 * @summary A component whose BeginPlay sets bReady. C++ creates the component, runs BeginPlay and verifies bReady through its path. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class UTestComponentBeginPlay : UActorComponent
{
	UPROPERTY()
	bool bReady = false;

	/**
	 * WorldStory: BeginPlay flips bReady to true.
	 *
	 * @Kind WorldStory
	 * @Covers Component.BeginPlay
	 * @Inputs none
	 * @Return bReady == true once BeginPlay has run
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		bReady = true;
	}

	/**
	 * Observe that a locally constructed component is not ready.
	 *
	 * @Kind Observe
	 * @Covers Component.BeginPlay
	 * @Inputs a component that has not run BeginPlay
	 * @Return true when bReady is false
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		return bReady == false;
	}

	/**
	 * Observe that writing this component leaves another component untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.BeginPlay
	 * @Inputs this component plus a second component
	 * @Return true when this is ready and the other is not
	 * @Param Second the other component, expected to stay false
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UTestComponentBeginPlay Second)
	{
		if (Second is null)
		{
			throw("BeginPlay setup: required Second is null");
		}
		bReady = true;
		if (!bReady)
		{
			return false;
		}
		return Second.bReady == false;
	}
}
/** @end */
/**
 * @begin box-component
 * @summary An actor whose UBoxComponent BeginPlay records the extent before and after SetBoxExtent. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class ACoverageSpecialBoxActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent BoxComp;

	UPROPERTY()
	FVector InitialExtent;

	UPROPERTY()
	FVector NewExtent;

	/**
	 * WorldStory: BeginPlay reads the unscaled extent, resizes the box, then reads
	 * it again.
	 *
	 * @Kind WorldStory
	 * @Covers Component.BoxComponent
	 * @Inputs a default-attached UBoxComponent
	 * @Return NewExtent == (100, 200, 300) after SetBoxExtent
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitialExtent = BoxComp.GetUnscaledBoxExtent();

		BoxComp.SetBoxExtent(FVector(100.0f, 200.0f, 300.0f));

		NewExtent = BoxComp.GetUnscaledBoxExtent();
	}

	/**
	 * Observe that a locally constructed actor has no extents and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.BoxComponent
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both extents are empty and BoxComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (InitialExtent.X != 0.0f)
		{
			return false;
		}
		if (NewExtent.X != 0.0f)
		{
			return false;
		}
		if (NewExtent.Y != 0.0f)
		{
			return false;
		}
		if (NewExtent.Z != 0.0f)
		{
			return false;
		}
		return BoxComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.BoxComponent
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the new extent and the other stays empty
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialBoxActor Second)
	{
		if (Second is null)
		{
			throw("BoxComponent setup: required Second is null");
		}
		NewExtent = FVector(100.0f, 200.0f, 300.0f);

		if (NewExtent.X != 100.0f)
		{
			return false;
		}
		if (NewExtent.Z != 300.0f)
		{
			return false;
		}
		if (Second.NewExtent.X != 0.0f)
		{
			return false;
		}
		return Second.NewExtent.Z == 0.0f;
	}
}
/** @end */
/**
 * @begin camera-component
 * @summary An actor whose UCameraComponent BeginPlay writes and reads FieldOfView. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class ACoverageSpecialCameraActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UCameraComponent CameraComp;

	UPROPERTY()
	float InitialFOV = 0.0f;

	UPROPERTY()
	float NewFOV = 0.0f;

	UPROPERTY()
	bool FieldOfViewSet = false;

	/**
	 * WorldStory: BeginPlay reads the field of view, widens it to 120, then reads
	 * it back and records that the write took.
	 *
	 * @Kind WorldStory
	 * @Covers Component.CameraComponent
	 * @Inputs a default-attached UCameraComponent
	 * @Return NewFOV == 120 and FieldOfViewSet true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (CameraComp != nullptr)
		{
			InitialFOV = CameraComp.FieldOfView;

			CameraComp.FieldOfView = 120.0f;

			NewFOV = CameraComp.FieldOfView;
			FieldOfViewSet = NewFOV > 119.0f;
		}
	}

	/**
	 * Observe that a locally constructed actor has no field of view and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.CameraComponent
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both fields of view are 0, the flag is clear and both components are null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (InitialFOV != 0.0f)
		{
			return false;
		}
		if (NewFOV != 0.0f)
		{
			return false;
		}
		if (FieldOfViewSet)
		{
			return false;
		}
		if (CameraComp != nullptr)
		{
			return false;
		}
		return Root == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.CameraComponent
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds 120 with the flag set and the other stays at 0
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialCameraActor Second)
	{
		if (Second is null)
		{
			throw("CameraComponent setup: required Second is null");
		}
		NewFOV = 120.0f;
		FieldOfViewSet = true;

		if (NewFOV != 120.0f)
		{
			return false;
		}
		if (!FieldOfViewSet)
		{
			return false;
		}
		if (Second.NewFOV != 0.0f)
		{
			return false;
		}
		return !Second.FieldOfViewSet;
	}
}
/** @end */
/**
 * @begin capsule-component
 * @summary An actor whose UCapsuleComponent BeginPlay records radius and half-height before and after SetCapsuleSize. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class ACoverageSpecialCapsuleActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UCapsuleComponent CapsuleComp;

	UPROPERTY()
	float InitialRadius = 0.0f;

	UPROPERTY()
	float InitialHalfHeight = 0.0f;

	UPROPERTY()
	float NewRadius = 0.0f;

	UPROPERTY()
	float NewHalfHeight = 0.0f;

	/**
	 * WorldStory: BeginPlay reads both capsule dimensions, resizes the capsule,
	 * then reads them back.
	 *
	 * @Kind WorldStory
	 * @Covers Component.CapsuleComponent
	 * @Inputs a default-attached UCapsuleComponent
	 * @Return NewRadius == 50 and NewHalfHeight == 100
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitialRadius = CapsuleComp.GetUnscaledCapsuleRadius();
		InitialHalfHeight = CapsuleComp.GetUnscaledCapsuleHalfHeight();

		CapsuleComp.SetCapsuleSize(50.0f, 100.0f);

		NewRadius = CapsuleComp.GetUnscaledCapsuleRadius();
		NewHalfHeight = CapsuleComp.GetUnscaledCapsuleHalfHeight();
	}

	/**
	 * Observe that a locally constructed actor has all four dimensions at zero.
	 *
	 * @Kind Observe
	 * @Covers Component.CapsuleComponent
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all four are 0 and CapsuleComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (InitialRadius != 0.0f)
		{
			return false;
		}
		if (InitialHalfHeight != 0.0f)
		{
			return false;
		}
		if (NewRadius != 0.0f)
		{
			return false;
		}
		if (NewHalfHeight != 0.0f)
		{
			return false;
		}
		return CapsuleComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.CapsuleComponent
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds 50/100 and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialCapsuleActor Second)
	{
		if (Second is null)
		{
			throw("CapsuleComponent setup: required Second is null");
		}
		NewRadius = 50.0f;
		NewHalfHeight = 100.0f;

		if (NewRadius != 50.0f)
		{
			return false;
		}
		if (NewHalfHeight != 100.0f)
		{
			return false;
		}
		if (Second.NewRadius != 0.0f)
		{
			return false;
		}
		return Second.NewHalfHeight == 0.0f;
	}
}
/** @end */
/**
 * @begin character-movement-component
 * @summary An actor whose UCharacterMovementComponent BeginPlay writes and reads MaxWalkSpeed, JumpZVelocity and GravityScale. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class ACoverageSpecialCharacterMovementActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCharacterMovementComponent MovementComp;

	UPROPERTY()
	float InitialMaxWalkSpeed = 0.0f;

	UPROPERTY()
	float NewMaxWalkSpeed = 0.0f;

	UPROPERTY()
	float InitialJumpVelocity = 0.0f;

	UPROPERTY()
	float NewJumpVelocity = 0.0f;

	UPROPERTY()
	float InitialGravityScale = 0.0f;

	UPROPERTY()
	float NewGravityScale = 0.0f;

	/**
	 * WorldStory: BeginPlay reads all three movement values, writes new ones, then
	 * reads them back.
	 *
	 * @Kind WorldStory
	 * @Covers Component.CharacterMovementComponent
	 * @Inputs a default-attached UCharacterMovementComponent
	 * @Return NewMaxWalkSpeed == 800, NewJumpVelocity == 500, NewGravityScale == 1.5
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (MovementComp != nullptr)
		{
			// Read initial values
			InitialMaxWalkSpeed = MovementComp.MaxWalkSpeed;
			InitialJumpVelocity = MovementComp.JumpZVelocity;
			InitialGravityScale = MovementComp.GravityScale;

			// Set new values
			MovementComp.MaxWalkSpeed = 800.0f;
			MovementComp.JumpZVelocity = 500.0f;
			MovementComp.GravityScale = 1.5f;

			// Read back
			NewMaxWalkSpeed = MovementComp.MaxWalkSpeed;
			NewJumpVelocity = MovementComp.JumpZVelocity;
			NewGravityScale = MovementComp.GravityScale;
		}
	}

	/**
	 * Observe that a locally constructed actor has all three new values at zero.
	 *
	 * @Kind Observe
	 * @Covers Component.CharacterMovementComponent
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all three new values are 0 and MovementComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (NewMaxWalkSpeed != 0.0f)
		{
			return false;
		}
		if (NewJumpVelocity != 0.0f)
		{
			return false;
		}
		if (NewGravityScale != 0.0f)
		{
			return false;
		}
		return MovementComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.CharacterMovementComponent
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds 800/500 and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialCharacterMovementActor Second)
	{
		if (Second is null)
		{
			throw("CharacterMovementComponent setup: required Second is null");
		}
		NewMaxWalkSpeed = 800.0f;
		NewJumpVelocity = 500.0f;

		if (NewMaxWalkSpeed != 800.0f)
		{
			return false;
		}
		if (NewJumpVelocity != 500.0f)
		{
			return false;
		}
		if (Second.NewMaxWalkSpeed != 0.0f)
		{
			return false;
		}
		return Second.NewJumpVelocity == 0.0f;
	}
}
/** @end */
/**
 * @begin component-activation
 * @summary A component whose BeginPlay walks IsActive through Deactivate and Activate. C++ verifies the three outcome flags by path. The observers cover the local-construct defaults and copy independence.
 * @topic Component
 */
UCLASS()
class UCoverageActivationComponent : UActorComponent
{
}

UCLASS()
class ACoverageComponentActivationActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageActivationComponent TestComp;

	UPROPERTY()
	bool InitiallyActive = false;

	UPROPERTY()
	bool AfterDeactivate = true;

	UPROPERTY()
	bool AfterReactivate = false;

	/**
	 * WorldStory: BeginPlay records the active state, deactivates, then reactivates.
	 *
	 * @Kind WorldStory
	 * @Covers Component.ComponentActivation
	 * @Inputs a default-attached UCoverageActivationComponent
	 * @Return InitiallyActive false, AfterDeactivate false, AfterReactivate true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitiallyActive = TestComp.IsActive();

		TestComp.Deactivate();
		AfterDeactivate = TestComp.IsActive();

		TestComp.Activate(true);
		AfterReactivate = TestComp.IsActive();
	}

	/**
	 * Observe that a locally constructed actor keeps its declared defaults.
	 *
	 * @Kind Observe
	 * @Covers Component.ComponentActivation
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the declared defaults hold and TestComp is null
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (InitiallyActive)
		{
			return false;
		}
		if (!AfterDeactivate)
		{
			return false;
		}
		if (AfterReactivate)
		{
			return false;
		}
		return TestComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.ComponentActivation
	 * @Inputs this actor plus a second actor
	 * @Return true when this is reactivated and the other keeps its defaults
	 * @Param Second the other actor, expected to keep the declared defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageComponentActivationActor Second)
	{
		if (Second is null)
		{
			throw("ComponentActivation setup: required Second is null");
		}
		AfterReactivate = true;
		AfterDeactivate = false;

		if (!AfterReactivate)
		{
			return false;
		}
		if (AfterDeactivate)
		{
			return false;
		}
		if (Second.AfterReactivate)
		{
			return false;
		}
		return Second.AfterDeactivate;
	}
}
/** @end */
/**
 * @begin component-actor-multi-and-dynamic-lifecycle-ordering
 * @summary Root, child and later default components plus one runtime-created component, each recording the position at which its BeginPlay ran. C++ captures the default orders and creates the runtime probe, then compares the.
 * @topic Component
 */
/**
 * The root scene component, which records its BeginPlay position in the owner tag
 * order.
 *
 * @Covers Component.LifecycleOrdering
 * @Inputs none
 * @Return a scene component tagging "RootBeginPlay" on its owner
 */
UCLASS()
class UCoverageRootLifecycleComponent : USceneComponent
{
	UPROPERTY()
	int BeginPlayOrder = 0;

	/**
	 * WorldStory: tag the owner and record the position this BeginPlay took.
	 *
	 * @Kind WorldStory
	 * @Covers Component.LifecycleOrdering
	 * @Inputs the owning actor
	 * @Return BeginPlayOrder set to the owner tag count after appending
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AActor Owner = GetOwner();
		if (Owner != nullptr)
		{
			Owner.Tags.Add(n"RootBeginPlay");
			BeginPlayOrder = Owner.Tags.Num();
		}
	}
}

/**
 * The child scene component, attached under the root.
 *
 * @Covers Component.LifecycleOrdering
 * @Inputs none
 * @Return a scene component tagging "ChildBeginPlay" on its owner
 */
UCLASS()
class UCoverageChildLifecycleComponent : USceneComponent
{
	UPROPERTY()
	int BeginPlayOrder = 0;

	/**
	 * WorldStory: tag the owner and record the position this BeginPlay took.
	 *
	 * @Kind WorldStory
	 * @Covers Component.LifecycleOrdering
	 * @Inputs the owning actor
	 * @Return BeginPlayOrder set to the owner tag count after appending
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AActor Owner = GetOwner();
		if (Owner != nullptr)
		{
			Owner.Tags.Add(n"ChildBeginPlay");
			BeginPlayOrder = Owner.Tags.Num();
		}
	}
}

/**
 * A non-scene default component declared after the scene components.
 *
 * @Covers Component.LifecycleOrdering
 * @Inputs none
 * @Return an actor component tagging "LaterBeginPlay" on its owner
 */
UCLASS()
class UCoverageLaterLifecycleComponent : UActorComponent
{
	UPROPERTY()
	int BeginPlayOrder = 0;

	/**
	 * WorldStory: tag the owner and record the position this BeginPlay took.
	 *
	 * @Kind WorldStory
	 * @Covers Component.LifecycleOrdering
	 * @Inputs the owning actor
	 * @Return BeginPlayOrder set to the owner tag count after appending
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AActor Owner = GetOwner();
		if (Owner != nullptr)
		{
			Owner.Tags.Add(n"LaterBeginPlay");
			BeginPlayOrder = Owner.Tags.Num();
		}
	}
}

/**
 * The component created at runtime rather than declared as a default component.
 *
 * @Covers Component.LifecycleOrdering
 * @Inputs none
 * @Return an actor component tagging "DynamicBeginPlay" on its owner
 */
UCLASS()
class UCoverageDynamicLifecycleComponent : UActorComponent
{
	UPROPERTY()
	int BeginPlayOrder = 0;

	/**
	 * WorldStory: tag the owner and record the position this BeginPlay took.
	 *
	 * @Kind WorldStory
	 * @Covers Component.LifecycleOrdering
	 * @Inputs the owning actor
	 * @Return BeginPlayOrder set to the owner tag count after appending
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AActor Owner = GetOwner();
		if (Owner != nullptr)
		{
			Owner.Tags.Add(n"DynamicBeginPlay");
			BeginPlayOrder = Owner.Tags.Num();
		}
	}
}

UCLASS()
class ACoverageComponentMultiDynamicLifecycleActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UCoverageRootLifecycleComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UCoverageChildLifecycleComponent ChildProbe;

	UPROPERTY(DefaultComponent)
	UCoverageLaterLifecycleComponent LaterProbe;

	UPROPERTY()
	UCoverageDynamicLifecycleComponent DynamicProbe;

	UPROPERTY()
	int ActorBeginPlayOrder = 0;

	UPROPERTY()
	int RootBeginPlayOrder = 0;

	UPROPERTY()
	int ChildBeginPlayOrder = 0;

	UPROPERTY()
	int LaterBeginPlayOrder = 0;

	UPROPERTY()
	int DynamicBeginPlayOrder = 0;

	UPROPERTY()
	bool DynamicCreated = false;

	/**
	 * WorldStory: the actor tags itself last and records its own position.
	 *
	 * @Kind WorldStory
	 * @Covers Component.LifecycleOrdering
	 * @Inputs none
	 * @Return ActorBeginPlayOrder greater than 0
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Tags.Add(n"ActorBeginPlay");
		ActorBeginPlayOrder = Tags.Num();
	}

	/**
	 * Create the runtime probe component and record the BeginPlay position it took.
	 *
	 * @Kind Action
	 * @Covers Component.LifecycleOrdering
	 * @Inputs none
	 * @Return DynamicCreated set and DynamicBeginPlayOrder copied off the new probe
	 */
	UFUNCTION()
	void CreateRuntimeProbe()
	{
		DynamicProbe = UCoverageDynamicLifecycleComponent::Create(this, n"DynamicProbe");
		if (DynamicProbe == nullptr)
		{
			return;
		}

		DynamicCreated = true;
		DynamicBeginPlayOrder = DynamicProbe.BeginPlayOrder;
	}

	/**
	 * Copy the BeginPlay positions recorded by the three default components.
	 *
	 * @Kind Action
	 * @Covers Component.LifecycleOrdering
	 * @Inputs none
	 * @Return Root/Child/LaterBeginPlayOrder copied off their components
	 */
	UFUNCTION()
	void CaptureDefaultOrders()
	{
		RootBeginPlayOrder = Root.BeginPlayOrder;
		ChildBeginPlayOrder = ChildProbe.BeginPlayOrder;
		LaterBeginPlayOrder = LaterProbe.BeginPlayOrder;
	}
}
/** @end */
/**
 * @begin component-basic-declaration
 * @summary DefaultComponent declaration of a root, an attached child and a plain logic component. C++ verifies the four outcome flags by path. All flags stay false until BeginPlay runs.
 * @topic Component
 */
UCLASS()
class UCoverageBasicLogicComponent : UActorComponent
{
}

UCLASS()
class ACoverageComponentBasicActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child;

	UPROPERTY(DefaultComponent)
	UCoverageBasicLogicComponent LogicComponent;

	UPROPERTY()
	bool RootIsValid = false;

	UPROPERTY()
	bool ChildIsValid = false;

	UPROPERTY()
	bool ChildIsAttached = false;

	UPROPERTY()
	bool LogicComponentIsValid = false;

	/**
	 * WorldStory: BeginPlay records that all three components exist and that the
	 * child really is attached to the root.
	 *
	 * @Kind WorldStory
	 * @Covers Component.BasicDeclaration
	 * @Inputs three default components
	 * @Return all four flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RootIsValid = (Root != nullptr);
		ChildIsValid = (Child != nullptr);
		LogicComponentIsValid = (LogicComponent != nullptr);

		if (Child != nullptr && Root != nullptr)
		{
			ChildIsAttached = Child.IsAttachedTo(Root);
		}
	}
}
/** @end */
/**
 * @begin component-collision-event-dispatch
 * @summary A sphere component whose hit and overlap delegates are bound in BeginPlay, with each handler recording a count and whether the payload matched the values C++ broadcast. The observers cover the local-construct default and.
 * @topic Component
 */
UCLASS()
class ACoveragePhysicsComponentCollisionEventActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY()
	int ComponentHitCount = 0;

	UPROPERTY()
	int ComponentBeginOverlapCount = 0;

	UPROPERTY()
	int ComponentEndOverlapCount = 0;

	UPROPERTY()
	bool ComponentDelegatesBound = false;

	UPROPERTY()
	bool HitPayloadMatched = false;

	UPROPERTY()
	bool BeginOverlapPayloadMatched = false;

	UPROPERTY()
	bool EndOverlapPayloadMatched = false;

	/**
	 * WorldStory: enable collision and bind all three delegates on the sphere.
	 *
	 * @Kind WorldStory
	 * @Covers Component.CollisionEventDispatch
	 * @Inputs a default-attached USphereComponent
	 * @Return ComponentDelegatesBound true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Sphere.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		Sphere.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Block);
		Sphere.SetGenerateOverlapEvents(true);
		Sphere.SetNotifyRigidBodyCollision(true);

		Sphere.OnComponentHit.AddUFunction(this, n"OnComponentHitEvent");
		Sphere.OnComponentBeginOverlap.AddUFunction(this, n"OnComponentBeginOverlapEvent");
		Sphere.OnComponentEndOverlap.AddUFunction(this, n"OnComponentEndOverlapEvent");
		ComponentDelegatesBound = true;
	}

	/**
	 * Record a hit and whether every payload field matched what C++ broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Component.CollisionEventDispatch
	 * @Inputs the hit delegate payload
	 * @Return ComponentHitCount incremented; HitPayloadMatched set from the payload
	 * @Param HitComponent the component that was hit
	 * @Param OtherActor the other actor in the hit
	 * @Param OtherComp the other component in the hit
	 * @Param NormalImpulse the impulse, expected to be (0, 2, 0)
	 * @Param Hit the hit result, expected to be blocking at (10, 20, 30)
	 */
	UFUNCTION()
	void OnComponentHitEvent(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		ComponentHitCount += 1;
		HitPayloadMatched =
			HitComponent == Sphere
			&& OtherActor != nullptr
			&& OtherComp != nullptr
			&& Hit.GetbBlockingHit()
			&& NormalImpulse.Equals(FVector(0.0f, 2.0f, 0.0f), 0.01f)
			&& Hit.ImpactPoint.Equals(FVector(10.0f, 20.0f, 30.0f), 0.01f)
			&& Hit.BoneName == n"CoverageComponentHitBone";
	}

	/**
	 * Record a begin overlap and whether every payload field matched.
	 *
	 * @Kind EventHandler
	 * @Covers Component.CollisionEventDispatch
	 * @Inputs the begin overlap delegate payload
	 * @Return ComponentBeginOverlapCount incremented; BeginOverlapPayloadMatched set from the payload
	 * @Param OverlappedComponent the component that was overlapped
	 * @Param OtherActor the other actor in the overlap
	 * @Param OtherComp the other component in the overlap
	 * @Param OtherBodyIndex the body index, expected to be 17
	 * @Param bFromSweep whether the overlap came from a sweep, expected true
	 * @Param SweepResult the sweep result, expected blocking at (4, 5, 6)
	 */
	UFUNCTION()
	void OnComponentBeginOverlapEvent(UPrimitiveComponent OverlappedComponent, AActor OtherActor, UPrimitiveComponent OtherComp, int32 OtherBodyIndex, bool bFromSweep, const FHitResult&in SweepResult)
	{
		ComponentBeginOverlapCount += 1;
		BeginOverlapPayloadMatched =
			OverlappedComponent == Sphere
			&& OtherActor != nullptr
			&& OtherComp != nullptr
			&& OtherBodyIndex == 17
			&& bFromSweep
			&& SweepResult.GetbBlockingHit()
			&& SweepResult.Location.Equals(FVector(4.0f, 5.0f, 6.0f), 0.01f);
	}

	/**
	 * Record an end overlap and whether every payload field matched.
	 *
	 * @Kind EventHandler
	 * @Covers Component.CollisionEventDispatch
	 * @Inputs the end overlap delegate payload
	 * @Return ComponentEndOverlapCount incremented; EndOverlapPayloadMatched set from the payload
	 * @Param OverlappedComponent the component that was overlapped
	 * @Param OtherActor the other actor in the overlap
	 * @Param OtherComp the other component in the overlap
	 * @Param OtherBodyIndex the body index, expected to be 19
	 */
	UFUNCTION()
	void OnComponentEndOverlapEvent(UPrimitiveComponent OverlappedComponent, AActor OtherActor, UPrimitiveComponent OtherComp, int32 OtherBodyIndex)
	{
		ComponentEndOverlapCount += 1;
		EndOverlapPayloadMatched =
			OverlappedComponent == Sphere
			&& OtherActor != nullptr
			&& OtherComp != nullptr
			&& OtherBodyIndex == 19;
	}

	/**
	 * Observe that a locally constructed actor holds no counts and no matches.
	 *
	 * @Kind Observe
	 * @Covers Component.CollisionEventDispatch
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all counts are 0, all flags clear and Sphere is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ComponentHitCount != 0)
		{
			return false;
		}
		if (ComponentBeginOverlapCount != 0)
		{
			return false;
		}
		if (ComponentEndOverlapCount != 0)
		{
			return false;
		}
		if (ComponentDelegatesBound)
		{
			return false;
		}
		if (HitPayloadMatched)
		{
			return false;
		}
		if (BeginOverlapPayloadMatched)
		{
			return false;
		}
		if (EndOverlapPayloadMatched)
		{
			return false;
		}
		return Sphere == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.CollisionEventDispatch
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds one matched hit and the other holds none
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePhysicsComponentCollisionEventActor Second)
	{
		if (Second is null)
		{
			throw("ComponentCollisionEventDispatch setup: required Second is null");
		}
		ComponentHitCount = 1;
		HitPayloadMatched = true;

		if (ComponentHitCount != 1)
		{
			return false;
		}
		if (!HitPayloadMatched)
		{
			return false;
		}
		if (Second.ComponentHitCount != 0)
		{
			return false;
		}
		return !Second.HitPayloadMatched;
	}
}
/** @end */
/**
 * @begin component-destruction
 * @summary A component destroyed from the owning actor's Tick. C++ verifies WasDestroyed by path. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class UCoverageDestructionComponent : UActorComponent
{
}

UCLASS()
class ACoverageComponentDestructionActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageDestructionComponent TestComp;

	UPROPERTY()
	bool WasDestroyed = false;

	/**
	 * WorldStory: the first Tick destroys the component and records that it did.
	 *
	 * @Kind WorldStory
	 * @Covers Component.Destruction
	 * @Inputs the default-attached component
	 * @Return WasDestroyed true once the component has been destroyed
	 * @Param DeltaTime the frame delta, unused
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		if (TestComp != nullptr && !TestComp.IsBeingDestroyed())
		{
			TestComp.DestroyComponent();
			WasDestroyed = true;
		}
	}

	/**
	 * Observe that a locally constructed actor has not destroyed anything.
	 *
	 * @Kind Observe
	 * @Covers Component.Destruction
	 * @Inputs an actor that has not ticked
	 * @Return true when the flag is clear and TestComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (WasDestroyed)
		{
			return false;
		}
		return TestComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.Destruction
	 * @Inputs this actor plus a second actor
	 * @Return true when this is flagged and the other is not
	 * @Param Second the other actor, expected to stay unflagged
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageComponentDestructionActor Second)
	{
		if (Second is null)
		{
			throw("ComponentDestruction setup: required Second is null");
		}
		WasDestroyed = true;

		if (!WasDestroyed)
		{
			return false;
		}
		return !Second.WasDestroyed;
	}
}
/** @end */
/**
 * @begin component-destruction-callbacks-and-state
 * @summary A component whose EndPlay records the destruction state, driven by an explicit DestroyProbeComponent action on the owning actor. C++ verifies the two flags and the EndPlay count. The observers cover the local-construct.
 * @topic Component
 */
UCLASS()
class UCoverageDestroyStateComponent : UActorComponent
{
	UPROPERTY()
	int EndPlayCount = 0;

	UPROPERTY()
	bool DestroyingDuringEndPlay = false;

	/**
	 * WorldStory: EndPlay records that the component is already being destroyed.
	 *
	 * @Kind WorldStory
	 * @Covers Component.DestructionCallbacksAndState
	 * @Inputs the end play reason supplied by the engine
	 * @Return EndPlayCount incremented and DestroyingDuringEndPlay set from IsBeingDestroyed
	 * @Param EndPlayReason why the component is ending play
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		EndPlayCount++;
		DestroyingDuringEndPlay = IsBeingDestroyed();
	}
}

UCLASS()
class ACoverageComponentDestructionStateActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageDestroyStateComponent DestroyProbe;

	UPROPERTY()
	bool DestroyCallCompleted = false;

	UPROPERTY()
	bool BeingDestroyedAfterCall = false;

	/**
	 * Destroy the probe component and record the state it entered.
	 *
	 * @Kind Action
	 * @Covers Component.DestructionCallbacksAndState
	 * @Inputs none
	 * @Return DestroyCallCompleted and BeingDestroyedAfterCall set; both stay false when the probe is null
	 */
	UFUNCTION()
	void DestroyProbeComponent()
	{
		if (DestroyProbe == nullptr)
		{
			return;
		}

		DestroyProbe.DestroyComponent();
		DestroyCallCompleted = true;
		BeingDestroyedAfterCall = DestroyProbe.IsBeingDestroyed();
	}

	/**
	 * Observe that a locally constructed actor has not destroyed anything.
	 *
	 * @Kind Observe
	 * @Covers Component.DestructionCallbacksAndState
	 * @Inputs an actor that has not run the destroy action
	 * @Return true when both flags are clear and DestroyProbe is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (DestroyCallCompleted)
		{
			return false;
		}
		if (BeingDestroyedAfterCall)
		{
			return false;
		}
		return DestroyProbe == nullptr;
	}

	/**
	 * Observe that the destroy action is a no-op without a probe component.
	 *
	 * @Kind Observe
	 * @Covers Component.DestructionCallbacksAndState
	 * @Inputs an actor whose probe component is null
	 * @Return true when both flags stay clear after the call
	 * @Boundary null probe
	 */
	UFUNCTION()
	bool NullProbeIsNoop()
	{
		DestroyProbeComponent();

		if (DestroyCallCompleted)
		{
			return false;
		}
		return !BeingDestroyedAfterCall;
	}
}
/** @end */
/**
 * @begin component-finding
 * @summary GetComponentByClass and GetComponentsByClass over a root, two attached scene children and one plain logic component. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this actor and verifies the results by.
 * @topic Component
 */
UCLASS()
class UCoverageFindingLogicComponent : UActorComponent
{
}

UCLASS()
class ACoverageComponentFindingActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child1;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child2;

	UPROPERTY(DefaultComponent)
	UCoverageFindingLogicComponent LogicComp;

	UPROPERTY()
	bool FoundSingleComponent = false;

	UPROPERTY()
	int SceneComponentCount = 0;

	/**
	 * WorldStory: BeginPlay resolves one arbitrary component and counts the scene
	 * components.
	 *
	 * @Kind WorldStory
	 * @Covers Component.Finding
	 * @Inputs four default components
	 * @Return FoundSingleComponent true and SceneComponentCount == 3
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UActorComponent FoundComp = GetComponentByClass(UActorComponent::StaticClass());
		FoundSingleComponent = (FoundComp != nullptr);

		TArray<USceneComponent> SceneComps;
		GetComponentsByClass(USceneComponent::StaticClass(), SceneComps);
		SceneComponentCount = SceneComps.Num();
	}

	/**
	 * Observe that a locally constructed actor found nothing and has no components.
	 *
	 * @Kind Observe
	 * @Covers Component.Finding
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the flag is clear, the count is 0 and all four handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (FoundSingleComponent)
		{
			return false;
		}
		if (SceneComponentCount != 0)
		{
			return false;
		}
		if (Root != nullptr)
		{
			return false;
		}
		if (Child1 != nullptr)
		{
			return false;
		}
		if (Child2 != nullptr)
		{
			return false;
		}
		return LogicComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.Finding
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the found state and the other holds nothing
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageComponentFindingActor Second)
	{
		if (Second is null)
		{
			throw("ComponentFinding setup: required Second is null");
		}
		FoundSingleComponent = true;
		SceneComponentCount = 3;

		if (!FoundSingleComponent)
		{
			return false;
		}
		if (SceneComponentCount != 3)
		{
			return false;
		}
		if (Second.FoundSingleComponent)
		{
			return false;
		}
		return Second.SceneComponentCount == 0;
	}
}
/** @end */
/**
 * @begin component-finding-by-class-and-tag
 * @summary Component lookup by class and by tag across a base/derived component pair. C++ verifies the found flag and the three counts. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class UCoverageFindBaseComponent : UActorComponent
{
}

/**
 * The derived component that the base-class lookup must also resolve.
 *
 * @Covers Component.FindingByClassAndTag
 * @Inputs none
 * @Return a component derived from UCoverageFindBaseComponent
 */
UCLASS()
class UCoverageFindDerivedComponent : UCoverageFindBaseComponent
{
}

UCLASS()
class ACoverageComponentFindingByClassAndTagActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageFindDerivedComponent DerivedA;

	UPROPERTY(DefaultComponent)
	UCoverageFindDerivedComponent DerivedB;

	UPROPERTY()
	bool GetComponentByClassFound = false;

	UPROPERTY()
	int TaggedComponentCount = 0;

	UPROPERTY()
	int TaggedQueryCount = 0;

	UPROPERTY()
	int DerivedComponentCount = 0;

	/**
	 * WorldStory: BeginPlay tags both derived components, resolves one by the base
	 * class, then counts tagged components two different ways and counts the
	 * derived components.
	 *
	 * @Kind WorldStory
	 * @Covers Component.FindingByClassAndTag
	 * @Inputs two default-attached derived components
	 * @Return GetComponentByClassFound true, TaggedComponentCount 2, TaggedQueryCount 2, DerivedComponentCount 2
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DerivedA.ComponentTags.Add(n"CoverageTag");
		DerivedB.ComponentTags.Add(n"CoverageTag");

		UActorComponent FoundBase = GetComponentByClass(UCoverageFindBaseComponent::StaticClass());
		GetComponentByClassFound = FoundBase != nullptr;

		TArray<UActorComponent> AllComponents;
		GetComponentsByClass(UActorComponent::StaticClass(), AllComponents);
		for (UActorComponent Component : AllComponents)
		{
			if (Component.ComponentHasTag(n"CoverageTag"))
			{
				TaggedComponentCount++;
			}
		}

		TArray<UActorComponent> TaggedComponents = GetComponentsByTag(UActorComponent::StaticClass(), n"CoverageTag");
		TaggedQueryCount = TaggedComponents.Num();

		TArray<UCoverageFindDerivedComponent> DerivedComponents;
		GetComponentsByClass(UCoverageFindDerivedComponent::StaticClass(), DerivedComponents);
		DerivedComponentCount = DerivedComponents.Num();
	}

	/**
	 * Observe that a locally constructed actor found nothing and has no handles.
	 *
	 * @Kind Observe
	 * @Covers Component.FindingByClassAndTag
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the flag is clear, all counts are 0 and both handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (GetComponentByClassFound)
		{
			return false;
		}
		if (TaggedComponentCount != 0)
		{
			return false;
		}
		if (TaggedQueryCount != 0)
		{
			return false;
		}
		if (DerivedComponentCount != 0)
		{
			return false;
		}
		if (DerivedA != nullptr)
		{
			return false;
		}
		return DerivedB == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.FindingByClassAndTag
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the found state and the other holds nothing
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageComponentFindingByClassAndTagActor Second)
	{
		if (Second is null)
		{
			throw("ComponentFindingByClassAndTag setup: required Second is null");
		}
		GetComponentByClassFound = true;
		TaggedComponentCount = 2;

		if (!GetComponentByClassFound)
		{
			return false;
		}
		if (TaggedComponentCount != 2)
		{
			return false;
		}
		if (Second.GetComponentByClassFound)
		{
			return false;
		}
		return Second.TaggedComponentCount == 0;
	}
}
/** @end */
/**
 * @begin component-lifecycle
 * @summary A component walking BeginPlay, Tick and EndPlay. C++ verifies LifecycleStage 2 and TickCount 2 by path. The CSV marks this NegativeDiagnostic, but the method is a lifecycle oracle rather than a compile failure: the.
 * @topic Component
 */
UCLASS()
class ULifecycleTestComponent : UActorComponent
{
	UPROPERTY()
	int LifecycleStage = 0;

	UPROPERTY()
	int TickCount = 0;

	/**
	 * WorldStory: BeginPlay advances the stage from 0 to 2.
	 *
	 * @Kind WorldStory
	 * @Covers Component.Lifecycle
	 * @Inputs none
	 * @Return LifecycleStage == 2
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		LifecycleStage = 2;
	}

	/**
	 * WorldStory: each Tick past BeginPlay increments the tick count.
	 *
	 * @Kind WorldStory
	 * @Covers Component.Lifecycle
	 * @Inputs the frame delta, unused
	 * @Return TickCount incremented once per tick while the stage is 2
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		if (LifecycleStage == 2)
		{
			TickCount++;
		}
	}

	/**
	 * WorldStory: EndPlay advances the stage from 2 to 3.
	 *
	 * @Kind WorldStory
	 * @Covers Component.Lifecycle
	 * @Inputs the end play reason supplied by the engine
	 * @Return LifecycleStage == 3
	 * @Param EndPlayReason why the component is ending play
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		if (LifecycleStage == 2)
		{
			LifecycleStage = 3;
		}
	}
}

/**
 * The actor that hosts the lifecycle component as a default component.
 *
 * @Covers Component.Lifecycle
 * @Inputs none
 * @Return an actor carrying one ULifecycleTestComponent
 */
UCLASS()
class ACoverageComponentLifecycleActor : AActor
{
	UPROPERTY(DefaultComponent)
	ULifecycleTestComponent TestComp;
}
/** @end */
/**
 * @begin component-lifecycle-ordering
 * @summary Component BeginPlay and EndPlay each claim an incrementing order token, so C++ can compare them against the actor BeginPlay. C++ verifies that the owner was visible during BeginPlay and that both orders are greater than.
 * @topic Component
 */
UCLASS()
class UCoverageLifecycleOrderComponent : UActorComponent
{
	UPROPERTY()
	int NextOrder = 0;

	UPROPERTY()
	int BeginPlayOrder = 0;

	UPROPERTY()
	int EndPlayOrder = 0;

	UPROPERTY()
	bool bSawOwnerDuringBeginPlay = false;

	/**
	 * Claim the next order token.
	 *
	 * @Kind Helper
	 * @Covers Component.LifecycleOrdering
	 * @Inputs none
	 * @Return the next order token, starting at 1
	 */
	int ClaimOrder()
	{
		NextOrder++;
		return NextOrder;
	}

	/**
	 * WorldStory: BeginPlay claims an order token and records that the owner was
	 * already available.
	 *
	 * @Kind WorldStory
	 * @Covers Component.LifecycleOrdering
	 * @Inputs none
	 * @Return BeginPlayOrder > 0 and bSawOwnerDuringBeginPlay true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayOrder = ClaimOrder();
		bSawOwnerDuringBeginPlay = GetOwner() != nullptr;
	}

	/**
	 * WorldStory: EndPlay claims the following order token.
	 *
	 * @Kind WorldStory
	 * @Covers Component.LifecycleOrdering
	 * @Inputs the end play reason supplied by the engine
	 * @Return EndPlayOrder > 0
	 * @Param EndPlayReason why the component is ending play
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		EndPlayOrder = ClaimOrder();
	}
}

UCLASS()
class ACoverageComponentLifecycleOrderingActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent)
	UCoverageLifecycleOrderComponent Probe;

	UPROPERTY()
	int ActorBeginPlayOrder = 0;

	/**
	 * WorldStory: the actor BeginPlay records its own position in the ordering.
	 *
	 * @Kind WorldStory
	 * @Covers Component.LifecycleOrdering
	 * @Inputs none
	 * @Return ActorBeginPlayOrder == 1 and the "ActorBeginPlayRan" tag appended
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ActorBeginPlayOrder = 1;
		Tags.Add(n"ActorBeginPlayRan");
	}
}
/** @end */
/**
 * @begin component-manual-new-object-registration
 * @summary A component built with NewObject rather than declared as a default component, then tagged, activated, deactivated and called through a custom method. C++ verifies every flag. The observers cover the local-construct.
 * @topic Component
 */
UCLASS()
class UCoverageManualNewObjectComponent : UActorComponent
{
	UPROPERTY()
	int BaseValue = 29;

	/**
	 * Add an extra value onto the base value.
	 *
	 * @Kind Action
	 * @Covers Component.ManualNewObjectRegistration
	 * @Inputs an extra value to add
	 * @Return BaseValue + ExtraValue
	 * @Param ExtraValue the amount to add
	 */
	UFUNCTION()
	int AddValue(int ExtraValue)
	{
		return BaseValue + ExtraValue;
	}

	/**
	 * Observe that adding zero returns the base value unchanged.
	 *
	 * @Kind Observe
	 * @Covers Component.ManualNewObjectRegistration
	 * @Inputs a component whose BaseValue is 29
	 * @Return AddValue(0)
	 * @Boundary zero extra value
	 */
	UFUNCTION()
	int AddValueZeroBoundary()
	{
		return AddValue(0);
	}
}

UCLASS()
class ACoverageComponentManualNewObjectActor : AActor
{
	UPROPERTY()
	UCoverageManualNewObjectComponent ManualComp;

	UPROPERTY()
	bool NewObjectCreated = false;

	UPROPERTY()
	bool OwnerBeforeRegisterMatched = false;

	UPROPERTY()
	bool WorldBeforeRegisterMatched = false;

	UPROPERTY()
	bool TaggedAfterRegister = false;

	UPROPERTY()
	bool ActiveAfterActivate = false;

	UPROPERTY()
	bool InactiveAfterDeactivate = false;

	UPROPERTY()
	int CustomMethodValue = 0;

	/**
	 * WorldStory: build the component with NewObject, then walk tags, activation
	 * and the custom method.
	 *
	 * @Kind WorldStory
	 * @Covers Component.ManualNewObjectRegistration
	 * @Inputs none
	 * @Return all flags true and CustomMethodValue == 42; all stay false when NewObject fails
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ManualComp = Cast<UCoverageManualNewObjectComponent>(NewObject(this, UCoverageManualNewObjectComponent::StaticClass(), n"ManualNewObjectComp", true));
		NewObjectCreated = ManualComp != nullptr;
		if (ManualComp == nullptr)
		{
			return;
		}

		OwnerBeforeRegisterMatched = ManualComp.GetOwner() == this;
		WorldBeforeRegisterMatched = ManualComp.GetWorld() == GetWorld();
		ManualComp.ComponentTags.Add(n"ManualNewObject");

		TaggedAfterRegister = ManualComp.ComponentHasTag(n"ManualNewObject");

		ManualComp.Activate(true);
		ActiveAfterActivate = ManualComp.IsActive();

		ManualComp.Deactivate();
		InactiveAfterDeactivate = !ManualComp.IsActive();

		CustomMethodValue = ManualComp.AddValue(13);
	}

	/**
	 * Observe that a locally constructed actor has no component and no flags set.
	 *
	 * @Kind Observe
	 * @Covers Component.ManualNewObjectRegistration
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when ManualComp is null, all flags are clear and the value is 0
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultNull()
	{
		if (ManualComp != nullptr)
		{
			return false;
		}
		if (NewObjectCreated)
		{
			return false;
		}
		if (OwnerBeforeRegisterMatched)
		{
			return false;
		}
		if (WorldBeforeRegisterMatched)
		{
			return false;
		}
		if (TaggedAfterRegister)
		{
			return false;
		}
		if (ActiveAfterActivate)
		{
			return false;
		}
		if (InactiveAfterDeactivate)
		{
			return false;
		}
		return CustomMethodValue == 0;
	}
}
/** @end */
/**
 * @begin component-registration-and-activation
 * @summary A component created at runtime with Create, then activated and deactivated. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this actor and verifies the flags by path, so this is a value oracle. The.
 * @topic Component
 */
UCLASS()
class UCoverageRuntimeLogicComponent : UActorComponent
{
	UPROPERTY()
	int Value = 17;
}

UCLASS()
class ACoverageComponentRegistrationActivationActor : AActor
{
	UPROPERTY()
	UCoverageRuntimeLogicComponent RuntimeComp;

	UPROPERTY()
	bool RegisteredAfterCreate = false;

	UPROPERTY()
	bool ActiveAfterActivate = false;

	UPROPERTY()
	bool InactiveAfterDeactivate = false;

	UPROPERTY()
	bool OwnerMatched = false;

	UPROPERTY()
	bool WorldMatched = false;

	/**
	 * WorldStory: create the component at runtime, walk activation, then confirm
	 * the owner and world it landed in.
	 *
	 * @Kind WorldStory
	 * @Covers Component.RegistrationAndActivation
	 * @Inputs none
	 * @Return all five flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RuntimeComp = UCoverageRuntimeLogicComponent::Create(this, n"RuntimeComp");
		RegisteredAfterCreate = RuntimeComp != nullptr;

		RuntimeComp.Activate(true);
		ActiveAfterActivate = RuntimeComp.IsActive();

		RuntimeComp.Deactivate();
		InactiveAfterDeactivate = !RuntimeComp.IsActive();

		OwnerMatched = RuntimeComp.GetOwner() == this;
		WorldMatched = RuntimeComp.GetWorld() == GetWorld();
	}

	/**
	 * Observe that a locally constructed actor has no component and no flags set.
	 *
	 * @Kind Observe
	 * @Covers Component.RegistrationAndActivation
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when RuntimeComp is null and all flags are clear
	 * @Boundary null runtime component
	 */
	UFUNCTION()
	bool DefaultNull()
	{
		if (RuntimeComp != nullptr)
		{
			return false;
		}
		if (RegisteredAfterCreate)
		{
			return false;
		}
		if (ActiveAfterActivate)
		{
			return false;
		}
		if (InactiveAfterDeactivate)
		{
			return false;
		}
		if (OwnerMatched)
		{
			return false;
		}
		return !WorldMatched;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.RegistrationAndActivation
	 * @Inputs this actor plus a second actor
	 * @Return true when this is flagged and the other stays null and unflagged
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageComponentRegistrationActivationActor Second)
	{
		if (Second is null)
		{
			throw("ComponentRegistrationAndActivation setup: required Second is null");
		}
		RegisteredAfterCreate = true;

		if (!RegisteredAfterCreate)
		{
			return false;
		}
		if (Second.RegisteredAfterCreate)
		{
			return false;
		}
		return Second.RuntimeComp == nullptr;
	}
}
/** @end */
/**
 * @begin component-runtime-tick-interval-control
 * @summary Component tick interval and enable state driven at runtime. C++ verifies the flags and the three intervals. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class UCoverageRuntimeTickIntervalComponent : UActorComponent
{
	UPROPERTY()
	int TickCount = 0;

	/**
	 * Count every tick the component receives.
	 *
	 * @Kind WorldStory
	 * @Covers Component.RuntimeTickIntervalControl
	 * @Inputs the frame delta, unused
	 * @Return TickCount incremented once per tick
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		TickCount++;
	}
}

UCLASS()
class ACoverageComponentRuntimeTickIntervalActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageRuntimeTickIntervalComponent TickComp;

	UPROPERTY()
	bool InitiallyDisabled = false;

	UPROPERTY()
	bool EnabledAfterToggle = false;

	UPROPERTY()
	bool DisabledAfterToggle = false;

	UPROPERTY()
	float InitialInterval = 0.0f;

	UPROPERTY()
	float UpdatedInterval = 0.0f;

	UPROPERTY()
	float SecondUpdatedInterval = 0.0f;

	/**
	 * WorldStory: BeginPlay reads the starting state, moves the interval twice, then
	 * re-enables ticking.
	 *
	 * @Kind WorldStory
	 * @Covers Component.RuntimeTickIntervalControl
	 * @Inputs a default-attached ticking component
	 * @Return InitiallyDisabled false, EnabledAfterToggle true, intervals ~0.125 then 0.25 then 0.05
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitiallyDisabled = !TickComp.IsComponentTickEnabled();
		InitialInterval = TickComp.GetComponentTickInterval();

		TickComp.SetComponentTickInterval(0.25f);
		UpdatedInterval = TickComp.GetComponentTickInterval();

		TickComp.SetComponentTickInterval(0.05f);
		SecondUpdatedInterval = TickComp.GetComponentTickInterval();

		TickComp.SetComponentTickEnabled(true);
		EnabledAfterToggle = TickComp.IsComponentTickEnabled();
	}

	/**
	 * Disable ticking at runtime and record that it took effect.
	 *
	 * @Kind Action
	 * @Covers Component.RuntimeTickIntervalControl
	 * @Inputs none
	 * @Return DisabledAfterToggle set from the tick-enabled state after disabling
	 */
	UFUNCTION()
	void DisableRuntimeTick()
	{
		TickComp.SetComponentTickEnabled(false);
		DisabledAfterToggle = !TickComp.IsComponentTickEnabled();
	}

	/**
	 * Observe that a locally constructed actor has no intervals and no flags set.
	 *
	 * @Kind Observe
	 * @Covers Component.RuntimeTickIntervalControl
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all flags are clear, all intervals are 0 and TickComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (InitiallyDisabled)
		{
			return false;
		}
		if (EnabledAfterToggle)
		{
			return false;
		}
		if (DisabledAfterToggle)
		{
			return false;
		}
		if (InitialInterval != 0.0f)
		{
			return false;
		}
		if (UpdatedInterval != 0.0f)
		{
			return false;
		}
		if (SecondUpdatedInterval != 0.0f)
		{
			return false;
		}
		return TickComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.RuntimeTickIntervalControl
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the toggled state and the other stays at zero
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageComponentRuntimeTickIntervalActor Second)
	{
		if (Second is null)
		{
			throw("ComponentRuntimeTickIntervalControl setup: required Second is null");
		}
		EnabledAfterToggle = true;
		UpdatedInterval = 0.25f;

		if (!EnabledAfterToggle)
		{
			return false;
		}
		if (UpdatedInterval != 0.25f)
		{
			return false;
		}
		if (Second.EnabledAfterToggle)
		{
			return false;
		}
		return Second.UpdatedInterval == 0.0f;
	}
}
/** @end */
/**
 * @begin component-special-type-declarations
 * @summary Arrow, audio and input components declared as default components. C++ reads the validity flags by path. All flags stay false until BeginPlay runs.
 * @topic Component
 */
UCLASS()
class ACoverageComponentSpecialTypeActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UArrowComponent Arrow;

	UPROPERTY(DefaultComponent, Attach=Root)
	UAudioComponent Audio;

	UPROPERTY(DefaultComponent)
	UInputComponent Input;

	UPROPERTY()
	bool ArrowValid = false;

	UPROPERTY()
	bool AudioValid = false;

	UPROPERTY()
	bool InputValid = false;

	UPROPERTY()
	bool SceneTypesAttached = false;

	/**
	 * WorldStory: BeginPlay records which default components resolved and whether
	 * both scene types ended up attached to the root.
	 *
	 * @Kind WorldStory
	 * @Covers Component.SpecialTypeDeclarations
	 * @Inputs four default components
	 * @Return all four flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ArrowValid = Arrow != nullptr;
		AudioValid = Audio != nullptr;
		InputValid = Input != nullptr;
		SceneTypesAttached = ArrowValid && AudioValid && Arrow.IsAttachedTo(Root) && Audio.IsAttachedTo(Root);
	}
}
/** @end */
/**
 * @begin component-tags
 * @summary ComponentTags.Add followed by ComponentHasTag and a tag count. C++ verifies the three results by path. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class UCoverageTagsComponent : UActorComponent
{
}

UCLASS()
class ACoverageComponentTagsActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageTagsComponent TestComp;

	UPROPERTY()
	bool HasTestTag = false;

	UPROPERTY()
	bool HasOtherTag = false;

	UPROPERTY()
	int TagCount = 0;

	/**
	 * WorldStory: BeginPlay adds two tags, then queries one present tag, one absent
	 * tag and the resulting count.
	 *
	 * @Kind WorldStory
	 * @Covers Component.Tags
	 * @Inputs a default-attached component
	 * @Return HasTestTag true, HasOtherTag false, TagCount == 2
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TestComp.ComponentTags.Add(n"TestTag");
		TestComp.ComponentTags.Add(n"AnotherTag");

		HasTestTag = TestComp.ComponentHasTag(n"TestTag");
		HasOtherTag = TestComp.ComponentHasTag(n"OtherTag");
		TagCount = TestComp.ComponentTags.Num();
	}

	/**
	 * Observe that a locally constructed actor holds no tags and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.Tags
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both flags are clear, the count is 0 and TestComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (HasTestTag)
		{
			return false;
		}
		if (HasOtherTag)
		{
			return false;
		}
		if (TagCount != 0)
		{
			return false;
		}
		return TestComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.Tags
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the tagged state and the other stays at its defaults
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageComponentTagsActor Second)
	{
		if (Second is null)
		{
			throw("ComponentTags setup: required Second is null");
		}
		HasTestTag = true;
		TagCount = 2;

		if (!HasTestTag)
		{
			return false;
		}
		if (TagCount != 2)
		{
			return false;
		}
		if (Second.HasTestTag)
		{
			return false;
		}
		if (Second.TagCount != 0)
		{
			return false;
		}
		return !Second.HasOtherTag;
	}
}
/** @end */
/**
 * @begin component-tick-configuration-and-prerequisites
 * @summary Tick prerequisites added and removed against both a component and an actor, alongside the starting tick-enabled state. C++ verifies the four flags and then sets the interval and tick group itself. The observers cover the.
 * @topic Component
 */
UCLASS()
class UCoverageTickConfigComponent : UActorComponent
{
	UPROPERTY()
	int TickCount = 0;

	/**
	 * Count every tick the component receives.
	 *
	 * @Kind WorldStory
	 * @Covers Component.TickConfigurationAndPrerequisites
	 * @Inputs the frame delta, unused
	 * @Return TickCount incremented once per tick
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		TickCount++;
	}
}

UCLASS()
class UCoverageTickDisabledComponent : UActorComponent
{
}

UCLASS()
class ACoverageComponentTickConfigurationActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageTickConfigComponent TickComp;

	UPROPERTY(DefaultComponent)
	UCoverageTickDisabledComponent DisabledComp;

	UPROPERTY()
	bool StartTickEnabled = false;

	UPROPERTY()
	bool ComponentPrereqAdded = false;

	UPROPERTY()
	bool ActorPrereqAdded = false;

	UPROPERTY()
	bool ComponentPrereqRemoved = false;

	/**
	 * WorldStory: BeginPlay records the starting tick state, adds a component and an
	 * actor prerequisite, then removes the component prerequisite again.
	 *
	 * @Kind WorldStory
	 * @Covers Component.TickConfigurationAndPrerequisites
	 * @Inputs two default components
	 * @Return all four flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		StartTickEnabled = TickComp.IsComponentTickEnabled();

		TickComp.AddTickPrerequisiteComponent(DisabledComp);
		ComponentPrereqAdded = true;

		TickComp.AddTickPrerequisiteActor(this);
		ActorPrereqAdded = true;

		TickComp.RemoveTickPrerequisiteComponent(DisabledComp);
		ComponentPrereqRemoved = true;
	}

	/**
	 * Observe that a locally constructed actor has no flags and no components.
	 *
	 * @Kind Observe
	 * @Covers Component.TickConfigurationAndPrerequisites
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all flags are clear and both components are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (StartTickEnabled)
		{
			return false;
		}
		if (ComponentPrereqAdded)
		{
			return false;
		}
		if (ActorPrereqAdded)
		{
			return false;
		}
		if (ComponentPrereqRemoved)
		{
			return false;
		}
		if (TickComp != nullptr)
		{
			return false;
		}
		return DisabledComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.TickConfigurationAndPrerequisites
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the flags and the other stays clear
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageComponentTickConfigurationActor Second)
	{
		if (Second is null)
		{
			throw("ComponentTickConfigurationAndPrerequisites setup: required Second is null");
		}
		StartTickEnabled = true;
		ComponentPrereqAdded = true;

		if (!StartTickEnabled)
		{
			return false;
		}
		if (!ComponentPrereqAdded)
		{
			return false;
		}
		if (Second.StartTickEnabled)
		{
			return false;
		}
		return !Second.ComponentPrereqAdded;
	}
}
/** @end */
/**
 * @begin component-tick-control
 * @summary Component ticking disabled once the component has ticked three times. C++ verifies DisableTickCount 2 by path. Nothing is recorded until BeginPlay and Tick have run.
 * @topic Component
 */
UCLASS()
class UTickControlComponent : UActorComponent
{
	UPROPERTY()
	int TickCount = 0;

	UPROPERTY()
	float AccumulatedTime = 0.0f;

	/**
	 * Count every tick and accumulate the elapsed time.
	 *
	 * @Kind WorldStory
	 * @Covers Component.TickControl
	 * @Inputs the frame delta
	 * @Return TickCount incremented and AccumulatedTime grown by the delta
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		TickCount++;
		AccumulatedTime += DeltaTime;
	}
}

UCLASS()
class ACoverageComponentTickControlActor : AActor
{
	UPROPERTY(DefaultComponent)
	UTickControlComponent TestComp;

	UPROPERTY()
	int DisableTickCount = 0;

	/**
	 * WorldStory: BeginPlay records that the component still has ticking enabled.
	 *
	 * @Kind WorldStory
	 * @Covers Component.TickControl
	 * @Inputs a default-attached ticking component
	 * @Return DisableTickCount == 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (TestComp.IsComponentTickEnabled())
		{
			DisableTickCount = 1;
		}
	}

	/**
	 * WorldStory: once the component has ticked three times, disable its ticking.
	 *
	 * @Kind WorldStory
	 * @Covers Component.TickControl
	 * @Inputs the frame delta, unused
	 * @Return DisableTickCount == 2 once the component has been switched off
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		if (TestComp.TickCount >= 3 && DisableTickCount == 1)
		{
			TestComp.SetComponentTickEnabled(false);
			DisableTickCount = 2;
		}
	}
}
/** @end */
/**
 * @begin component-tick-dispatch-is-exact
 * @summary A component Tick override counted across an exact number of direct dispatches. C++ dispatches four ticks and compares the count against its expected value. The observers cover the local-construct defaults and copy.
 * @topic Component
 */
UCLASS()
class UTestComponentLifecycleExactTickProbe : UActorComponent
{
	UPROPERTY()
	int TickCount = 0;

	/**
	 * Count every tick dispatch.
	 *
	 * @Kind WorldStory
	 * @Covers Component.TickDispatchIsExact
	 * @Inputs the frame delta, unused
	 * @Return TickCount incremented once per dispatch
	 * @Param DeltaSeconds the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCount += 1;
	}

	/**
	 * Observe that a locally constructed probe has not ticked.
	 *
	 * @Kind Observe
	 * @Covers Component.TickDispatchIsExact
	 * @Inputs a probe that has not been dispatched
	 * @Return true when TickCount is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool ProbeDefaultZero()
	{
		return TickCount == 0;
	}

	/**
	 * Observe that writing this probe leaves another probe untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.TickDispatchIsExact
	 * @Inputs this probe plus a second probe
	 * @Return true when this counts 4 and the other stays at 0
	 * @Param Second the other probe, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UTestComponentLifecycleExactTickProbe Second)
	{
		if (Second is null)
		{
			throw("ComponentTickDispatchIsExact setup: required Second is null");
		}
		TickCount = 4;

		if (TickCount != 4)
		{
			return false;
		}
		return Second.TickCount == 0;
	}
}

UCLASS()
class ATestComponentLifecycleExactTick : AActor
{
	UPROPERTY(DefaultComponent)
	UTestComponentLifecycleExactTickProbe Probe;

	/**
	 * Observe that a locally constructed actor has no probe component.
	 *
	 * @Kind Observe
	 * @Covers Component.TickDispatchIsExact
	 * @Inputs an actor that has not been spawned
	 * @Return true when Probe is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		return Probe == nullptr;
	}
}
/** @end */
/**
 * @begin create-component
 * @summary CreateComponent returning named scene and billboard components to C++. The entrypoint names are part of the C++ contract and are kept verbatim, including the lookup with a deliberately wrong type. The observer covers the.
 * @topic Component
 */
UCLASS()
class ATestActorCreateComponent : AActor
{
	/**
	 * Create the dynamic root scene component for C++.
	 *
	 * @Kind Action
	 * @Covers Component.CreateComponent
	 * @Inputs none
	 * @Return the new scene component named DynamicRoot
	 */
	UFUNCTION()
	USceneComponent CreateDynamicRootForCpp()
	{
		return Cast<USceneComponent>(CreateComponent(USceneComponent::StaticClass(), n"DynamicRoot"));
	}

	/**
	 * Create the dynamic child scene component for C++.
	 *
	 * @Kind Action
	 * @Covers Component.CreateComponent
	 * @Inputs none
	 * @Return the new scene component named DynamicChild
	 */
	UFUNCTION()
	USceneComponent CreateDynamicChildForCpp()
	{
		return Cast<USceneComponent>(CreateComponent(USceneComponent::StaticClass(), n"DynamicChild"));
	}

	/**
	 * Create the dynamic billboard component for C++.
	 *
	 * @Kind Action
	 * @Covers Component.CreateComponent
	 * @Inputs none
	 * @Return the new billboard component named DynamicBillboard
	 */
	UFUNCTION()
	UBillboardComponent CreateDynamicBillboardForCpp()
	{
		return Cast<UBillboardComponent>(CreateComponent(UBillboardComponent::StaticClass(), n"DynamicBillboard"));
	}

	/**
	 * Create another named scene component for C++.
	 *
	 * @Kind Action
	 * @Covers Component.CreateComponent
	 * @Inputs none
	 * @Return the new scene component named CppReturnedNamedScene
	 */
	UFUNCTION()
	USceneComponent CreateNamedSceneForCpp()
	{
		return Cast<USceneComponent>(CreateComponent(USceneComponent::StaticClass(), n"CppReturnedNamedScene"));
	}

	/**
	 * Look up the dynamic root by name for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.CreateComponent
	 * @Inputs none
	 * @Return the component named DynamicRoot, or null before it is created
	 */
	UFUNCTION()
	UActorComponent FindDynamicRootForCpp()
	{
		return GetComponent(USceneComponent::StaticClass(), n"DynamicRoot");
	}

	/**
	 * Look up the dynamic billboard by name for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.CreateComponent
	 * @Inputs none
	 * @Return the component named DynamicBillboard, or null before it is created
	 */
	UFUNCTION()
	UActorComponent FindDynamicBillboardForCpp()
	{
		return GetComponent(UBillboardComponent::StaticClass(), n"DynamicBillboard");
	}

	/**
	 * Look up the dynamic billboard under a type it does not have, which must not
	 * resolve.
	 *
	 * @Kind Observe
	 * @Covers Component.CreateComponent
	 * @Inputs none
	 * @Return null, even after the billboard has been created
	 * @Boundary wrong type lookup
	 */
	UFUNCTION()
	UActorComponent FindDynamicBillboardAsWrongTypeForCpp()
	{
		return GetComponent(UStaticMeshComponent::StaticClass(), n"DynamicBillboard");
	}

	/**
	 * Observe that nothing resolves before any component has been created.
	 *
	 * @Kind Observe
	 * @Covers Component.CreateComponent
	 * @Inputs an actor on which no Create* entrypoint has run
	 * @Return true when all three lookups return null
	 * @Boundary create not yet called
	 */
	UFUNCTION()
	bool DefaultMissingNull()
	{
		if (FindDynamicRootForCpp() != nullptr)
		{
			return false;
		}
		if (FindDynamicBillboardForCpp() != nullptr)
		{
			return false;
		}
		return FindDynamicBillboardAsWrongTypeForCpp() == nullptr;
	}
}
/** @end */
/**
 * @begin custom-script-component
 * @summary A script-derived actor component carrying a value, a name and a doubling method. C++ reads the retrieved value, name and doubled value by path. The observers cover the local-construct default and the doubling method at.
 * @topic Component
 */
UCLASS()
class UCustomLogicComponent : UActorComponent
{
	UPROPERTY()
	int CustomValue = 42;

	UPROPERTY()
	FString CustomName = "TestComponent";

	/**
	 * Double the custom value.
	 *
	 * @Kind Action
	 * @Covers Component.CustomScriptComponent
	 * @Inputs none
	 * @Return CustomValue * 2
	 */
	UFUNCTION()
	int GetDoubledValue()
	{
		return CustomValue * 2;
	}

	/**
	 * Observe that the default custom value doubles to 84.
	 *
	 * @Kind Observe
	 * @Covers Component.CustomScriptComponent
	 * @Inputs a component whose CustomValue is 42
	 * @Return GetDoubledValue(), expected to be 84
	 */
	UFUNCTION()
	int GetDoubledValueDefault()
	{
		return GetDoubledValue();
	}

	/**
	 * Observe that a zeroed custom value doubles to zero.
	 *
	 * @Kind Observe
	 * @Covers Component.CustomScriptComponent
	 * @Inputs a component whose CustomValue has been set to 0
	 * @Return GetDoubledValue(), expected to be 0
	 * @Boundary zero value
	 */
	UFUNCTION()
	int GetDoubledValueZeroBoundary()
	{
		CustomValue = 0;
		return GetDoubledValue();
	}
}

UCLASS()
class ACoverageComponentCustomScriptActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCustomLogicComponent CustomComp;

	UPROPERTY()
	int RetrievedValue = 0;

	UPROPERTY()
	FString RetrievedName;

	UPROPERTY()
	int DoubledValue = 0;

	/**
	 * WorldStory: BeginPlay copies the value and name off the component and calls
	 * its doubling method.
	 *
	 * @Kind WorldStory
	 * @Covers Component.CustomScriptComponent
	 * @Inputs a default-attached UCustomLogicComponent
	 * @Return RetrievedValue 42, RetrievedName "TestComponent", DoubledValue 84
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (CustomComp != nullptr)
		{
			RetrievedValue = CustomComp.CustomValue;
			RetrievedName = CustomComp.CustomName;
			DoubledValue = CustomComp.GetDoubledValue();
		}
	}

	/**
	 * Observe that a locally constructed actor has retrieved nothing.
	 *
	 * @Kind Observe
	 * @Covers Component.CustomScriptComponent
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the value is 0, the name is empty and CustomComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (RetrievedValue != 0)
		{
			return false;
		}
		if (RetrievedName.Len() != 0)
		{
			return false;
		}
		if (DoubledValue != 0)
		{
			return false;
		}
		return CustomComp == nullptr;
	}
}
/** @end */
/**
 * @begin custom-script-scene-component
 * @summary A script-derived scene component carrying a radius, a colour and an area method. C++ reads the retrieved radius, colour, calculated area and validity flag by path. The observers cover the local-construct default and the.
 * @topic Component
 */
UCLASS()
class UCustomSceneComponent : USceneComponent
{
	UPROPERTY()
	float CustomRadius = 100.0f;

	UPROPERTY()
	FLinearColor CustomColor = FLinearColor::Red;

	/**
	 * Compute the circular area from the custom radius.
	 *
	 * @Kind Action
	 * @Covers Component.CustomScriptSceneComponent
	 * @Inputs none
	 * @Return pi * CustomRadius * CustomRadius
	 */
	UFUNCTION()
	float GetArea()
	{
		return 3.14159f * CustomRadius * CustomRadius;
	}

	/**
	 * Observe that a zeroed radius yields a zero area.
	 *
	 * @Kind Observe
	 * @Covers Component.CustomScriptSceneComponent
	 * @Inputs a component whose CustomRadius has been set to 0
	 * @Return GetArea(), expected to be 0
	 * @Boundary zero radius
	 */
	UFUNCTION()
	float GetAreaZeroBoundary()
	{
		CustomRadius = 0.0f;
		return GetArea();
	}
}

UCLASS()
class ACoverageSpecialCustomSceneActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UCustomSceneComponent CustomComp;

	UPROPERTY()
	float RetrievedRadius = 0.0f;

	UPROPERTY()
	FLinearColor RetrievedColor;

	UPROPERTY()
	float CalculatedArea = 0.0f;

	UPROPERTY()
	bool CustomComponentValid = false;

	/**
	 * WorldStory: BeginPlay copies the radius and colour off the component and calls
	 * its area method.
	 *
	 * @Kind WorldStory
	 * @Covers Component.CustomScriptSceneComponent
	 * @Inputs a default-attached UCustomSceneComponent
	 * @Return RetrievedRadius 100, RetrievedColor red, CalculatedArea ~31415.9, CustomComponentValid true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (CustomComp != nullptr)
		{
			CustomComponentValid = true;
			RetrievedRadius = CustomComp.CustomRadius;
			RetrievedColor = CustomComp.CustomColor;
			CalculatedArea = CustomComp.GetArea();
		}
	}

	/**
	 * Observe that a locally constructed actor has retrieved nothing.
	 *
	 * @Kind Observe
	 * @Covers Component.CustomScriptSceneComponent
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when radius and area are 0, the flag is clear and CustomComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (RetrievedRadius != 0.0f)
		{
			return false;
		}
		if (CalculatedArea != 0.0f)
		{
			return false;
		}
		if (CustomComponentValid)
		{
			return false;
		}
		return CustomComp == nullptr;
	}
}
/** @end */
/**
 * @begin destroy-component-unregisters-runtime-component
 * @summary DestroyComponent on a runtime script component, which must leave it both destroying and unregistered. C++ spawns the actor, calls DestroySelf and then inspects the probe. The observers cover the local-construct default.
 * @topic Component
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
/** @end */
/**
 * @begin end-play-receives-destroyed-reason
 * @summary A component EndPlay override recording how many times it ran and the reason it last received. C++ destroys the actor and verifies the count and reason by path. The observers cover the local-construct default and copy.
 * @topic Component
 */
UCLASS()
class UTestComponentLifecycleEndPlayProbe : UActorComponent
{
	UPROPERTY()
	int EndPlayCount = 0;

	UPROPERTY()
	EEndPlayReason LastReason = EEndPlayReason::Quit;

	/**
	 * WorldStory: EndPlay records how many times it ran and the reason supplied.
	 *
	 * @Kind WorldStory
	 * @Covers Component.EndPlayReceivesDestroyedReason
	 * @Inputs the end play reason supplied by the engine
	 * @Return EndPlayCount incremented and LastReason set to the received reason
	 * @Param Reason why the component is ending play
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		EndPlayCount += 1;
		LastReason = Reason;
	}

	/**
	 * Observe that a locally constructed probe has not ended play.
	 *
	 * @Kind Observe
	 * @Covers Component.EndPlayReceivesDestroyedReason
	 * @Inputs a probe that has not ended play
	 * @Return true when the count is 0 and the reason is still Quit
	 * @Boundary declared default
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (EndPlayCount != 0)
		{
			return false;
		}
		return LastReason == EEndPlayReason::Quit;
	}

	/**
	 * Observe that writing this probe leaves another probe untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.EndPlayReceivesDestroyedReason
	 * @Inputs this probe plus a second probe
	 * @Return true when this holds one Destroyed end play and the other keeps its defaults
	 * @Param Second the other probe, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UTestComponentLifecycleEndPlayProbe Second)
	{
		if (Second is null)
		{
			throw("EndPlayReceivesDestroyedReason setup: required Second is null");
		}
		EndPlayCount = 1;
		LastReason = EEndPlayReason::Destroyed;

		if (EndPlayCount != 1)
		{
			return false;
		}
		if (LastReason != EEndPlayReason::Destroyed)
		{
			return false;
		}
		if (Second.EndPlayCount != 0)
		{
			return false;
		}
		return Second.LastReason == EEndPlayReason::Quit;
	}
}

/**
 * The actor that hosts the EndPlay probe as a default component.
 *
 * @Covers Component.EndPlayReceivesDestroyedReason
 * @Inputs none
 * @Return an actor carrying one UTestComponentLifecycleEndPlayProbe
 */
UCLASS()
class ATestComponentLifecycleEndPlayReason : AActor
{
	UPROPERTY(DefaultComponent)
	UTestComponentLifecycleEndPlayProbe Probe;
}
/** @end */
/**
 * @begin enhanced-input-component-binding-events-and-removal
 * @summary Enhanced Input action, action-value and debug-key bindings, followed by the three Clear*Bindings calls. C++ verifies the four flags by path. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class AEnhancedInputCoverageActor : AActor
{
	UPROPERTY()
	UInputAction Action;

	UPROPERTY()
	int StartedCount = 0;

	UPROPERTY()
	bool bBindingsAdded = false;

	UPROPERTY()
	bool bActionValueBindingAdded = false;

	UPROPERTY()
	bool bDebugBindingAdded = false;

	UPROPERTY()
	bool bClearRemovedBindings = false;

	/**
	 * Count each triggered action the bindings deliver.
	 *
	 * @Kind EventHandler
	 * @Covers Component.EnhancedInputComponentBindingEventsAndRemoval
	 * @Inputs the action value and trigger timings
	 * @Return StartedCount incremented once per trigger
	 * @Param ActionValue the value delivered with the action
	 * @Param ElapsedTime how long the action has been held
	 * @Param TriggeredTime how long since the trigger fired
	 * @Param SourceAction the action that fired
	 */
	UFUNCTION()
	void OnAction(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		StartedCount += 1;
	}

	/**
	 * Receive a debug key binding without recording anything.
	 *
	 * @Kind EventHandler
	 * @Covers Component.EnhancedInputComponentBindingEventsAndRemoval
	 * @Inputs the key and its action value
	 * @Return nothing; the binding existing is what the test observes
	 * @Param Key the debug key that was pressed
	 * @Param ActionValue the value delivered with the key
	 */
	UFUNCTION()
	void OnDebug(FKey Key, FInputActionValue ActionValue)
	{
	}

	/**
	 * WorldStory: build an enhanced input component, install all three binding
	 * kinds, then clear them again.
	 *
	 * @Kind WorldStory
	 * @Covers Component.EnhancedInputComponentBindingEventsAndRemoval
	 * @Inputs none
	 * @Return all four flags true; all stay false when either NewObject fails
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Action = Cast<UInputAction>(NewObject(this, UInputAction::StaticClass(), n"CoverageAction", true));
		UEnhancedInputComponent EnhancedComponent = Cast<UEnhancedInputComponent>(NewObject(this, UEnhancedInputComponent::StaticClass(), n"CoverageEnhancedInputComponent", true));
		if (Action == nullptr || EnhancedComponent == nullptr)
		{
			return;
		}

		FEnhancedInputActionHandlerDynamicSignature StartedDelegate;
		StartedDelegate.BindUFunction(this, n"OnAction");
		EnhancedComponent.BindAction(Action, ETriggerEvent::Started, StartedDelegate);
		EnhancedComponent.BindAction(Action, ETriggerEvent::Ongoing, StartedDelegate);
		EnhancedComponent.BindAction(Action, ETriggerEvent::Triggered, StartedDelegate);
		EnhancedComponent.BindAction(Action, ETriggerEvent::Completed, StartedDelegate);
		EnhancedComponent.BindAction(Action, ETriggerEvent::Canceled, StartedDelegate);
		bBindingsAdded = EnhancedComponent.HasBindings();

		EnhancedComponent.BindActionValue(Action);
		bActionValueBindingAdded = EnhancedComponent.HasBindings();

		FInputDebugKeyHandlerDynamicSignature DebugDelegate;
		DebugDelegate.BindUFunction(this, n"OnDebug");
		EnhancedComponent.BindDebugKey(FInputChord(EKeys::SpaceBar), EInputEvent::IE_Pressed, DebugDelegate, true);
		bDebugBindingAdded = EnhancedComponent.HasBindings();

		EnhancedComponent.ClearActionEventBindings();
		EnhancedComponent.ClearActionValueBindings();
		EnhancedComponent.ClearDebugKeyBindings();
		bClearRemovedBindings = !EnhancedComponent.HasBindings();
	}

	/**
	 * Observe that a locally constructed actor has no action and no flags set.
	 *
	 * @Kind Observe
	 * @Covers Component.EnhancedInputComponentBindingEventsAndRemoval
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when Action is null, the count is 0 and all flags are clear
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (Action != nullptr)
		{
			return false;
		}
		if (StartedCount != 0)
		{
			return false;
		}
		if (bBindingsAdded)
		{
			return false;
		}
		if (bActionValueBindingAdded)
		{
			return false;
		}
		if (bDebugBindingAdded)
		{
			return false;
		}
		return !bClearRemovedBindings;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.EnhancedInputComponentBindingEventsAndRemoval
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the bound state and the other stays at its defaults
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(AEnhancedInputCoverageActor Second)
	{
		if (Second is null)
		{
			throw("EnhancedInputComponentBindingEventsAndRemoval setup: required Second is null");
		}
		bBindingsAdded = true;
		StartedCount = 1;

		if (!bBindingsAdded)
		{
			return false;
		}
		if (StartedCount != 1)
		{
			return false;
		}
		if (Second.bBindingsAdded)
		{
			return false;
		}
		if (Second.StartedCount != 0)
		{
			return false;
		}
		return Second.Action == nullptr;
	}
}
/** @end */
/**
 * @begin event-built-in-actor-and-component-instances
 * @summary AddUFunction bindings on both the actor-level and the component-level built-in overlap, hit, click and release delegates. C++ broadcasts once and compares the handler counts. The observers cover the local-construct.
 * @topic Component
 */
UCLASS()
class ACoverageEventBuiltInActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent SphereComp;

	UPROPERTY()
	int ActorBeginOverlapCount = 0;

	UPROPERTY()
	int ActorHitCount = 0;

	UPROPERTY()
	int ActorClickCount = 0;

	UPROPERTY()
	int ActorReleaseCount = 0;

	UPROPERTY()
	int ComponentHitCount = 0;

	UPROPERTY()
	int ComponentBeginOverlapCount = 0;

	UPROPERTY()
	int ComponentClickCount = 0;

	UPROPERTY()
	int ComponentReleaseCount = 0;

	/**
	 * WorldStory: bind all four actor delegates and all four sphere delegates.
	 *
	 * @Kind WorldStory
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs a default-attached USphereComponent
	 * @Return all eight handlers bound
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnActorBeginOverlap.AddUFunction(this, n"HandleActorBeginOverlap");
		OnActorHit.AddUFunction(this, n"HandleActorHit");
		OnClicked.AddUFunction(this, n"HandleActorClicked");
		OnReleased.AddUFunction(this, n"HandleActorReleased");

		SphereComp.OnComponentHit.AddUFunction(this, n"HandleComponentHit");
		SphereComp.OnComponentBeginOverlap.AddUFunction(this, n"HandleComponentBeginOverlap");
		SphereComp.OnClicked.AddUFunction(this, n"HandleComponentClicked");
		SphereComp.OnReleased.AddUFunction(this, n"HandleComponentReleased");
	}

	/**
	 * Count an actor begin overlap broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs the overlapped actor and the other actor
	 * @Return ActorBeginOverlapCount incremented
	 * @Param OverlappedActor the actor that was overlapped
	 * @Param OtherActor the other actor in the overlap
	 */
	UFUNCTION()
	void HandleActorBeginOverlap(AActor OverlappedActor, AActor OtherActor)
	{
		ActorBeginOverlapCount += 1;
	}

	/**
	 * Count an actor hit broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs both actors, the impulse and the hit result
	 * @Return ActorHitCount incremented
	 * @Param SelfActor the actor that was hit
	 * @Param OtherActor the other actor in the hit
	 * @Param NormalImpulse the impulse delivered by the hit
	 * @Param Hit the hit result
	 */
	UFUNCTION()
	void HandleActorHit(AActor SelfActor, AActor OtherActor, FVector NormalImpulse, const FHitResult&in Hit)
	{
		ActorHitCount += 1;
	}

	/**
	 * Count an actor click broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs the touched actor and the button used
	 * @Return ActorClickCount incremented
	 * @Param TouchedActor the actor that was clicked
	 * @Param ButtonPressed the key that was used
	 */
	UFUNCTION()
	void HandleActorClicked(AActor TouchedActor, FKey ButtonPressed)
	{
		ActorClickCount += 1;
	}

	/**
	 * Count an actor release broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs the touched actor and the button released
	 * @Return ActorReleaseCount incremented
	 * @Param TouchedActor the actor that was released
	 * @Param ButtonReleased the key that was let go
	 */
	UFUNCTION()
	void HandleActorReleased(AActor TouchedActor, FKey ButtonReleased)
	{
		ActorReleaseCount += 1;
	}

	/**
	 * Count a component hit broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs both components, both actors, the impulse and the hit result
	 * @Return ComponentHitCount incremented
	 * @Param HitComponent the component that was hit
	 * @Param OtherActor the other actor in the hit
	 * @Param OtherComp the other component in the hit
	 * @Param NormalImpulse the impulse delivered by the hit
	 * @Param Hit the hit result
	 */
	UFUNCTION()
	void HandleComponentHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp, FVector NormalImpulse, const FHitResult&in Hit)
	{
		ComponentHitCount += 1;
	}

	/**
	 * Count a component begin overlap broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs both components, both actors, the body index, the sweep flag and the sweep result
	 * @Return ComponentBeginOverlapCount incremented
	 * @Param OverlappedComponent the component that was overlapped
	 * @Param OtherActor the other actor in the overlap
	 * @Param OtherComp the other component in the overlap
	 * @Param OtherBodyIndex the body index of the other component
	 * @Param bFromSweep whether the overlap came from a sweep
	 * @Param SweepResult the sweep result
	 */
	UFUNCTION()
	void HandleComponentBeginOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor, UPrimitiveComponent OtherComp, int OtherBodyIndex, bool bFromSweep, const FHitResult&in SweepResult)
	{
		ComponentBeginOverlapCount += 1;
	}

	/**
	 * Count a component click broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs the touched component and the button used
	 * @Return ComponentClickCount incremented
	 * @Param TouchedComponent the component that was clicked
	 * @Param ButtonPressed the key that was used
	 */
	UFUNCTION()
	void HandleComponentClicked(UPrimitiveComponent TouchedComponent, FKey ButtonPressed)
	{
		ComponentClickCount += 1;
	}

	/**
	 * Count a component release broadcast.
	 *
	 * @Kind EventHandler
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs the touched component and the button released
	 * @Return ComponentReleaseCount incremented
	 * @Param TouchedComponent the component that was released
	 * @Param ButtonReleased the key that was let go
	 */
	UFUNCTION()
	void HandleComponentReleased(UPrimitiveComponent TouchedComponent, FKey ButtonReleased)
	{
		ComponentReleaseCount += 1;
	}

	/**
	 * Observe that a locally constructed actor holds no counts and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all eight counts are 0 and SphereComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ActorBeginOverlapCount != 0)
		{
			return false;
		}
		if (ActorHitCount != 0)
		{
			return false;
		}
		if (ActorClickCount != 0)
		{
			return false;
		}
		if (ActorReleaseCount != 0)
		{
			return false;
		}
		if (ComponentHitCount != 0)
		{
			return false;
		}
		if (ComponentBeginOverlapCount != 0)
		{
			return false;
		}
		if (ComponentClickCount != 0)
		{
			return false;
		}
		if (ComponentReleaseCount != 0)
		{
			return false;
		}
		return SphereComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.BuiltInActorAndComponentEvents
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds both counts and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageEventBuiltInActor Second)
	{
		if (Second is null)
		{
			throw("EventBuiltInActorAndComponentInstances setup: required Second is null");
		}
		ActorBeginOverlapCount = 1;
		ComponentHitCount = 1;

		if (ActorBeginOverlapCount != 1)
		{
			return false;
		}
		if (ComponentHitCount != 1)
		{
			return false;
		}
		if (Second.ActorBeginOverlapCount != 0)
		{
			return false;
		}
		return Second.ComponentHitCount == 0;
	}
}
/** @end */
/**
 * @begin four-level-attach-chain-resolves
 * @summary A four-level DefaultComponent attach chain. C++ spawns the actor and walks the parents of Root, Middle, LeafMesh and DeepLight. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class AFunctionalMultiLevelActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach = Root)
	USceneComponent Middle;

	UPROPERTY(DefaultComponent, Attach = Middle)
	UStaticMeshComponent LeafMesh;

	UPROPERTY(DefaultComponent, Attach = LeafMesh)
	UPointLightComponent DeepLight;

	/**
	 * Observe that a locally constructed actor has none of the four components.
	 *
	 * @Kind Observe
	 * @Covers Component.FourLevelAttachChain
	 * @Inputs an actor that has not been spawned
	 * @Return true when all four handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultComponentsNull()
	{
		if (Root != nullptr)
		{
			return false;
		}
		if (Middle != nullptr)
		{
			return false;
		}
		if (LeafMesh != nullptr)
		{
			return false;
		}
		return DeepLight == nullptr;
	}

	/**
	 * Observe that a second instance keeps its own independent null handles.
	 *
	 * @Kind Observe
	 * @Covers Component.FourLevelAttachChain
	 * @Inputs this actor plus a second actor
	 * @Return true when all eight handles are null
	 * @Param Second the other actor, also expected to hold null handles
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(AFunctionalMultiLevelActor Second)
	{
		if (Second is null)
		{
			throw("FourLevelAttachChainResolves setup: required Second is null");
		}
		if (Root != nullptr)
		{
			return false;
		}
		if (Second.Root != nullptr)
		{
			return false;
		}
		if (Middle != nullptr)
		{
			return false;
		}
		if (Second.Middle != nullptr)
		{
			return false;
		}
		if (LeafMesh != nullptr)
		{
			return false;
		}
		if (Second.LeafMesh != nullptr)
		{
			return false;
		}
		if (DeepLight != nullptr)
		{
			return false;
		}
		return Second.DeepLight == nullptr;
	}
}
/** @end */
/**
 * @begin get-all-components
 * @summary GetAllComponents filling and storing arrays by class. C++ calls the entrypoints by name and inspects the stored arrays, so both the entrypoint names and the stored-array property names are part of the contract and are.
 * @topic Component
 */
UCLASS()
class UTestCompA : USceneComponent
{
}

UCLASS()
class UTestCompB : USceneComponent
{
}

/**
 * The derived component that the base-class queries must also resolve.
 *
 * @Covers Component.GetAllComponents
 * @Inputs none
 * @Return a component derived from UTestCompB
 */
UCLASS()
class UTestCompDerivedB : UTestCompB
{
}

UCLASS()
class ATestActorGetAllComponents : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestCompA CompA;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UTestCompB CompB;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UTestCompB CompB2;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UTestCompDerivedB DerivedB;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UTestCompDerivedB DerivedB2;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UBillboardComponent Billboard;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UBillboardComponent Billboard2;

	UPROPERTY()
	TArray<UActorComponent> LastBFamilyForCpp;

	UPROPERTY()
	TArray<UActorComponent> LastAllComponentsForCpp;

	UPROPERTY()
	TArray<UActorComponent> LastBillboardsForCpp;

	/**
	 * Return the root component to C++.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs none
	 * @Return CompA, or null before the actor is spawned
	 */
	UFUNCTION()
	UActorComponent ReturnRootForCpp()
	{
		return CompA;
	}

	/**
	 * Return the derived component to C++.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs none
	 * @Return DerivedB, or null before the actor is spawned
	 */
	UFUNCTION()
	UActorComponent ReturnDerivedForCpp()
	{
		return DerivedB;
	}

	/**
	 * Fill an array with every actor component.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs an array to fill
	 * @Return every UActorComponent in the actor
	 * @Param OutComponents the array to fill
	 */
	UFUNCTION()
	void FillAllActorComponentsForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(UActorComponent::StaticClass(), OutComponents);
	}

	/**
	 * Fill an array with every scene component.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs an array to fill
	 * @Return every USceneComponent in the actor
	 * @Param OutComponents the array to fill
	 */
	UFUNCTION()
	void FillAllSceneComponentsForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(USceneComponent::StaticClass(), OutComponents);
	}

	/**
	 * Fill an array with every component of the B family, derived ones included.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs an array to fill
	 * @Return every UTestCompB in the actor
	 * @Param OutComponents the array to fill
	 */
	UFUNCTION()
	void FillBFamilyForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(UTestCompB::StaticClass(), OutComponents);
	}

	/**
	 * Fill an array with only the derived B components.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs an array to fill
	 * @Return every UTestCompDerivedB in the actor
	 * @Param OutComponents the array to fill
	 */
	UFUNCTION()
	void FillDerivedBOnlyForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(UTestCompDerivedB::StaticClass(), OutComponents);
	}

	/**
	 * Fill an array with the billboard components.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs an array to fill
	 * @Return every UBillboardComponent in the actor
	 * @Param OutComponents the array to fill
	 */
	UFUNCTION()
	void FillBillboardsForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(UBillboardComponent::StaticClass(), OutComponents);
	}

	/**
	 * Fill an array with static mesh components, of which the actor has none.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs an array to fill
	 * @Return an empty array
	 * @Param OutComponents the array to fill
	 * @Boundary no matching class
	 */
	UFUNCTION()
	void FillNoStaticMeshMatchesForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(UStaticMeshComponent::StaticClass(), OutComponents);
	}

	/**
	 * Append the billboard components onto an existing array.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs an array to append onto
	 * @Return the billboards appended to whatever the array already held
	 * @Param OutComponents the array to append onto
	 */
	UFUNCTION()
	void AppendBillboardsForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(UBillboardComponent::StaticClass(), OutComponents);
	}

	/**
	 * Store three query results on the actor so C++ can inspect them afterwards.
	 *
	 * @Kind Action
	 * @Covers Component.GetAllComponents
	 * @Inputs none
	 * @Return LastBFamilyForCpp, LastAllComponentsForCpp and LastBillboardsForCpp refilled
	 */
	UFUNCTION()
	void StoreArraysForCpp()
	{
		LastBFamilyForCpp.Empty();
		GetAllComponents(UTestCompB::StaticClass(), LastBFamilyForCpp);

		LastAllComponentsForCpp.Empty();
		GetAllComponents(UActorComponent::StaticClass(), LastAllComponentsForCpp);

		LastBillboardsForCpp.Empty();
		GetAllComponents(UBillboardComponent::StaticClass(), LastBillboardsForCpp);
	}

	/**
	 * Observe that a locally constructed actor has stored nothing and holds no components.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs an actor that has not been spawned
	 * @Return true when all three arrays are empty and both lookups return null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (LastBFamilyForCpp.Num() != 0)
		{
			return false;
		}
		if (LastAllComponentsForCpp.Num() != 0)
		{
			return false;
		}
		if (LastBillboardsForCpp.Num() != 0)
		{
			return false;
		}
		if (CompA != nullptr)
		{
			return false;
		}
		if (DerivedB != nullptr)
		{
			return false;
		}
		if (ReturnRootForCpp() != nullptr)
		{
			return false;
		}
		return ReturnDerivedForCpp() == nullptr;
	}

	/**
	 * Observe that querying for a class the actor does not have yields nothing.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs an actor without any static mesh component
	 * @Return true when the filled array is empty
	 * @Boundary no matching class
	 */
	UFUNCTION()
	bool NoStaticMeshEmpty()
	{
		TArray<UActorComponent> OutComponents;
		FillNoStaticMeshMatchesForCpp(OutComponents);
		return OutComponents.Num() == 0;
	}
}
/** @end */
/**
 * @begin get-component
 * @summary GetComponent by class and by name, including the missing-name, missing-class and wrong-class vectors that must all return null. C++ calls the entrypoints by name, so the names are part of the contract and are kept.
 * @topic Component
 */
UCLASS()
class UTestActorGetComponentMissing : UActorComponent
{
}

UCLASS()
class ATestActorGetComponent : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UStaticMeshComponent Mesh;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UBillboardComponent Billboard;

	/**
	 * Resolve the first scene component by class for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.GetComponent
	 * @Inputs none
	 * @Return the first USceneComponent, or null before the actor is spawned
	 */
	UFUNCTION()
	UActorComponent FindFirstSceneByClassForCpp()
	{
		return GetComponent(USceneComponent::StaticClass());
	}

	/**
	 * Resolve the static mesh component by class for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.GetComponent
	 * @Inputs none
	 * @Return the UStaticMeshComponent, or null before the actor is spawned
	 */
	UFUNCTION()
	UActorComponent FindMeshByClassForCpp()
	{
		return GetComponent(UStaticMeshComponent::StaticClass());
	}

	/**
	 * Resolve the root by both class and name for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.GetComponent
	 * @Inputs none
	 * @Return the component named RootScene, or null before the actor is spawned
	 */
	UFUNCTION()
	UActorComponent FindRootByClassAndNameForCpp()
	{
		return GetComponent(USceneComponent::StaticClass(), n"RootScene");
	}

	/**
	 * Resolve the mesh through its parent class rather than its own for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.GetComponent
	 * @Inputs none
	 * @Return the component named Mesh found as a USceneComponent
	 */
	UFUNCTION()
	UActorComponent FindMeshByParentClassAndNameForCpp()
	{
		return GetComponent(USceneComponent::StaticClass(), n"Mesh");
	}

	/**
	 * Resolve the billboard under a type it does not have, which must not resolve.
	 *
	 * @Kind Observe
	 * @Covers Component.GetComponent
	 * @Inputs none
	 * @Return null
	 * @Boundary wrong class
	 */
	UFUNCTION()
	UActorComponent FindBillboardWithWrongClassForCpp()
	{
		return GetComponent(UStaticMeshComponent::StaticClass(), n"Billboard");
	}

	/**
	 * Resolve a name the actor does not carry, which must not resolve.
	 *
	 * @Kind Observe
	 * @Covers Component.GetComponent
	 * @Inputs none
	 * @Return null
	 * @Boundary missing name
	 */
	UFUNCTION()
	UActorComponent FindMissingSceneByNameForCpp()
	{
		return GetComponent(USceneComponent::StaticClass(), n"MissingScene");
	}

	/**
	 * Resolve a class the actor does not carry, which must not resolve.
	 *
	 * @Kind Observe
	 * @Covers Component.GetComponent
	 * @Inputs none
	 * @Return null
	 * @Boundary missing class
	 */
	UFUNCTION()
	UActorComponent FindMissingComponentByClassForCpp()
	{
		return GetComponent(UTestActorGetComponentMissing::StaticClass());
	}

	/**
	 * Observe that a locally constructed actor has none of the three components.
	 *
	 * @Kind Observe
	 * @Covers Component.GetComponent
	 * @Inputs an actor that has not been spawned
	 * @Return true when all three handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultNull()
	{
		if (RootScene != nullptr)
		{
			return false;
		}
		if (Mesh != nullptr)
		{
			return false;
		}
		return Billboard == nullptr;
	}

	/**
	 * Observe that the three negative lookups all return null.
	 *
	 * @Kind Observe
	 * @Covers Component.GetComponent
	 * @Inputs an actor with a billboard but no static mesh and no missing names
	 * @Return true when all three negative lookups return null
	 * @Boundary wrong class, missing name, missing class
	 */
	UFUNCTION()
	bool MissingAndWrongClassNull()
	{
		if (FindBillboardWithWrongClassForCpp() != nullptr)
		{
			return false;
		}
		if (FindMissingSceneByNameForCpp() != nullptr)
		{
			return false;
		}
		return FindMissingComponentByClassForCpp() == nullptr;
	}
}
/** @end */
/**
 * @begin get-or-create-component
 * @summary GetOrCreateComponent reusing an existing root versus lazily creating named components. C++ calls the entrypoints by name, so the names are part of the contract and are kept verbatim. The observers cover the.
 * @topic Component
 */
UCLASS()
class ATestActorGetOrCreateComponent : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	/**
	 * Get the existing root by name for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.GetOrCreateComponent
	 * @Inputs none
	 * @Return the existing RootScene, reused rather than recreated
	 */
	UFUNCTION()
	UActorComponent GetExistingRootByNameForCpp()
	{
		return GetOrCreateComponent(USceneComponent::StaticClass(), n"RootScene");
	}

	/**
	 * Get the existing root by class alone for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.GetOrCreateComponent
	 * @Inputs none
	 * @Return the existing scene component, reused rather than recreated
	 */
	UFUNCTION()
	UActorComponent GetExistingRootByClassForCpp()
	{
		return GetOrCreateComponent(USceneComponent::StaticClass());
	}

	/**
	 * Lazily create a named scene component for C++.
	 *
	 * @Kind Action
	 * @Covers Component.GetOrCreateComponent
	 * @Inputs none
	 * @Return the newly created LazyScene component
	 */
	UFUNCTION()
	USceneComponent CreateLazySceneForCpp()
	{
		return Cast<USceneComponent>(GetOrCreateComponent(USceneComponent::StaticClass(), n"LazyScene"));
	}

	/**
	 * Look up the lazily created scene again, which must reuse it.
	 *
	 * @Kind Observe
	 * @Covers Component.GetOrCreateComponent
	 * @Inputs none
	 * @Return the same LazyScene component rather than a second one
	 */
	UFUNCTION()
	UActorComponent GetLazySceneAgainForCpp()
	{
		return GetOrCreateComponent(USceneComponent::StaticClass(), n"LazyScene");
	}

	/**
	 * Lazily create a named billboard component for C++.
	 *
	 * @Kind Action
	 * @Covers Component.GetOrCreateComponent
	 * @Inputs none
	 * @Return the newly created LazyBillboard component
	 */
	UFUNCTION()
	UBillboardComponent CreateLazyBillboardForCpp()
	{
		return Cast<UBillboardComponent>(GetOrCreateComponent(UBillboardComponent::StaticClass(), n"LazyBillboard"));
	}

	/**
	 * Look up the lazy billboard through a parent class for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.GetOrCreateComponent
	 * @Inputs none
	 * @Return the LazyBillboard component found as a USceneComponent
	 */
	UFUNCTION()
	UActorComponent GetLazyBillboardBySceneClassForCpp()
	{
		return GetOrCreateComponent(USceneComponent::StaticClass(), n"LazyBillboard");
	}

	/**
	 * Observe that a locally constructed actor has no root component.
	 *
	 * @Kind Observe
	 * @Covers Component.GetOrCreateComponent
	 * @Inputs an actor that has not been spawned
	 * @Return true when RootScene is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultNull()
	{
		return RootScene == nullptr;
	}

	/**
	 * Observe that a second instance keeps its own independent null root.
	 *
	 * @Kind Observe
	 * @Covers Component.GetOrCreateComponent
	 * @Inputs this actor plus a second actor
	 * @Return true when both roots are null
	 * @Param Second the other actor, also expected to hold a null root
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestActorGetOrCreateComponent Second)
	{
		if (Second is null)
		{
			throw("GetOrCreateComponent setup: required Second is null");
		}
		if (RootScene != nullptr)
		{
			return false;
		}
		return Second.RootScene == nullptr;
	}
}
/** @end */
/**
 * @begin has-begun-play-transitions-in-world
 * @summary A component HasBegunPlay transition observed from inside its own BeginPlay override. C++ spawns the actor and reads the recorded flags and owner by path. The observers cover the local-construct defaults.
 * @topic Component
 */
UCLASS()
class UTestComponentLifecycleBeginPlayProbe : UActorComponent
{
	UPROPERTY()
	bool bSawBeginPlay = false;

	UPROPERTY()
	bool bHadNotBegunPlayInsideOverride = false;

	UPROPERTY()
	AActor OwnerAtBeginPlay;

	/**
	 * WorldStory: BeginPlay records that HasBegunPlay is still false while the
	 * override is running, and captures the owner.
	 *
	 * @Kind WorldStory
	 * @Covers Component.HasBegunPlayTransitionsInWorld
	 * @Inputs none
	 * @Return bSawBeginPlay true, bHadNotBegunPlayInsideOverride true, OwnerAtBeginPlay the owning actor
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		bSawBeginPlay = true;
		bHadNotBegunPlayInsideOverride = !HasBegunPlay();
		OwnerAtBeginPlay = GetOwner();
	}

	/**
	 * Observe that a locally constructed probe has not begun play.
	 *
	 * @Kind Observe
	 * @Covers Component.HasBegunPlayTransitionsInWorld
	 * @Inputs a probe that has not begun play
	 * @Return true when both flags are clear and the owner is null
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool ProbeDefaultNull()
	{
		if (bSawBeginPlay)
		{
			return false;
		}
		if (bHadNotBegunPlayInsideOverride)
		{
			return false;
		}
		return OwnerAtBeginPlay == nullptr;
	}
}

UCLASS()
class ATestComponentLifecycleHasBegunPlay : AActor
{
	UPROPERTY(DefaultComponent)
	UTestComponentLifecycleBeginPlayProbe Probe;

	/**
	 * Observe that a locally constructed actor has no probe component.
	 *
	 * @Kind Observe
	 * @Covers Component.HasBegunPlayTransitionsInWorld
	 * @Inputs an actor that has not been spawned
	 * @Return true when Probe is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		return Probe == nullptr;
	}
}
/** @end */
/**
 * @begin interface-component-and-input
 * @summary GetComponentsByClass alongside GetInputComponent, EnableInput and DisableInput. C++ calls CheckComponentsAndInput with a spawned player controller and expects 1. The observers cover the local-construct default and the.
 * @topic Component
 */
UCLASS()
class UTestActorInterfaceRootComponent : USceneComponent
{
}

UCLASS()
class UTestActorInterfaceExtraComponent : USceneComponent
{
}

UCLASS()
class ATestActorInterfaceComponentAndInput : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestActorInterfaceRootComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UTestActorInterfaceExtraComponent ExtraScene;

	/**
	 * Walk the component queries and the input enable/disable round trip.
	 *
	 * @Kind Observe
	 * @Covers Component.InterfaceComponentAndInput
	 * @Inputs a player controller to enable input against
	 * @Return 1 on success; 10, 20, 30, 40 or 50 naming the step that failed
	 * @Param Controller the controller to enable and then disable input for
	 */
	UFUNCTION()
	int CheckComponentsAndInput(APlayerController Controller)
	{
		TArray<USceneComponent> SceneComponents;
		GetComponentsByClass(SceneComponents);
		if (SceneComponents.Num() != 2)
		{
			return 10;
		}

		TArray<UTestActorInterfaceExtraComponent> ExtraComponents;
		GetComponentsByClass(UTestActorInterfaceExtraComponent::StaticClass(), ExtraComponents);
		if (ExtraComponents.Num() != 1)
		{
			return 20;
		}

		TArray<UActorComponent> ActorComponents;
		GetComponentsByClass(USceneComponent::StaticClass(), ActorComponents);
		if (ActorComponents.Num() != 2)
		{
			return 30;
		}

		if (GetInputComponent() != nullptr)
		{
			return 40;
		}
		EnableInput(Controller);
		if (GetInputComponent() == nullptr)
		{
			return 50;
		}
		DisableInput(Controller);

		return 1;
	}

	/**
	 * Observe that a locally constructed actor has no components and no input component.
	 *
	 * @Kind Observe
	 * @Covers Component.InterfaceComponentAndInput
	 * @Inputs an actor that has not been spawned
	 * @Return true when both scene components and the input component are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultNull()
	{
		if (RootScene != nullptr)
		{
			return false;
		}
		if (ExtraScene != nullptr)
		{
			return false;
		}
		return GetInputComponent() == nullptr;
	}

	/**
	 * Observe the entrypoint result when no controller is supplied.
	 *
	 * @Kind Observe
	 * @Covers Component.InterfaceComponentAndInput
	 * @Inputs a null player controller
	 * @Return CheckComponentsAndInput(nullptr)
	 * @Boundary null controller
	 */
	UFUNCTION()
	int NullController()
	{
		return CheckComponentsAndInput(nullptr);
	}
}
/** @end */
/**
 * @begin member-object-actor-component-references
 * @summary Member handles for a UObject, an AActor and a UActorComponent, assigned from NewObject, SpawnActor and CreateComponent. C++ verifies the four flags by path. The observers cover the local-construct default and copy.
 * @topic Component
 */
UCLASS()
class ACoverageHandleMemberReferenceActor : AActor
{
	UPROPERTY()
	UObject MemberObject;

	UPROPERTY()
	AActor MemberActor;

	UPROPERTY()
	UActorComponent MemberComponent;

	UPROPERTY()
	bool ObjectReferenceWorked = false;

	UPROPERTY()
	bool ActorReferenceWorked = false;

	UPROPERTY()
	bool ComponentReferenceWorked = false;

	UPROPERTY()
	bool ComponentOwnerWorked = false;

	/**
	 * WorldStory: BeginPlay assigns all three member handles and records that each
	 * one landed where it should.
	 *
	 * @Kind WorldStory
	 * @Covers Component.MemberObjectActorComponentReferences
	 * @Inputs none
	 * @Return all four flags true; the object is outer-ed to this, the actor is not this,
	 * the component is named and owned by this
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MemberObject = NewObject(this, UTexture2D::StaticClass(), n"CoverageMemberObject");
		MemberActor = SpawnActor(AActor::StaticClass());
		MemberComponent = CreateComponent(USceneComponent::StaticClass(), n"CoverageMemberComponent");

		ObjectReferenceWorked = MemberObject != nullptr && MemberObject.GetOuter() == this;
		ActorReferenceWorked = MemberActor != nullptr && MemberActor != this;
		ComponentReferenceWorked = MemberComponent != nullptr && MemberComponent.GetName() == n"CoverageMemberComponent";
		ComponentOwnerWorked = MemberComponent != nullptr && MemberComponent.GetOwner() == this;
	}

	/**
	 * Observe that a locally constructed actor holds no handles and no flags.
	 *
	 * @Kind Observe
	 * @Covers Component.MemberObjectActorComponentReferences
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all three handles are null and all flags are clear
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultNull()
	{
		if (MemberObject != nullptr)
		{
			return false;
		}
		if (MemberActor != nullptr)
		{
			return false;
		}
		if (MemberComponent != nullptr)
		{
			return false;
		}
		if (ObjectReferenceWorked)
		{
			return false;
		}
		if (ActorReferenceWorked)
		{
			return false;
		}
		if (ComponentReferenceWorked)
		{
			return false;
		}
		return !ComponentOwnerWorked;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.MemberObjectActorComponentReferences
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds both flags and the other stays at its defaults
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageHandleMemberReferenceActor Second)
	{
		if (Second is null)
		{
			throw("MemberObjectActorComponentReferences setup: required Second is null");
		}
		ObjectReferenceWorked = true;
		ActorReferenceWorked = true;

		if (!ObjectReferenceWorked)
		{
			return false;
		}
		if (!ActorReferenceWorked)
		{
			return false;
		}
		if (Second.ObjectReferenceWorked)
		{
			return false;
		}
		if (Second.ActorReferenceWorked)
		{
			return false;
		}
		return Second.MemberObject == nullptr;
	}
}
/** @end */
/**
 * @begin multiple-shape-components
 * @summary Capsule, box and sphere default components, counted through a UShapeComponent query. C++ verifies the validity flag and the count. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class ACoverageSpecialMultipleShapesActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UCapsuleComponent CapsuleComp;

	UPROPERTY(DefaultComponent, Attach=CapsuleComp)
	UBoxComponent BoxComp;

	UPROPERTY(DefaultComponent, Attach=CapsuleComp)
	USphereComponent SphereComp;

	UPROPERTY()
	bool AllComponentsValid = false;

	UPROPERTY()
	int ShapeComponentCount = 0;

	/**
	 * WorldStory: BeginPlay sizes all three shapes, then counts the shape components
	 * the actor reports.
	 *
	 * @Kind WorldStory
	 * @Covers Component.MultipleShapeComponents
	 * @Inputs three default-attached shape components
	 * @Return AllComponentsValid true and ShapeComponentCount == 3
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AllComponentsValid = (CapsuleComp != nullptr && BoxComp != nullptr && SphereComp != nullptr);

		// Set sizes
		CapsuleComp.SetCapsuleSize(40.0f, 90.0f);
		BoxComp.SetBoxExtent(FVector(50.0f, 50.0f, 50.0f));
		SphereComp.SetSphereRadius(30.0f);

		// Count shape components
		TArray<UShapeComponent> ShapeComps;
		GetComponentsByClass(UShapeComponent::StaticClass(), ShapeComps);
		ShapeComponentCount = ShapeComps.Num();
	}

	/**
	 * Observe that a locally constructed actor has no shapes and no count.
	 *
	 * @Kind Observe
	 * @Covers Component.MultipleShapeComponents
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the flag is clear, the count is 0 and all three handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (AllComponentsValid)
		{
			return false;
		}
		if (ShapeComponentCount != 0)
		{
			return false;
		}
		if (CapsuleComp != nullptr)
		{
			return false;
		}
		if (BoxComp != nullptr)
		{
			return false;
		}
		return SphereComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.MultipleShapeComponents
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the counted state and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialMultipleShapesActor Second)
	{
		if (Second is null)
		{
			throw("MultipleShapeComponents setup: required Second is null");
		}
		AllComponentsValid = true;
		ShapeComponentCount = 3;

		if (!AllComponentsValid)
		{
			return false;
		}
		if (ShapeComponentCount != 3)
		{
			return false;
		}
		if (Second.AllComponentsValid)
		{
			return false;
		}
		return Second.ShapeComponentCount == 0;
	}
}
/** @end */
/**
 * @begin name-and-class-filtering-are-strict
 * @summary GetComponent requiring both a class and a name to agree. C++ runs RunNameClassFilterTest and expects 1. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class ATestActorComponentManagementNameClassFilter : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UStaticMeshComponent MeshScene;

	/**
	 * Walk the four filtering vectors: wrong class, missing name, and both exact
	 * matches.
	 *
	 * @Kind Observe
	 * @Covers Component.NameAndClassFilteringAreStrict
	 * @Inputs none
	 * @Return 1 on success; 10, 20, 30 or 40 naming the step that failed
	 */
	UFUNCTION()
	int RunNameClassFilterTest()
	{
		if (GetComponent(UStaticMeshComponent::StaticClass(), n"RootScene") != nullptr)
		{
			return 10;
		}

		if (GetComponent(USceneComponent::StaticClass(), n"MissingScene") != nullptr)
		{
			return 20;
		}

		UActorComponent RootByExactName = GetComponent(USceneComponent::StaticClass(), n"RootScene");
		if (RootByExactName == nullptr || RootByExactName != RootScene)
		{
			return 30;
		}

		UActorComponent MeshByExactName = GetComponent(UStaticMeshComponent::StaticClass(), n"MeshScene");
		if (MeshByExactName == nullptr || MeshByExactName != MeshScene)
		{
			return 40;
		}

		return 1;
	}

	/**
	 * Observe that a locally constructed actor has neither component.
	 *
	 * @Kind Observe
	 * @Covers Component.NameAndClassFilteringAreStrict
	 * @Inputs an actor that has not been spawned
	 * @Return true when both scene components are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultNull()
	{
		if (RootScene != nullptr)
		{
			return false;
		}
		return MeshScene == nullptr;
	}

	/**
	 * Observe that a second instance keeps its own independent null handles.
	 *
	 * @Kind Observe
	 * @Covers Component.NameAndClassFilteringAreStrict
	 * @Inputs this actor plus a second actor
	 * @Return true when all four handles are null
	 * @Param Second the other actor, also expected to hold null handles
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestActorComponentManagementNameClassFilter Second)
	{
		if (Second is null)
		{
			throw("NameAndClassFilteringAreStrict setup: required Second is null");
		}
		if (RootScene != nullptr)
		{
			return false;
		}
		if (Second.MeshScene != nullptr)
		{
			return false;
		}
		return MeshScene == nullptr;
	}
}
/** @end */
/**
 * @begin primitive-collision-channel-matrix-readback
 * @summary The built-in object-type and trace-channel collision matrix read back off a static mesh component. C++ verifies the three flags by path. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class ACoveragePrimitiveCollisionChannelMatrixActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent MeshComp;

	UPROPERTY()
	bool BuiltInObjectTypesRoundTripped = false;

	UPROPERTY()
	bool BuiltInTraceChannelsRoundTripped = false;

	UPROPERTY()
	bool AllResponsesRoundTripped = false;

	/**
	 * WorldStory: BeginPlay walks every built-in object type, both built-in trace
	 * channels, then a blanket response reset and reads all of them back.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitiveCollisionChannelMatrixReadback
	 * @Inputs a default-attached UStaticMeshComponent
	 * @Return all three flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MeshComp.SetCollisionObjectType(ECollisionChannel::ECC_WorldStatic);
		bool bWorldStatic = MeshComp.GetCollisionObjectType() == ECollisionChannel::ECC_WorldStatic;
		MeshComp.SetCollisionObjectType(ECollisionChannel::ECC_WorldDynamic);
		bool bWorldDynamic = MeshComp.GetCollisionObjectType() == ECollisionChannel::ECC_WorldDynamic;
		MeshComp.SetCollisionObjectType(ECollisionChannel::ECC_Pawn);
		bool bPawn = MeshComp.GetCollisionObjectType() == ECollisionChannel::ECC_Pawn;
		MeshComp.SetCollisionObjectType(ECollisionChannel::ECC_PhysicsBody);
		bool bPhysicsBody = MeshComp.GetCollisionObjectType() == ECollisionChannel::ECC_PhysicsBody;
		MeshComp.SetCollisionObjectType(ECollisionChannel::ECC_Vehicle);
		bool bVehicle = MeshComp.GetCollisionObjectType() == ECollisionChannel::ECC_Vehicle;
		MeshComp.SetCollisionObjectType(ECollisionChannel::ECC_Destructible);
		bool bDestructible = MeshComp.GetCollisionObjectType() == ECollisionChannel::ECC_Destructible;
		BuiltInObjectTypesRoundTripped =
			bWorldStatic
			&& bWorldDynamic
			&& bPawn
			&& bPhysicsBody
			&& bVehicle
			&& bDestructible;

		MeshComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility, ECollisionResponse::ECR_Block);
		bool bVisibility = MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility) == ECollisionResponse::ECR_Block;
		MeshComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Camera, ECollisionResponse::ECR_Ignore);
		bool bCamera = MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Camera) == ECollisionResponse::ECR_Ignore;
		BuiltInTraceChannelsRoundTripped = bVisibility && bCamera;

		MeshComp.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Ignore);
		AllResponsesRoundTripped =
			MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_WorldStatic) == ECollisionResponse::ECR_Ignore
			&& MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_WorldDynamic) == ECollisionResponse::ECR_Ignore
			&& MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn) == ECollisionResponse::ECR_Ignore
			&& MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility) == ECollisionResponse::ECR_Ignore
			&& MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Camera) == ECollisionResponse::ECR_Ignore
			&& MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_PhysicsBody) == ECollisionResponse::ECR_Ignore
			&& MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Vehicle) == ECollisionResponse::ECR_Ignore
			&& MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Destructible) == ECollisionResponse::ECR_Ignore;
	}

	/**
	 * Observe that a locally constructed actor has no flags and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveCollisionChannelMatrixReadback
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all flags are clear and MeshComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (BuiltInObjectTypesRoundTripped)
		{
			return false;
		}
		if (BuiltInTraceChannelsRoundTripped)
		{
			return false;
		}
		if (AllResponsesRoundTripped)
		{
			return false;
		}
		return MeshComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveCollisionChannelMatrixReadback
	 * @Inputs this actor plus a second actor
	 * @Return true when this is flagged and the other is not
	 * @Param Second the other actor, expected to stay unflagged
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitiveCollisionChannelMatrixActor Second)
	{
		if (Second is null)
		{
			throw("PrimitiveCollisionChannelMatrixReadback setup: required Second is null");
		}
		AllResponsesRoundTripped = true;

		if (!AllResponsesRoundTripped)
		{
			return false;
		}
		return !Second.AllResponsesRoundTripped;
	}
}
/** @end */
/**
 * @begin primitive-collision-configuration-readback
 * @summary Collision enabled state, object type and channel response all read back off a sphere component. C++ verifies the three flags by path. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class ACoveragePrimitiveCollisionConfigurationReadbackActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent SphereComp;

	UPROPERTY()
	bool CollisionEnabledRoundTripped = false;

	UPROPERTY()
	bool ObjectTypeRoundTripped = false;

	UPROPERTY()
	bool ChannelResponseRoundTripped = false;

	/**
	 * WorldStory: BeginPlay walks every collision-enabled state, both object types
	 * and all three channel responses, reading each back after it is written.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitiveCollisionConfigurationReadback
	 * @Inputs a default-attached USphereComponent
	 * @Return all three flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SphereComp.SetCollisionEnabled(ECollisionEnabled::NoCollision);
		bool bNoCollision = SphereComp.GetCollisionEnabled() == ECollisionEnabled::NoCollision;
		SphereComp.SetCollisionEnabled(ECollisionEnabled::QueryOnly);
		bool bQueryOnly = SphereComp.GetCollisionEnabled() == ECollisionEnabled::QueryOnly;
		SphereComp.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		bool bQueryAndPhysics = SphereComp.GetCollisionEnabled() == ECollisionEnabled::QueryAndPhysics;
		CollisionEnabledRoundTripped = bNoCollision && bQueryOnly && bQueryAndPhysics;

		SphereComp.SetCollisionObjectType(ECollisionChannel::ECC_WorldDynamic);
		bool bWorldDynamic = SphereComp.GetCollisionObjectType() == ECollisionChannel::ECC_WorldDynamic;
		SphereComp.SetCollisionObjectType(ECollisionChannel::ECC_Pawn);
		bool bPawn = SphereComp.GetCollisionObjectType() == ECollisionChannel::ECC_Pawn;
		ObjectTypeRoundTripped = bWorldDynamic && bPawn;

		SphereComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn, ECollisionResponse::ECR_Block);
		bool bPawnBlocks = SphereComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn) == ECollisionResponse::ECR_Block;
		SphereComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility, ECollisionResponse::ECR_Overlap);
		bool bVisibilityOverlaps = SphereComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility) == ECollisionResponse::ECR_Overlap;
		SphereComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Camera, ECollisionResponse::ECR_Ignore);
		bool bCameraIgnores = SphereComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Camera) == ECollisionResponse::ECR_Ignore;
		ChannelResponseRoundTripped = bPawnBlocks && bVisibilityOverlaps && bCameraIgnores;
	}

	/**
	 * Observe that a locally constructed actor has no flags and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveCollisionConfigurationReadback
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all flags are clear and SphereComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (CollisionEnabledRoundTripped)
		{
			return false;
		}
		if (ObjectTypeRoundTripped)
		{
			return false;
		}
		if (ChannelResponseRoundTripped)
		{
			return false;
		}
		return SphereComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveCollisionConfigurationReadback
	 * @Inputs this actor plus a second actor
	 * @Return true when this is flagged and the other is not
	 * @Param Second the other actor, expected to stay unflagged
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitiveCollisionConfigurationReadbackActor Second)
	{
		if (Second is null)
		{
			throw("PrimitiveCollisionConfigurationReadback setup: required Second is null");
		}
		CollisionEnabledRoundTripped = true;

		if (!CollisionEnabledRoundTripped)
		{
			return false;
		}
		return !Second.CollisionEnabledRoundTripped;
	}
}
/** @end */
/**
 * @begin primitive-collision-events
 * @summary OnComponentBeginOverlap and OnComponentEndOverlap bound on a sphere component. C++ spawns an overlapping actor and verifies the counts and the recorded name by path. The observers cover the local-construct default and.
 * @topic Component
 */
UCLASS()
class ACoveragePrimitiveCollisionEventsActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent SphereComp;

	UPROPERTY()
	int BeginOverlapCount = 0;

	UPROPERTY()
	int EndOverlapCount = 0;

	UPROPERTY()
	FString OverlappedActorName;

	/**
	 * WorldStory: BeginPlay configures the sphere for overlaps and binds both
	 * overlap delegates.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitiveCollisionEvents
	 * @Inputs a default-attached USphereComponent
	 * @Return both delegates bound
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SphereComp.SetCollisionEnabled(ECollisionEnabled::QueryOnly);
		SphereComp.SetCollisionProfileName(n"OverlapAll");
		SphereComp.SetGenerateOverlapEvents(true);
		SphereComp.SetSphereRadius(100.0f);

		SphereComp.OnComponentBeginOverlap.AddUFunction(this, n"HandleBeginOverlap");
		SphereComp.OnComponentEndOverlap.AddUFunction(this, n"HandleEndOverlap");
	}

	/**
	 * Count a begin overlap and record the name of the other actor.
	 *
	 * @Kind EventHandler
	 * @Covers Component.PrimitiveCollisionEvents
	 * @Inputs both components, the other actor, the body index, the sweep flag and the sweep result
	 * @Return BeginOverlapCount incremented and OverlappedActorName set from the other actor
	 * @Param OverlappedComponent the component that was overlapped
	 * @Param OtherActor the other actor in the overlap
	 * @Param OtherComp the other component in the overlap
	 * @Param OtherBodyIndex the body index of the other component
	 * @Param bFromSweep whether the overlap came from a sweep
	 * @Param SweepResult the sweep result
	 */
	UFUNCTION()
	void HandleBeginOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor,
		UPrimitiveComponent OtherComp, int32 OtherBodyIndex, bool bFromSweep, const FHitResult&in SweepResult)
	{
		BeginOverlapCount++;
		if (OtherActor != nullptr)
		{
			OverlappedActorName = OtherActor.GetName().ToString();
		}
	}

	/**
	 * Count an end overlap.
	 *
	 * @Kind EventHandler
	 * @Covers Component.PrimitiveCollisionEvents
	 * @Inputs both components, the other actor and the body index
	 * @Return EndOverlapCount incremented
	 * @Param OverlappedComponent the component that was overlapped
	 * @Param OtherActor the other actor in the overlap
	 * @Param OtherComp the other component in the overlap
	 * @Param OtherBodyIndex the body index of the other component
	 */
	UFUNCTION()
	void HandleEndOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor,
		UPrimitiveComponent OtherComp, int32 OtherBodyIndex)
	{
		EndOverlapCount++;
	}

	/**
	 * Observe that a locally constructed actor holds no counts, no name and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveCollisionEvents
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both counts are 0, the name is empty and SphereComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (BeginOverlapCount != 0)
		{
			return false;
		}
		if (EndOverlapCount != 0)
		{
			return false;
		}
		if (OverlappedActorName.Len() != 0)
		{
			return false;
		}
		return SphereComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveCollisionEvents
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the overlapped state and the other stays empty
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitiveCollisionEventsActor Second)
	{
		if (Second is null)
		{
			throw("PrimitiveCollisionEvents setup: required Second is null");
		}
		BeginOverlapCount = 1;
		OverlappedActorName = "Other";

		if (BeginOverlapCount != 1)
		{
			return false;
		}
		if (OverlappedActorName.Len() <= 0)
		{
			return false;
		}
		if (Second.BeginOverlapCount != 0)
		{
			return false;
		}
		return Second.OverlappedActorName.Len() == 0;
	}
}
/** @end */
/**
 * @begin primitive-collision-response
 * @summary Per-channel and all-channel collision responses plus the object type, all read back off a static mesh component. C++ verifies the six flags by path. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class ACoveragePrimitiveCollisionResponseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent MeshComp;

	UPROPERTY()
	bool ResponseSet = false;

	UPROPERTY()
	bool AllChannelsSet = false;

	UPROPERTY()
	bool ObjectTypeSet = false;

	UPROPERTY()
	bool BlockResponseSet = false;

	UPROPERTY()
	bool OverlapResponseSet = false;

	UPROPERTY()
	bool IgnoreResponseSet = false;

	/**
	 * WorldStory: BeginPlay writes a block, an overlap and an ignore response, then a
	 * blanket all-channel response, then the object type, reading each back.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitiveCollisionResponse
	 * @Inputs a default-attached UStaticMeshComponent
	 * @Return all six flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Set response to specific channel
		MeshComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn, ECollisionResponse::ECR_Block);
		BlockResponseSet = MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn) == ECollisionResponse::ECR_Block;

		MeshComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility, ECollisionResponse::ECR_Overlap);
		OverlapResponseSet = MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility) == ECollisionResponse::ECR_Overlap;

		MeshComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Camera, ECollisionResponse::ECR_Ignore);
		IgnoreResponseSet = MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Camera) == ECollisionResponse::ECR_Ignore;
		ResponseSet = BlockResponseSet && OverlapResponseSet && IgnoreResponseSet;

		// Set response to all channels
		MeshComp.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Block);
		AllChannelsSet =
			MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn) == ECollisionResponse::ECR_Block
			&& MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility) == ECollisionResponse::ECR_Block
			&& MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Camera) == ECollisionResponse::ECR_Block;

		// Set object type
		MeshComp.SetCollisionObjectType(ECollisionChannel::ECC_WorldDynamic);
		ObjectTypeSet = MeshComp.GetCollisionObjectType() == ECollisionChannel::ECC_WorldDynamic;
	}

	/**
	 * Observe that a locally constructed actor has no flags and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveCollisionResponse
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all six flags are clear and MeshComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (ResponseSet)
		{
			return false;
		}
		if (AllChannelsSet)
		{
			return false;
		}
		if (ObjectTypeSet)
		{
			return false;
		}
		if (BlockResponseSet)
		{
			return false;
		}
		if (OverlapResponseSet)
		{
			return false;
		}
		if (IgnoreResponseSet)
		{
			return false;
		}
		return MeshComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveCollisionResponse
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds both flags and the other stays clear
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitiveCollisionResponseActor Second)
	{
		if (Second is null)
		{
			throw("PrimitiveCollisionResponse setup: required Second is null");
		}
		ResponseSet = true;
		ObjectTypeSet = true;

		if (!ResponseSet)
		{
			return false;
		}
		if (!ObjectTypeSet)
		{
			return false;
		}
		if (Second.ResponseSet)
		{
			return false;
		}
		return !Second.ObjectTypeSet;
	}
}
/** @end */
/**
 * @begin primitive-hidden-in-game
 * @summary SetHiddenInGame accepted on a static mesh component. C++ verifies the flag and the native bHiddenInGame by path. The observers cover the declared defaults and copy independence.
 * @topic Component
 */
UCLASS()
class ACoveragePrimitiveHiddenInGameActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent MeshComp;

	UPROPERTY()
	bool InitiallyHidden = true;

	UPROPERTY()
	bool SetHiddenInGameAccepted = false;

	/**
	 * WorldStory: BeginPlay hides the mesh in game and records that the call was
	 * accepted.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitiveHiddenInGame
	 * @Inputs a default-attached UStaticMeshComponent
	 * @Return SetHiddenInGameAccepted true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MeshComp.SetHiddenInGame(true);
		SetHiddenInGameAccepted = true;
	}

	/**
	 * Observe that a locally constructed actor keeps its declared defaults.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveHiddenInGame
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when InitiallyHidden is true, the flag is clear and MeshComp is null
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (!InitiallyHidden)
		{
			return false;
		}
		if (SetHiddenInGameAccepted)
		{
			return false;
		}
		return MeshComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveHiddenInGame
	 * @Inputs this actor plus a second actor
	 * @Return true when this is flipped and the other keeps its declared defaults
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitiveHiddenInGameActor Second)
	{
		if (Second is null)
		{
			throw("PrimitiveHiddenInGame setup: required Second is null");
		}
		SetHiddenInGameAccepted = true;
		InitiallyHidden = false;

		if (!SetHiddenInGameAccepted)
		{
			return false;
		}
		if (InitiallyHidden)
		{
			return false;
		}
		if (Second.SetHiddenInGameAccepted)
		{
			return false;
		}
		return Second.InitiallyHidden;
	}
}
/** @end */
/**
 * @begin primitive-hit-events
 * @summary An OnComponentHit binding whose handler records the count and the hit normal. The C++ oracle in this method is HitCount == 0, because no hit is dispatched here. The observers cover the local-construct default and copy.
 * @topic Component
 */
UCLASS()
class ACoveragePrimitiveHitEventsActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent MeshComp;

	UPROPERTY()
	int HitCount = 0;

	UPROPERTY()
	FVector HitNormal;

	/**
	 * WorldStory: BeginPlay enables collision and binds the hit delegate.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitiveHitEvents
	 * @Inputs a default-attached UStaticMeshComponent
	 * @Return the hit delegate bound; HitCount stays 0 because nothing is dispatched here
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MeshComp.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		MeshComp.SetNotifyRigidBodyCollision(true);

		MeshComp.OnComponentHit.AddUFunction(this, n"HandleHit");
	}

	/**
	 * Count a hit and record the normal it arrived with.
	 *
	 * @Kind EventHandler
	 * @Covers Component.PrimitiveHitEvents
	 * @Inputs both components, the other actor, the impulse and the hit result
	 * @Return HitCount incremented and HitNormal set from the hit result
	 * @Param HitComponent the component that was hit
	 * @Param OtherActor the other actor in the hit
	 * @Param OtherComp the other component in the hit
	 * @Param NormalImpulse the impulse delivered by the hit
	 * @Param Hit the hit result
	 */
	UFUNCTION()
	void HandleHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp,
		FVector NormalImpulse, const FHitResult&in Hit)
	{
		HitCount++;
		HitNormal = Hit.Normal;
	}

	/**
	 * Observe that a locally constructed actor has no count, no normal and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveHitEvents
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the count is 0, the normal is zero and MeshComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (HitCount != 0)
		{
			return false;
		}
		if (HitNormal.X != 0.0f)
		{
			return false;
		}
		if (HitNormal.Y != 0.0f)
		{
			return false;
		}
		if (HitNormal.Z != 0.0f)
		{
			return false;
		}
		return MeshComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveHitEvents
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the recorded hit and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitiveHitEventsActor Second)
	{
		if (Second is null)
		{
			throw("PrimitiveHitEvents setup: required Second is null");
		}
		HitCount = 1;
		HitNormal = FVector(0.0f, 0.0f, 1.0f);

		if (HitCount != 1)
		{
			return false;
		}
		if (HitNormal.Z != 1.0f)
		{
			return false;
		}
		if (Second.HitCount != 0)
		{
			return false;
		}
		return Second.HitNormal.Z == 0.0f;
	}
}
/** @end */
/**
 * @begin primitive-physics
 * @summary Physics simulation, gravity, an impulse and a force applied to a sphere component. C++ verifies the four flags by path. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class ACoveragePrimitivePhysicsActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent SphereComp;

	UPROPERTY()
	bool PhysicsEnabled = false;

	UPROPERTY()
	bool GravityEnabled = false;

	UPROPERTY()
	bool ImpulseApplied = false;

	UPROPERTY()
	bool ForceApplied = false;

	/**
	 * WorldStory: BeginPlay enables simulation and gravity, then applies an impulse
	 * and a force.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitivePhysics
	 * @Inputs a default-attached USphereComponent
	 * @Return all four flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SphereComp.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);

		// Enable physics simulation
		SphereComp.SetSimulatePhysics(true);
		PhysicsEnabled = SphereComp.IsSimulatingPhysics();

		// Enable gravity
		SphereComp.SetEnableGravity(true);
		GravityEnabled = SphereComp.IsGravityEnabled();

		// Apply impulse
		SphereComp.AddImpulse(FVector(0.0f, 0.0f, 1000.0f), NAME_None, false);
		ImpulseApplied = true;

		// Apply force
		SphereComp.AddForce(FVector(0.0f, 0.0f, 500.0f), NAME_None, false);
		ForceApplied = true;
	}

	/**
	 * Observe that a locally constructed actor has no flags and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitivePhysics
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all four flags are clear and SphereComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (PhysicsEnabled)
		{
			return false;
		}
		if (GravityEnabled)
		{
			return false;
		}
		if (ImpulseApplied)
		{
			return false;
		}
		if (ForceApplied)
		{
			return false;
		}
		return SphereComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitivePhysics
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds both flags and the other stays clear
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitivePhysicsActor Second)
	{
		if (Second is null)
		{
			throw("PrimitivePhysics setup: required Second is null");
		}
		PhysicsEnabled = true;
		ImpulseApplied = true;

		if (!PhysicsEnabled)
		{
			return false;
		}
		if (!ImpulseApplied)
		{
			return false;
		}
		if (Second.PhysicsEnabled)
		{
			return false;
		}
		return !Second.ImpulseApplied;
	}
}
/** @end */
/**
 * @begin primitive-physics-state-readback
 * @summary Simulation, gravity, mass and both velocity components read back off a sphere component. C++ verifies the six flags by path. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class ACoveragePrimitivePhysicsStateReadbackActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent SphereComp;

	UPROPERTY()
	bool SimulatePhysicsEnabled = false;

	UPROPERTY()
	bool SimulatePhysicsDisabled = false;

	UPROPERTY()
	bool GravityDisabled = false;

	UPROPERTY()
	bool MassOverrideRoundTripped = false;

	UPROPERTY()
	bool LinearVelocityRoundTripped = false;

	UPROPERTY()
	bool AngularVelocityRoundTripped = false;

	/**
	 * WorldStory: BeginPlay walks simulation, gravity, the mass override and both
	 * velocities, reading each back within a tolerance, then switches simulation off.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitivePhysicsStateReadback
	 * @Inputs a default-attached USphereComponent
	 * @Return all six flags true; mass 125, linear (120, 30, 0), angular (0, 45, 90)
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SphereComp.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		SphereComp.SetSimulatePhysics(true);
		SimulatePhysicsEnabled = SphereComp.IsSimulatingPhysics();

		SphereComp.SetEnableGravity(false);
		GravityDisabled = !SphereComp.IsGravityEnabled();

		SphereComp.SetMassOverrideInKg(NAME_None, 125.0f, true);
		float Mass = SphereComp.GetMass();
		MassOverrideRoundTripped = Mass > 124.0f && Mass < 126.0f;

		FVector TargetLinearVelocity = FVector(120.0f, 30.0f, 0.0f);
		SphereComp.SetPhysicsLinearVelocity(TargetLinearVelocity, false, NAME_None);
		FVector LinearVelocity = SphereComp.GetPhysicsLinearVelocity(NAME_None);
		LinearVelocityRoundTripped =
			LinearVelocity.X > 119.0f
			&& LinearVelocity.X < 121.0f
			&& LinearVelocity.Y > 29.0f
			&& LinearVelocity.Y < 31.0f;

		FVector TargetAngularVelocity = FVector(0.0f, 45.0f, 90.0f);
		SphereComp.SetPhysicsAngularVelocityInDegrees(TargetAngularVelocity, false, NAME_None);
		FVector AngularVelocity = SphereComp.GetPhysicsAngularVelocityInDegrees(NAME_None);
		AngularVelocityRoundTripped =
			AngularVelocity.Y > 44.0f
			&& AngularVelocity.Y < 46.0f
			&& AngularVelocity.Z > 89.0f
			&& AngularVelocity.Z < 91.0f;

		SphereComp.SetSimulatePhysics(false);
		SimulatePhysicsDisabled = !SphereComp.IsSimulatingPhysics();
	}

	/**
	 * Observe that a locally constructed actor has no flags and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitivePhysicsStateReadback
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all six flags are clear and SphereComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (SimulatePhysicsEnabled)
		{
			return false;
		}
		if (SimulatePhysicsDisabled)
		{
			return false;
		}
		if (GravityDisabled)
		{
			return false;
		}
		if (MassOverrideRoundTripped)
		{
			return false;
		}
		if (LinearVelocityRoundTripped)
		{
			return false;
		}
		if (AngularVelocityRoundTripped)
		{
			return false;
		}
		return SphereComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitivePhysicsStateReadback
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds both flags and the other stays clear
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitivePhysicsStateReadbackActor Second)
	{
		if (Second is null)
		{
			throw("PrimitivePhysicsStateReadback setup: required Second is null");
		}
		SimulatePhysicsEnabled = true;
		MassOverrideRoundTripped = true;

		if (!SimulatePhysicsEnabled)
		{
			return false;
		}
		if (!MassOverrideRoundTripped)
		{
			return false;
		}
		if (Second.SimulatePhysicsEnabled)
		{
			return false;
		}
		return !Second.MassOverrideRoundTripped;
	}
}
/** @end */
/**
 * @begin primitive-rendering
 * @summary Visibility, shadow casting and the custom depth setters on a static mesh component. C++ verifies the flags by path. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class ACoveragePrimitiveRenderingActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent MeshComp;

	UPROPERTY()
	bool InitiallyVisible = false;

	UPROPERTY()
	bool AfterSetVisible = false;

	UPROPERTY()
	bool InitiallyCastsShadow = false;

	UPROPERTY()
	bool AfterSetCastShadow = false;

	UPROPERTY()
	bool CustomDepthCallAccepted = false;

	/**
	 * WorldStory: BeginPlay reads the starting visibility, hides the mesh, disables
	 * its shadow, then turns on custom depth with a stencil value.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitiveRendering
	 * @Inputs a default-attached UStaticMeshComponent
	 * @Return InitiallyVisible true, AfterSetVisible false, AfterSetCastShadow true, CustomDepthCallAccepted true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitiallyVisible = MeshComp.IsVisible();

		MeshComp.SetVisibility(false);
		AfterSetVisible = MeshComp.IsVisible();

		MeshComp.SetCastShadow(false);
		AfterSetCastShadow = true;

		MeshComp.SetRenderCustomDepth(true);
		MeshComp.SetCustomDepthStencilValue(128);
		CustomDepthCallAccepted = true;
	}

	/**
	 * Observe that a locally constructed actor has no flags and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveRendering
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all five flags are clear and MeshComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (InitiallyVisible)
		{
			return false;
		}
		if (AfterSetVisible)
		{
			return false;
		}
		if (InitiallyCastsShadow)
		{
			return false;
		}
		if (AfterSetCastShadow)
		{
			return false;
		}
		if (CustomDepthCallAccepted)
		{
			return false;
		}
		return MeshComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveRendering
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds both flags and the other stays clear
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitiveRenderingActor Second)
	{
		if (Second is null)
		{
			throw("PrimitiveRendering setup: required Second is null");
		}
		CustomDepthCallAccepted = true;
		AfterSetCastShadow = true;

		if (!CustomDepthCallAccepted)
		{
			return false;
		}
		if (!AfterSetCastShadow)
		{
			return false;
		}
		if (Second.CustomDepthCallAccepted)
		{
			return false;
		}
		return !Second.AfterSetCastShadow;
	}
}
/** @end */
/**
 * @begin primitive-trace-object-query-readback
 * @summary FCollisionObjectQueryParams and FCollisionResponseContainer round-tripped, plus the trace channel enums read. C++ verifies the four flags by path. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class ACoveragePrimitiveTraceObjectQueryActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent SphereComp;

	UPROPERTY()
	bool TraceChannelsReadable = false;

	UPROPERTY()
	bool ObjectQueryChannelsValidated = false;

	UPROPERTY()
	bool ObjectQueryParamsRoundTripped = false;

	UPROPERTY()
	bool ResponseContainerRoundTripped = false;

	/**
	 * WorldStory: BeginPlay reads both trace channels, validates which channels are
	 * legal object queries, round-trips an object query bitfield and a response
	 * container, then resets the sphere's own collision state.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitiveTraceObjectQueryReadback
	 * @Inputs a default-attached USphereComponent
	 * @Return all four flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TraceChannelsReadable =
			int(ECollisionChannel::ECC_Visibility) >= 0
			&& int(ECollisionChannel::ECC_Camera) >= 0;

		ObjectQueryChannelsValidated =
			FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::ECC_WorldStatic)
			&& FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::ECC_WorldDynamic)
			&& FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::ECC_Pawn)
			&& FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::ECC_PhysicsBody)
			&& !FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::ECC_Visibility)
			&& !FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::ECC_Camera);

		FCollisionObjectQueryParams ObjectParams;
		ObjectParams.AddObjectTypesToQuery(ECollisionChannel::ECC_WorldStatic);
		ObjectParams.AddObjectTypesToQuery(ECollisionChannel::ECC_WorldDynamic);
		ObjectParams.AddObjectTypesToQuery(ECollisionChannel::ECC_Pawn);
		int64 BeforeRemove = ObjectParams.GetQueryBitfield64();
		ObjectParams.RemoveObjectTypesToQuery(ECollisionChannel::ECC_Pawn);
		int64 AfterRemove = ObjectParams.GetQueryBitfield64();
		ObjectQueryParamsRoundTripped =
			ObjectParams.IsValid()
			&& BeforeRemove != 0
			&& AfterRemove != 0
			&& BeforeRemove != AfterRemove
			&& ObjectParams.GetObjectTypesToQuery() == AfterRemove;

		FCollisionResponseContainer Responses(ECollisionResponse::ECR_Ignore);
		bool bSetVisibility = Responses.SetResponse(ECollisionChannel::ECC_Visibility, ECollisionResponse::ECR_Block);
		bool bSetPawn = Responses.SetResponse(ECollisionChannel::ECC_Pawn, ECollisionResponse::ECR_Overlap);
		bool bSetAll = Responses.SetAllChannels(ECollisionResponse::ECR_Block);
		ResponseContainerRoundTripped =
			bSetVisibility
			&& bSetPawn
			&& bSetAll
			&& Responses.GetResponse(ECollisionChannel::ECC_Visibility) == ECollisionResponse::ECR_Block
			&& Responses.GetResponse(ECollisionChannel::ECC_Pawn) == ECollisionResponse::ECR_Block
			&& Responses.GetResponse(ECollisionChannel::ECC_Camera) == ECollisionResponse::ECR_Block;

		SphereComp.SetCollisionObjectType(ECollisionChannel::ECC_WorldDynamic);
		SphereComp.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Ignore);
	}

	/**
	 * Observe that a locally constructed actor has no flags and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveTraceObjectQueryReadback
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all four flags are clear and SphereComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (TraceChannelsReadable)
		{
			return false;
		}
		if (ObjectQueryChannelsValidated)
		{
			return false;
		}
		if (ObjectQueryParamsRoundTripped)
		{
			return false;
		}
		if (ResponseContainerRoundTripped)
		{
			return false;
		}
		return SphereComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveTraceObjectQueryReadback
	 * @Inputs this actor plus a second actor
	 * @Return true when this is flagged and the other is not
	 * @Param Second the other actor, expected to stay unflagged
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitiveTraceObjectQueryActor Second)
	{
		if (Second is null)
		{
			throw("PrimitiveTraceObjectQueryReadback setup: required Second is null");
		}
		TraceChannelsReadable = true;

		if (!TraceChannelsReadable)
		{
			return false;
		}
		return !Second.TraceChannelsReadable;
	}
}
/** @end */
/**
 * @begin receive-end-play
 * @summary A component whose EndPlay sets bCleanedUp. C++ begins play, destroys the host and ticks the world, then verifies bCleanedUp through its path. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class UTestComponentReceiveEndPlay : UActorComponent
{
	UPROPERTY()
	bool bCleanedUp = false;

	/**
	 * WorldStory: EndPlay flips bCleanedUp to true.
	 *
	 * @Kind WorldStory
	 * @Covers Component.ReceiveEndPlay
	 * @Inputs the end play reason supplied by the engine
	 * @Return bCleanedUp == true once EndPlay has run
	 * @Param Reason why the component is ending play
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		bCleanedUp = true;
	}

	/**
	 * Observe that a locally constructed component has not cleaned up.
	 *
	 * @Kind Observe
	 * @Covers Component.ReceiveEndPlay
	 * @Inputs a component that has not ended play
	 * @Return true when bCleanedUp is false
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		return bCleanedUp == false;
	}

	/**
	 * Observe that writing this component leaves another component untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.ReceiveEndPlay
	 * @Inputs this component plus a second component
	 * @Return true when this is cleaned up and the other is not
	 * @Param Second the other component, expected to stay unflagged
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UTestComponentReceiveEndPlay Second)
	{
		if (Second is null)
		{
			throw("ReceiveEndPlay setup: required Second is null");
		}
		bCleanedUp = true;

		if (!bCleanedUp)
		{
			return false;
		}
		return Second.bCleanedUp == false;
	}
}
/** @end */
/**
 * @begin return-components-to-cpp
 * @summary Typed components and component arrays returned to C++. The entrypoint names are part of the C++ contract and are kept verbatim. The observers cover the local-construct default and the empty-name lookup vector.
 * @topic Component
 */
UCLASS()
class UReturnComponentBase : USceneComponent
{
}

/**
 * The derived component whose identity C++ checks separately from the base.
 *
 * @Covers Component.ReturnComponentsToCpp
 * @Inputs none
 * @Return a component derived from UReturnComponentBase
 */
UCLASS()
class UReturnComponentDerived : UReturnComponentBase
{
}

UCLASS()
class ATestActorReturnComponentsToCpp : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UReturnComponentBase BaseA;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UReturnComponentBase BaseB;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UReturnComponentDerived DerivedA;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UReturnComponentDerived DerivedB;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UBillboardComponent BillboardA;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UBillboardComponent BillboardB;

	UPROPERTY()
	TArray<UActorComponent> StoredBaseFamily;

	UPROPERTY()
	TArray<UActorComponent> StoredAllComponents;

	UPROPERTY()
	TArray<UActorComponent> StoredBillboards;

	/**
	 * Return the first base component to C++.
	 *
	 * @Kind Observe
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs none
	 * @Return BaseA, or null before the actor is spawned
	 */
	UFUNCTION()
	UActorComponent ReturnBaseAForCpp()
	{
		return BaseA;
	}

	/**
	 * Return the second derived component to C++.
	 *
	 * @Kind Observe
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs none
	 * @Return DerivedB, or null before the actor is spawned
	 */
	UFUNCTION()
	UActorComponent ReturnDerivedBForCpp()
	{
		return DerivedB;
	}

	/**
	 * Resolve a component by name for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs a component name to look up
	 * @Return the named component, or null when the name does not resolve
	 * @Param ComponentName the name to look up
	 */
	UFUNCTION()
	UActorComponent ReturnComponentByNameForCpp(FName ComponentName)
	{
		return GetComponent(UActorComponent::StaticClass(), ComponentName);
	}

	/**
	 * Create and return an explicitly named scene component for C++.
	 *
	 * @Kind Action
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs none
	 * @Return the new scene component named CppExplicitNamedScene
	 */
	UFUNCTION()
	USceneComponent ReturnCreatedNamedSceneForCpp()
	{
		return Cast<USceneComponent>(CreateComponent(USceneComponent::StaticClass(), n"CppExplicitNamedScene"));
	}

	/**
	 * Fill an array with the base component family for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs an array to fill
	 * @Return every UReturnComponentBase in the actor
	 * @Param OutComponents the array to fill
	 */
	UFUNCTION()
	void ReturnBaseFamilyArrayForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(UReturnComponentBase::StaticClass(), OutComponents);
	}

	/**
	 * Fill an array with every component for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs an array to fill
	 * @Return every UActorComponent in the actor
	 * @Param OutComponents the array to fill
	 */
	UFUNCTION()
	void ReturnAllComponentsArrayForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(UActorComponent::StaticClass(), OutComponents);
	}

	/**
	 * Append the billboard components onto an array for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs an array to append onto
	 * @Return the billboards appended to whatever the array already held
	 * @Param OutComponents the array to append onto
	 */
	UFUNCTION()
	void AppendBillboardArrayForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(UBillboardComponent::StaticClass(), OutComponents);
	}

	/**
	 * Store three query results on the actor so C++ can inspect them afterwards.
	 *
	 * @Kind Action
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs none
	 * @Return StoredBaseFamily, StoredAllComponents and StoredBillboards refilled
	 */
	UFUNCTION()
	void StoreComponentArraysForCpp()
	{
		StoredBaseFamily.Empty();
		GetAllComponents(UReturnComponentBase::StaticClass(), StoredBaseFamily);

		StoredAllComponents.Empty();
		GetAllComponents(UActorComponent::StaticClass(), StoredAllComponents);

		StoredBillboards.Empty();
		GetAllComponents(UBillboardComponent::StaticClass(), StoredBillboards);
	}

	/**
	 * Observe that a locally constructed actor has stored nothing and holds no components.
	 *
	 * @Kind Observe
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs an actor that has not been spawned
	 * @Return true when all three arrays are empty and all four lookups return null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (StoredBaseFamily.Num() != 0)
		{
			return false;
		}
		if (StoredAllComponents.Num() != 0)
		{
			return false;
		}
		if (StoredBillboards.Num() != 0)
		{
			return false;
		}
		if (BaseA != nullptr)
		{
			return false;
		}
		if (DerivedB != nullptr)
		{
			return false;
		}
		if (ReturnBaseAForCpp() != nullptr)
		{
			return false;
		}
		if (ReturnDerivedBForCpp() != nullptr)
		{
			return false;
		}
		return ReturnComponentByNameForCpp(n"Missing") == nullptr;
	}

	/**
	 * Observe that looking up an empty name does not resolve.
	 *
	 * @Kind Observe
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs an unset component name
	 * @Return true when the lookup returns null
	 * @Boundary empty name
	 */
	UFUNCTION()
	bool MissingNameNull()
	{
		return ReturnComponentByNameForCpp(n"") == nullptr;
	}
}
/** @end */
/**
 * @begin scene-component-complete-transform
 * @summary A complete world transform set on a scene component and read back through GetComponentTransform. C++ verifies the final location, rotation and scale. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class ACoverageSceneComponentCompleteTransformActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY()
	FVector FinalLocation;

	UPROPERTY()
	FRotator FinalRotation;

	UPROPERTY()
	FVector FinalScale;

	/**
	 * WorldStory: BeginPlay builds a complete transform, applies it without sweeping,
	 * then reads it back and stores the three parts.
	 *
	 * @Kind WorldStory
	 * @Covers Component.SceneComponentCompleteTransform
	 * @Inputs a default-attached USceneComponent
	 * @Return FinalLocation (100, 200, 300), FinalRotation ~(10, 20, 30), FinalScale (1.5, 1.5, 1.5)
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Create and set a complete transform
		FTransform NewTransform;
		NewTransform.SetLocation(FVector(100.0f, 200.0f, 300.0f));
		NewTransform.SetRotation(FQuat(FRotator(10.0f, 20.0f, 30.0f)));
		NewTransform.SetScale3D(FVector(1.5f, 1.5f, 1.5f));

		// SetWorldTransform is a reflective K2_ bind requiring the sweep/teleport
		// arguments (FHitResult&out has no AS default).
		FHitResult SweepHit;
		Root.SetWorldTransform(NewTransform, false, SweepHit, false);

		// Read back using GetComponentTransform
		FTransform CurrentTransform = Root.GetComponentTransform();
		FinalLocation = CurrentTransform.GetLocation();
		FinalRotation = CurrentTransform.GetRotation().Rotator();
		FinalScale = CurrentTransform.GetScale3D();
	}

	/**
	 * Observe that a locally constructed actor holds no transform and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentCompleteTransform
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when location, rotation and scale are zero and Root is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (FinalLocation.X != 0.0f)
		{
			return false;
		}
		if (FinalRotation.Pitch != 0.0f)
		{
			return false;
		}
		if (FinalScale.X != 0.0f)
		{
			return false;
		}
		return Root == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentCompleteTransform
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the transform and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSceneComponentCompleteTransformActor Second)
	{
		if (Second is null)
		{
			throw("SceneComponentCompleteTransform setup: required Second is null");
		}
		FinalLocation = FVector(100.0f, 200.0f, 300.0f);
		FinalScale = FVector(1.5f, 1.5f, 1.5f);

		if (FinalLocation.X != 100.0f)
		{
			return false;
		}
		if (FinalScale.X != 1.5f)
		{
			return false;
		}
		if (Second.FinalLocation.X != 0.0f)
		{
			return false;
		}
		return Second.FinalScale.X == 0.0f;
	}
}
/** @end */
/**
 * @begin scene-component-hierarchy
 * @summary GetAttachParent and GetChildrenComponents across a root with two children and one grandchild. C++ verifies both parent links and both child counts. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class ACoverageSceneComponentHierarchyActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child1;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child2;

	UPROPERTY(DefaultComponent, Attach=Child1)
	USceneComponent GrandChild;

	UPROPERTY()
	bool Child1HasParent = false;

	UPROPERTY()
	bool GrandChildParentIsChild1 = false;

	UPROPERTY()
	int RootChildrenCount = 0;

	UPROPERTY()
	int Child1ChildrenCount = 0;

	/**
	 * WorldStory: BeginPlay walks both attach parents and counts the children at two
	 * levels of the hierarchy.
	 *
	 * @Kind WorldStory
	 * @Covers Component.SceneComponentHierarchy
	 * @Inputs four default-attached scene components
	 * @Return both parent flags true, RootChildrenCount 2, Child1ChildrenCount 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		USceneComponent Child1Parent = Child1.GetAttachParent();
		Child1HasParent = (Child1Parent == Root);

		USceneComponent GrandChildParent = GrandChild.GetAttachParent();
		GrandChildParentIsChild1 = (GrandChildParent == Child1);

		TArray<USceneComponent> RootChildren;
		Root.GetChildrenComponents(false, RootChildren);
		RootChildrenCount = RootChildren.Num();

		TArray<USceneComponent> Child1Children;
		Child1.GetChildrenComponents(false, Child1Children);
		Child1ChildrenCount = Child1Children.Num();
	}

	/**
	 * Observe that a locally constructed actor has no counts, no flags and no handles.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentHierarchy
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both flags are clear, both counts are 0 and all four handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (Child1HasParent)
		{
			return false;
		}
		if (GrandChildParentIsChild1)
		{
			return false;
		}
		if (RootChildrenCount != 0)
		{
			return false;
		}
		if (Child1ChildrenCount != 0)
		{
			return false;
		}
		if (Root != nullptr)
		{
			return false;
		}
		if (Child1 != nullptr)
		{
			return false;
		}
		if (Child2 != nullptr)
		{
			return false;
		}
		return GrandChild == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentHierarchy
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the walked state and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSceneComponentHierarchyActor Second)
	{
		if (Second is null)
		{
			throw("SceneComponentHierarchy setup: required Second is null");
		}
		RootChildrenCount = 2;
		Child1HasParent = true;

		if (RootChildrenCount != 2)
		{
			return false;
		}
		if (!Child1HasParent)
		{
			return false;
		}
		if (Second.RootChildrenCount != 0)
		{
			return false;
		}
		return !Second.Child1HasParent;
	}
}
/** @end */
/**
 * @begin scene-component-relative-transform
 * @summary A child component's relative location and rotation versus the world location it resolves to. C++ verifies all three. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class ACoverageSceneComponentRelativeTransformActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child;

	UPROPERTY()
	FVector ChildRelativeLocation;

	UPROPERTY()
	FRotator ChildRelativeRotation;

	UPROPERTY()
	FVector ChildWorldLocation;

	/**
	 * WorldStory: BeginPlay moves the root to a known position, sets the child's
	 * relative transform, then reads both back along with the resolved world
	 * location.
	 *
	 * @Kind WorldStory
	 * @Covers Component.SceneComponentRelativeTransform
	 * @Inputs a root and an attached child scene component
	 * @Return ChildRelativeLocation (50, 0, 0), ChildRelativeRotation yaw 45, ChildWorldLocation (150, 0, 0)
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Set root to known position
		FHitResult SweepHit;
		Root.SetWorldLocation(FVector(100.0f, 0.0f, 0.0f), false, SweepHit, false);

		// Set child relative transform
		Child.SetRelativeLocation(FVector(50.0f, 0.0f, 0.0f));
		Child.SetRelativeRotation(FRotator(0.0f, 45.0f, 0.0f));

		// Read back
		ChildRelativeLocation = Child.RelativeLocation;
		ChildRelativeRotation = Child.RelativeRotation;
		ChildWorldLocation = Child.GetWorldLocation();
	}

	/**
	 * Observe that a locally constructed actor holds no transform and no components.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentRelativeTransform
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all three transforms are zero and both handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ChildRelativeLocation.X != 0.0f)
		{
			return false;
		}
		if (ChildRelativeRotation.Yaw != 0.0f)
		{
			return false;
		}
		if (ChildWorldLocation.X != 0.0f)
		{
			return false;
		}
		if (Root != nullptr)
		{
			return false;
		}
		return Child == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentRelativeTransform
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the relative location and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSceneComponentRelativeTransformActor Second)
	{
		if (Second is null)
		{
			throw("SceneComponentRelativeTransform setup: required Second is null");
		}
		ChildRelativeLocation = FVector(50.0f, 0.0f, 0.0f);

		if (ChildRelativeLocation.X != 50.0f)
		{
			return false;
		}
		return Second.ChildRelativeLocation.X == 0.0f;
	}
}
/** @end */
/**
 * @begin scene-component-tags
 * @summary Component tags added to a root and a child scene component, then queried and counted. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this actor and verifies the results by path, so this is a value oracle.
 * @topic Component
 */
UCLASS()
class ACoverageSceneComponentTagsActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child;

	UPROPERTY()
	bool RootHasCoverageTag = false;

	UPROPERTY()
	bool ChildHasCoverageTag = false;

	UPROPERTY()
	bool ChildRejectsMissingTag = false;

	UPROPERTY()
	int RootTagCount = 0;

	UPROPERTY()
	int ChildTagCount = 0;

	/**
	 * WorldStory: BeginPlay tags the root once and the child twice, then queries both
	 * plus a tag that was never added.
	 *
	 * @Kind WorldStory
	 * @Covers Component.SceneComponentTags
	 * @Inputs a root and an attached child scene component
	 * @Return both present tags found, the missing tag rejected, RootTagCount 1, ChildTagCount 2
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Root.ComponentTags.Add(n"RootCoverageTag");
		Child.ComponentTags.Add(n"SceneCoverageTag");
		Child.ComponentTags.Add(n"SharedCoverageTag");

		RootHasCoverageTag = Root.ComponentHasTag(n"RootCoverageTag");
		ChildHasCoverageTag = Child.ComponentHasTag(n"SceneCoverageTag");
		ChildRejectsMissingTag = !Child.ComponentHasTag(n"MissingCoverageTag");
		RootTagCount = Root.ComponentTags.Num();
		ChildTagCount = Child.ComponentTags.Num();
	}

	/**
	 * Observe that a locally constructed actor holds no tags and no components.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentTags
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all flags are clear, both counts are 0 and both handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (RootHasCoverageTag)
		{
			return false;
		}
		if (ChildHasCoverageTag)
		{
			return false;
		}
		if (ChildRejectsMissingTag)
		{
			return false;
		}
		if (RootTagCount != 0)
		{
			return false;
		}
		if (ChildTagCount != 0)
		{
			return false;
		}
		if (Root != nullptr)
		{
			return false;
		}
		return Child == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentTags
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the tagged state and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSceneComponentTagsActor Second)
	{
		if (Second is null)
		{
			throw("SceneComponentTags setup: required Second is null");
		}
		RootHasCoverageTag = true;
		ChildTagCount = 2;

		if (!RootHasCoverageTag)
		{
			return false;
		}
		if (ChildTagCount != 2)
		{
			return false;
		}
		if (Second.RootHasCoverageTag)
		{
			return false;
		}
		return Second.ChildTagCount == 0;
	}
}
/** @end */
/**
 * @begin scene-component-world-transform
 * @summary World location, rotation and scale set with explicit sweep arguments, then read back. SetWorldLocation and SetWorldRotation are reflective K2_ binds whose FHitResult&out sweep parameter has no script default, so all four.
 * @topic Component
 */
UCLASS()
class ACoverageSceneComponentWorldTransformActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY()
	FVector InitialLocation;

	UPROPERTY()
	FVector NewLocation;

	UPROPERTY()
	FRotator NewRotation;

	UPROPERTY()
	FVector NewScale;

	/**
	 * WorldStory: BeginPlay reads the starting location, writes all three world
	 * transform parts, then reads them back.
	 *
	 * @Kind WorldStory
	 * @Covers Component.SceneComponentWorldTransform
	 * @Inputs a default-attached USceneComponent
	 * @Return NewLocation (100, 200, 300), NewRotation (0, 90, 0), NewScale (2, 2, 2)
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitialLocation = Root.GetWorldLocation();

		// Set world transform. SetWorldLocation/SetWorldRotation are reflective
		// K2_ binds with a required FHitResult&out sweep param (no AS defaults on
		// out params), so all four arguments must be supplied explicitly.
		FHitResult SweepHit;
		Root.SetWorldLocation(FVector(100.0f, 200.0f, 300.0f), false, SweepHit, false);
		Root.SetWorldRotation(FRotator(0.0f, 90.0f, 0.0f), false, SweepHit, false);
		Root.SetWorldScale3D(FVector(2.0f, 2.0f, 2.0f));

		// Read back
		NewLocation = Root.GetWorldLocation();
		NewRotation = Root.GetWorldRotation();
		// No direct world-scale getter is AS-bound; derive it from the world transform.
		NewScale = Root.GetComponentTransform().GetScale3D();
	}

	/**
	 * Observe that a locally constructed actor holds no transform and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentWorldTransform
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when location, rotation and scale are all zero and Root is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (NewLocation.X != 0.0f)
		{
			return false;
		}
		if (NewLocation.Y != 0.0f)
		{
			return false;
		}
		if (NewLocation.Z != 0.0f)
		{
			return false;
		}
		if (NewRotation.Yaw != 0.0f)
		{
			return false;
		}
		if (NewScale.X != 0.0f)
		{
			return false;
		}
		return Root == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentWorldTransform
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the new location and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSceneComponentWorldTransformActor Second)
	{
		if (Second is null)
		{
			throw("SceneComponentWorldTransform setup: required Second is null");
		}
		NewLocation = FVector(100.0f, 200.0f, 300.0f);

		if (NewLocation.X != 100.0f)
		{
			return false;
		}
		if (Second.NewLocation.X != 0.0f)
		{
			return false;
		}
		return Second.NewScale.X == 0.0f;
	}
}
/** @end */
/**
 * @begin special-component-operations
 * @summary Arrow, audio and input components tagged and looked up by class, plus a runtime arrow built with NewObject that is attached, activated, deactivated and destroyed. C++ verifies the flags and the tagged count. The.
 * @topic Component
 */
UCLASS()
class ACoverageSpecialComponentOperationsActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UArrowComponent Arrow;

	UPROPERTY(DefaultComponent, Attach=Root)
	UAudioComponent Audio;

	UPROPERTY(DefaultComponent)
	UInputComponent Input;

	UPROPERTY()
	UArrowComponent RuntimeArrow;

	UPROPERTY()
	bool FoundAudioByClass = false;

	UPROPERTY()
	int TaggedSpecialComponentCount = 0;

	UPROPERTY()
	bool ArrowHasTag = false;

	UPROPERTY()
	bool AudioOwnerMatched = false;

	UPROPERTY()
	bool InputOwnerMatched = false;

	UPROPERTY()
	bool AudioWorldMatched = false;

	UPROPERTY()
	bool RuntimeArrowCreated = false;

	UPROPERTY()
	bool RuntimeArrowActivated = false;

	UPROPERTY()
	bool RuntimeArrowDeactivated = false;

	UPROPERTY()
	bool RuntimeArrowDestroyed = false;

	/**
	 * WorldStory: BeginPlay tags all three special components, resolves the audio one
	 * by class, counts the tagged components, then walks a runtime arrow through its
	 * whole lifecycle.
	 *
	 * @Kind WorldStory
	 * @Covers Component.SpecialComponentOperations
	 * @Inputs three default components plus a NewObject arrow
	 * @Return all flags true and TaggedSpecialComponentCount == 3
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (Arrow != nullptr)
		{
			Arrow.ComponentTags.Add(n"SpecialCoverage");
			ArrowHasTag = Arrow.ComponentHasTag(n"SpecialCoverage");
		}

		if (Audio != nullptr)
		{
			Audio.ComponentTags.Add(n"SpecialCoverage");
			Audio.SetVolumeMultiplier(0.25f);
			Audio.Stop();
			AudioOwnerMatched = Audio.GetOwner() == this;
			AudioWorldMatched = Audio.GetWorld() == GetWorld();
		}

		if (Input != nullptr)
		{
			Input.ComponentTags.Add(n"SpecialCoverage");
			InputOwnerMatched = Input.GetOwner() == this;
		}

		FoundAudioByClass = Cast<UAudioComponent>(GetComponentByClass(UAudioComponent::StaticClass())) == Audio;

		TArray<UActorComponent> TaggedComponents = GetComponentsByTag(UActorComponent::StaticClass(), n"SpecialCoverage");
		TaggedSpecialComponentCount = TaggedComponents.Num();

		RuntimeArrow = Cast<UArrowComponent>(NewObject(this, UArrowComponent::StaticClass(), n"RuntimeArrow", true));
		RuntimeArrowCreated = RuntimeArrow != nullptr;
		if (RuntimeArrow == nullptr)
		{
			return;
		}

		RuntimeArrow.AttachToComponent(Root, NAME_None, EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, false);

		RuntimeArrow.Activate(true);
		RuntimeArrowActivated = RuntimeArrow.IsActive();

		RuntimeArrow.Deactivate();
		RuntimeArrowDeactivated = !RuntimeArrow.IsActive();

		RuntimeArrow.DestroyComponent();
		RuntimeArrowDestroyed = RuntimeArrow.IsBeingDestroyed();
	}

	/**
	 * Observe that a locally constructed actor has no flags, no count and no components.
	 *
	 * @Kind Observe
	 * @Covers Component.SpecialComponentOperations
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all flags are clear, the count is 0 and all five handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (FoundAudioByClass)
		{
			return false;
		}
		if (TaggedSpecialComponentCount != 0)
		{
			return false;
		}
		if (ArrowHasTag)
		{
			return false;
		}
		if (AudioOwnerMatched)
		{
			return false;
		}
		if (InputOwnerMatched)
		{
			return false;
		}
		if (AudioWorldMatched)
		{
			return false;
		}
		if (RuntimeArrowCreated)
		{
			return false;
		}
		if (RuntimeArrowActivated)
		{
			return false;
		}
		if (RuntimeArrowDeactivated)
		{
			return false;
		}
		if (RuntimeArrowDestroyed)
		{
			return false;
		}
		if (RuntimeArrow != nullptr)
		{
			return false;
		}
		if (Root != nullptr)
		{
			return false;
		}
		if (Arrow != nullptr)
		{
			return false;
		}
		if (Audio != nullptr)
		{
			return false;
		}
		return Input == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.SpecialComponentOperations
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the found state and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialComponentOperationsActor Second)
	{
		if (Second is null)
		{
			throw("SpecialComponentOperations setup: required Second is null");
		}
		FoundAudioByClass = true;
		TaggedSpecialComponentCount = 3;

		if (!FoundAudioByClass)
		{
			return false;
		}
		if (TaggedSpecialComponentCount != 3)
		{
			return false;
		}
		if (Second.FoundAudioByClass)
		{
			return false;
		}
		return Second.TaggedSpecialComponentCount == 0;
	}
}
/** @end */
/**
 * @begin sphere-component
 * @summary SetSphereRadius and GetUnscaledSphereRadius on a sphere component. C++ verifies the new radius. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class ACoverageSpecialSphereActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent SphereComp;

	UPROPERTY()
	float InitialRadius = 0.0f;

	UPROPERTY()
	float NewRadius = 0.0f;

	/**
	 * WorldStory: BeginPlay reads the starting radius, resizes the sphere, then reads
	 * it back.
	 *
	 * @Kind WorldStory
	 * @Covers Component.SphereComponent
	 * @Inputs a default-attached USphereComponent
	 * @Return NewRadius == 150
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitialRadius = SphereComp.GetUnscaledSphereRadius();

		SphereComp.SetSphereRadius(150.0f);

		NewRadius = SphereComp.GetUnscaledSphereRadius();
	}

	/**
	 * Observe that a locally constructed actor has no radii and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.SphereComponent
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both radii are 0 and SphereComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (InitialRadius != 0.0f)
		{
			return false;
		}
		if (NewRadius != 0.0f)
		{
			return false;
		}
		return SphereComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.SphereComponent
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the new radius and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialSphereActor Second)
	{
		if (Second is null)
		{
			throw("SphereComponent setup: required Second is null");
		}
		NewRadius = 150.0f;

		if (NewRadius != 150.0f)
		{
			return false;
		}
		return Second.NewRadius == 0.0f;
	}
}
/** @end */
/**
 * @begin spring-arm-component
 * @summary TargetArmLength and CameraLagSpeed written and read on a spring arm component. C++ verifies both. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class ACoverageSpecialSpringArmActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USpringArmComponent SpringArmComp;

	UPROPERTY()
	float InitialArmLength = 0.0f;

	UPROPERTY()
	float NewArmLength = 0.0f;

	UPROPERTY()
	float CameraLagSpeed = 0.0f;

	/**
	 * WorldStory: BeginPlay reads the starting arm length, writes both properties,
	 * then reads them back.
	 *
	 * @Kind WorldStory
	 * @Covers Component.SpringArmComponent
	 * @Inputs an attached USpringArmComponent
	 * @Return NewArmLength == 500 and CameraLagSpeed == 8
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (SpringArmComp != nullptr)
		{
			InitialArmLength = SpringArmComp.TargetArmLength;

			SpringArmComp.TargetArmLength = 500.0f;
			SpringArmComp.CameraLagSpeed = 8.0f;

			NewArmLength = SpringArmComp.TargetArmLength;
			CameraLagSpeed = SpringArmComp.CameraLagSpeed;
		}
	}

	/**
	 * Observe that a locally constructed actor has no values and no components.
	 *
	 * @Kind Observe
	 * @Covers Component.SpringArmComponent
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all three values are 0 and both handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (InitialArmLength != 0.0f)
		{
			return false;
		}
		if (NewArmLength != 0.0f)
		{
			return false;
		}
		if (CameraLagSpeed != 0.0f)
		{
			return false;
		}
		if (SpringArmComp != nullptr)
		{
			return false;
		}
		return Root == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.SpringArmComponent
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds both values and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialSpringArmActor Second)
	{
		if (Second is null)
		{
			throw("SpringArmComponent setup: required Second is null");
		}
		NewArmLength = 500.0f;
		CameraLagSpeed = 8.0f;

		if (NewArmLength != 500.0f)
		{
			return false;
		}
		if (CameraLagSpeed != 8.0f)
		{
			return false;
		}
		if (Second.NewArmLength != 0.0f)
		{
			return false;
		}
		return Second.CameraLagSpeed == 0.0f;
	}
}
/** @end */
/**
 * @begin static-mesh-component
 * @summary GetNumMaterials on a static mesh component that has no asset assigned. C++ verifies the count and the native null mesh. The observers cover the declared defaults and copy independence.
 * @topic Component
 */
UCLASS()
class ACoverageSpecialStaticMeshActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent MeshComp;

	UPROPERTY()
	bool MeshWasNull = true;

	UPROPERTY()
	int MaterialCount = 0;

	/**
	 * WorldStory: BeginPlay reads the material count off a component with no mesh
	 * assigned.
	 *
	 * @Kind WorldStory
	 * @Covers Component.StaticMeshComponent
	 * @Inputs a default-attached UStaticMeshComponent with no asset
	 * @Return MaterialCount == 0
	 * @Boundary no asset assigned
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Get material count
		MaterialCount = MeshComp.GetNumMaterials();
	}

	/**
	 * Observe that a locally constructed actor keeps its declared defaults.
	 *
	 * @Kind Observe
	 * @Covers Component.StaticMeshComponent
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when MeshWasNull is true, the count is 0 and MeshComp is null
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (!MeshWasNull)
		{
			return false;
		}
		if (MaterialCount != 0)
		{
			return false;
		}
		return MeshComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.StaticMeshComponent
	 * @Inputs this actor plus a second actor
	 * @Return true when this is flipped and the other keeps its declared defaults
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialStaticMeshActor Second)
	{
		if (Second is null)
		{
			throw("StaticMeshComponent setup: required Second is null");
		}
		MeshWasNull = false;
		MaterialCount = 1;

		if (MeshWasNull)
		{
			return false;
		}
		if (MaterialCount != 1)
		{
			return false;
		}
		if (!Second.MeshWasNull)
		{
			return false;
		}
		return Second.MaterialCount == 0;
	}
}
/** @end */
/**
 * @begin static-typed-accessors-create-get-and-reuse
 * @summary Typed Create, Get and GetOrCreate accessors, where the latter two must return the same object the first one made. C++ runs the entrypoint and expects 1. The observers cover the local-construct default and copy.
 * @topic Component
 */
UCLASS()
class UTestActorComponentManagementTypedScene : USceneComponent
{
}

UCLASS()
class ATestActorComponentManagementTypedAccessors : AActor
{
	UPROPERTY()
	UTestActorComponentManagementTypedScene Created;

	UPROPERTY()
	UTestActorComponentManagementTypedScene Found;

	UPROPERTY()
	UTestActorComponentManagementTypedScene Reused;

	/**
	 * Create a typed component, then resolve it twice more and confirm all three
	 * handles are the same object.
	 *
	 * @Kind Observe
	 * @Covers Component.StaticTypedAccessorsCreateGetAndReuse
	 * @Inputs none
	 * @Return 1 on success; 10, 20 or 30 naming the step that failed
	 */
	UFUNCTION()
	int RunTypedAccessorTest()
	{
		Created = UTestActorComponentManagementTypedScene::Create(this, n"TypedScene");
		if (Created == nullptr)
		{
			return 10;
		}

		Found = UTestActorComponentManagementTypedScene::Get(this, n"TypedScene");
		if (Found == nullptr || Found != Created)
		{
			return 20;
		}

		Reused = UTestActorComponentManagementTypedScene::GetOrCreate(this, n"TypedScene");
		if (Reused == nullptr || Reused != Created)
		{
			return 30;
		}

		return 1;
	}

	/**
	 * Observe that a locally constructed actor holds none of the three handles.
	 *
	 * @Kind Observe
	 * @Covers Component.StaticTypedAccessorsCreateGetAndReuse
	 * @Inputs an actor that has not run the entrypoint
	 * @Return true when all three handles are null
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultNull()
	{
		if (Created != nullptr)
		{
			return false;
		}
		if (Found != nullptr)
		{
			return false;
		}
		return Reused == nullptr;
	}

	/**
	 * Observe that a second instance keeps its own independent null handles.
	 *
	 * @Kind Observe
	 * @Covers Component.StaticTypedAccessorsCreateGetAndReuse
	 * @Inputs this actor plus a second actor
	 * @Return true when all six handles are null
	 * @Param Second the other actor, also expected to hold null handles
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestActorComponentManagementTypedAccessors Second)
	{
		if (Second is null)
		{
			throw("StaticTypedAccessorsCreateGetAndReuse setup: required Second is null");
		}
		Created = Found;

		if (Created != nullptr)
		{
			return false;
		}
		if (Second.Created != nullptr)
		{
			return false;
		}
		if (Second.Found != nullptr)
		{
			return false;
		}
		return Second.Reused == nullptr;
	}
}
/** @end */
/**
 * @begin tick
 * @summary A component Tick override incrementing a counter. C++ enables ticking, ticks the world five times and verifies the count by path. The observers cover the local-construct default and copy independence.
 * @topic Component
 */
UCLASS()
class UTestComponentTick : UActorComponent
{
	UPROPERTY()
	int TickCount = 0;

	/**
	 * WorldStory: Tick increments the counter once per dispatch.
	 *
	 * @Kind WorldStory
	 * @Covers Component.Tick
	 * @Inputs the frame delta, unused
	 * @Return TickCount incremented once per tick
	 * @Param DeltaSeconds the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCount += 1;
	}

	/**
	 * Observe that a locally constructed component has not ticked.
	 *
	 * @Kind Observe
	 * @Covers Component.Tick
	 * @Inputs a component that has not been ticked
	 * @Return true when TickCount is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return TickCount == 0;
	}

	/**
	 * Observe that writing this component leaves another component untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.Tick
	 * @Inputs this component plus a second component
	 * @Return true when this counts 5 and the other stays at 0
	 * @Param Second the other component, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UTestComponentTick Second)
	{
		if (Second is null)
		{
			throw("Tick setup: required Second is null");
		}
		TickCount = 5;

		if (TickCount != 5)
		{
			return false;
		}
		return Second.TickCount == 0;
	}
}
/** @end */
/**
 * @begin timer-compile-stable-actor-and-component-call-sites
 * @summary System::SetTimer call sites on both a component and an actor, compiled and run to confirm the call shapes stay stable. The CSV NegativeDiagnostic label is a heuristic: C++ compiles these and verifies the flags by path.
 * @topic Component
 */
UCLASS()
class UCoverageTimerComponentCallSite : UActorComponent
{
	FTimerHandle ComponentHandle;

	/**
	 * The callback the component timer fires into.
	 *
	 * @Kind EventHandler
	 * @Covers Component.TimerCompileStableCallSites
	 * @Inputs none
	 * @Return nothing; the timer reaching it is what the test observes
	 */
	UFUNCTION()
	void ComponentCallback()
	{
	}

	/**
	 * Set up the component timer, walk the pause and clear calls, and confirm the
	 * reported state at each step.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerCompileStableCallSites
	 * @Inputs none
	 * @Return true when the timer was active, paused on request, reported sane
	 * remaining and elapsed times, and no longer exists after being cleared
	 */
	UFUNCTION()
	bool ConfigureComponentTimer()
	{
		ComponentHandle = System::SetTimer(this, n"ComponentCallback", 1.0f, true);
		bool bActive = SystemLibrary::IsTimerActiveHandle(ComponentHandle);
		float Remaining = SystemLibrary::GetTimerRemainingTimeHandle(ComponentHandle);
		float Elapsed = SystemLibrary::GetTimerElapsedTimeHandle(ComponentHandle);

		System::PauseTimerHandle(ComponentHandle);
		bool bPaused = System::IsTimerPausedHandle(ComponentHandle);
		System::UnPauseTimerHandle(ComponentHandle);
		System::ClearAndInvalidateTimerHandle(ComponentHandle);

		if (!bActive)
		{
			return false;
		}
		if (!bPaused)
		{
			return false;
		}
		if (Remaining < 0.0f)
		{
			return false;
		}
		if (Elapsed < 0.0f)
		{
			return false;
		}
		return !SystemLibrary::TimerExistsHandle(ComponentHandle);
	}
}

UCLASS()
class ACoverageTimerCompileStableActor : AActor
{
	FTimerHandle NextTickHandle;
	FTimerHandle FunctionNameHandle;

	UPROPERTY()
	bool bNextTickCallSiteCompiled = false;

	UPROPERTY()
	bool bFunctionNameCallSiteCompiled = false;

	/**
	 * The callback the zero-delay timer fires into.
	 *
	 * @Kind EventHandler
	 * @Covers Component.TimerCompileStableCallSites
	 * @Inputs none
	 * @Return nothing; the call site compiling is what the test observes
	 */
	UFUNCTION()
	void NextTickCallback()
	{
	}

	/**
	 * The callback the repeating timer fires into.
	 *
	 * @Kind EventHandler
	 * @Covers Component.TimerCompileStableCallSites
	 * @Inputs none
	 * @Return nothing; the call site compiling is what the test observes
	 */
	UFUNCTION()
	void FunctionNameCallback()
	{
	}

	/**
	 * WorldStory: BeginPlay sets a zero-delay timer and a repeating timer, records
	 * that each call site compiled, then clears both.
	 *
	 * @Kind WorldStory
	 * @Covers Component.TimerCompileStableCallSites
	 * @Inputs none
	 * @Return both flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		NextTickHandle = System::SetTimer(this, n"NextTickCallback", 0.0f, false);
		bNextTickCallSiteCompiled = SystemLibrary::TimerExistsHandle(NextTickHandle) || !System::IsTimerPausedHandle(NextTickHandle);
		System::ClearAndInvalidateTimerHandle(NextTickHandle);

		FunctionNameHandle = System::SetTimer(this, n"FunctionNameCallback", 0.25f, true);
		bFunctionNameCallSiteCompiled = SystemLibrary::IsTimerActiveHandle(FunctionNameHandle)
			&& SystemLibrary::GetTimerRemainingTimeHandle(FunctionNameHandle) >= 0.0f
			&& SystemLibrary::GetTimerElapsedTimeHandle(FunctionNameHandle) >= 0.0f;
		System::ClearAndInvalidateTimerHandle(FunctionNameHandle);
	}

	/**
	 * Observe that a locally constructed actor has neither flag set.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerCompileStableCallSites
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both flags are clear
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (bNextTickCallSiteCompiled)
		{
			return false;
		}
		return !bFunctionNameCallSiteCompiled;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerCompileStableCallSites
	 * @Inputs this actor plus a second actor
	 * @Return true when this is flagged and the other is not
	 * @Param Second the other actor, expected to stay unflagged
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageTimerCompileStableActor Second)
	{
		if (Second is null)
		{
			throw("TimerCompileStableActorAndComponentCallSites setup: required Second is null");
		}
		bNextTickCallSiteCompiled = true;

		if (!bNextTickCallSiteCompiled)
		{
			return false;
		}
		return !Second.bNextTickCallSiteCompiled;
	}
}
/** @end */
/**
 * @begin timer-component-callbacks-run-on-owner-world
 * @summary A timer owned by a component, driven and snapshotted from the owning actor. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this and verifies the flags by path after a pause and snapshot, so this is a value.
 * @topic Component
 */
UCLASS()
class UCoverageTimerRuntimeComponent : UActorComponent
{
	UPROPERTY()
	int ComponentCallCount = 0;

	UPROPERTY()
	bool bActiveAfterSetup = false;

	UPROPERTY()
	bool bPausedStoppedCallbacks = false;

	FTimerHandle ComponentHandle;

	/**
	 * Count each timer callback the component receives.
	 *
	 * @Kind EventHandler
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs none
	 * @Return ComponentCallCount incremented once per callback
	 */
	UFUNCTION()
	void ComponentCallback()
	{
		ComponentCallCount++;
	}

	/**
	 * Start the repeating component timer and record whether it went active.
	 *
	 * @Kind Action
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs none
	 * @Return bActiveAfterSetup set from the timer's active state
	 */
	UFUNCTION()
	void ConfigureComponentTimer()
	{
		ComponentHandle = System::SetTimer(this, n"ComponentCallback", 0.1f, true);
		bActiveAfterSetup = SystemLibrary::IsTimerActiveHandle(ComponentHandle);
	}

	/**
	 * Pause the component timer.
	 *
	 * @Kind Action
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs none
	 * @Return the timer left paused
	 */
	UFUNCTION()
	void PauseComponentTimer()
	{
		System::PauseTimerHandle(ComponentHandle);
	}

	/**
	 * Record whether the timer is currently paused.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs none
	 * @Return bPausedStoppedCallbacks set from the timer's paused state
	 */
	UFUNCTION()
	void MarkPausedResult()
	{
		bPausedStoppedCallbacks = System::IsTimerPausedHandle(ComponentHandle);
	}

	/**
	 * Clear the component timer.
	 *
	 * @Kind Action
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs none
	 * @Return the timer handle cleared and invalidated
	 */
	UFUNCTION()
	void ClearComponentTimer()
	{
		System::ClearAndInvalidateTimerHandle(ComponentHandle);
	}
}

UCLASS()
class ACoverageTimerComponentOwnerActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageTimerRuntimeComponent TimerComponent;

	UPROPERTY()
	bool bComponentSetupComplete = false;

	UPROPERTY()
	bool bComponentPausedStoppedCallbacks = false;

	UPROPERTY()
	int ObservedComponentCallCount = 0;

	/**
	 * WorldStory: BeginPlay starts the component timer and records that setup
	 * completed.
	 *
	 * @Kind WorldStory
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs a default-attached timer component
	 * @Return bComponentSetupComplete true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TimerComponent.ConfigureComponentTimer();
		bComponentSetupComplete = TimerComponent.bActiveAfterSetup;
	}

	/**
	 * Pause the component timer from the owning actor.
	 *
	 * @Kind Action
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs none
	 * @Return the component timer left paused
	 */
	UFUNCTION()
	void PauseComponentTimerFromOwner()
	{
		TimerComponent.PauseComponentTimer();
	}

	/**
	 * Copy the component's timer state and callback count onto this actor.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs none
	 * @Return bComponentPausedStoppedCallbacks and ObservedComponentCallCount copied off the component
	 */
	UFUNCTION()
	void SnapshotComponentTimerState()
	{
		TimerComponent.MarkPausedResult();
		bComponentPausedStoppedCallbacks = TimerComponent.bPausedStoppedCallbacks;
		ObservedComponentCallCount = TimerComponent.ComponentCallCount;
	}

	/**
	 * Clear the component timer from the owning actor.
	 *
	 * @Kind Action
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs none
	 * @Return the component timer handle cleared
	 */
	UFUNCTION()
	void ClearComponentTimerFromOwner()
	{
		TimerComponent.ClearComponentTimer();
	}

	/**
	 * Observe that a locally constructed actor has no flags, no count and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both flags are clear, the count is 0 and TimerComponent is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (bComponentSetupComplete)
		{
			return false;
		}
		if (bComponentPausedStoppedCallbacks)
		{
			return false;
		}
		if (ObservedComponentCallCount != 0)
		{
			return false;
		}
		return TimerComponent == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerComponentCallbacksRunOnOwnerWorld
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the snapshotted state and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageTimerComponentOwnerActor Second)
	{
		if (Second is null)
		{
			throw("TimerComponentCallbacksRunOnOwnerWorld setup: required Second is null");
		}
		bComponentSetupComplete = true;
		ObservedComponentCallCount = 3;

		if (!bComponentSetupComplete)
		{
			return false;
		}
		if (ObservedComponentCallCount != 3)
		{
			return false;
		}
		if (Second.bComponentSetupComplete)
		{
			return false;
		}
		return Second.ObservedComponentCallCount == 0;
	}
}
/** @end */
/**
 * @begin timer-destroyed-component-stops-callbacks
 * @summary A component that owns a timer, destroyed to confirm its callbacks stop. C++ verifies the active flag before the destroy and the destroyed flag afterwards. The observers cover the declared defaults and copy independence.
 * @topic Component
 */
UCLASS()
class UCoverageTimerDestroyableComponent : UActorComponent
{
	UPROPERTY()
	int CallbackCount = 0;

	UPROPERTY()
	bool bTimerActiveBeforeDestroy = false;

	FTimerHandle DestroyedComponentHandle;

	/**
	 * Count each timer callback the component receives.
	 *
	 * @Kind EventHandler
	 * @Covers Component.TimerDestroyedComponentStopsCallbacks
	 * @Inputs none
	 * @Return CallbackCount incremented once per callback
	 */
	UFUNCTION()
	void CallbackAfterDestroy()
	{
		CallbackCount++;
	}

	/**
	 * Start the repeating timer and record whether it went active.
	 *
	 * @Kind Action
	 * @Covers Component.TimerDestroyedComponentStopsCallbacks
	 * @Inputs none
	 * @Return bTimerActiveBeforeDestroy set from the timer's active state
	 */
	UFUNCTION()
	void ConfigureTimer()
	{
		DestroyedComponentHandle = System::SetTimer(this, n"CallbackAfterDestroy", 0.1f, true);
		bTimerActiveBeforeDestroy = SystemLibrary::IsTimerActiveHandle(DestroyedComponentHandle);
	}
}

UCLASS()
class ACoverageTimerDestroyedComponentOwner : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageTimerDestroyableComponent DestroyableComponent;

	UPROPERTY()
	bool bComponentTimerActiveBeforeDestroy = false;

	UPROPERTY()
	bool bComponentDestroyed = false;

	UPROPERTY()
	int ObservedCallbackCount = -1;

	/**
	 * WorldStory: BeginPlay configures the component timer and records that it was
	 * active.
	 *
	 * @Kind WorldStory
	 * @Covers Component.TimerDestroyedComponentStopsCallbacks
	 * @Inputs a default-attached timer component
	 * @Return bComponentTimerActiveBeforeDestroy true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DestroyableComponent.ConfigureTimer();
		bComponentTimerActiveBeforeDestroy = DestroyableComponent.bTimerActiveBeforeDestroy;
	}

	/**
	 * Destroy the component that owns the timer.
	 *
	 * @Kind Action
	 * @Covers Component.TimerDestroyedComponentStopsCallbacks
	 * @Inputs none
	 * @Return bComponentDestroyed set from the component's destroying state
	 */
	UFUNCTION()
	void DestroyTimerComponent()
	{
		DestroyableComponent.DestroyComponent();
		bComponentDestroyed = DestroyableComponent.IsBeingDestroyed();
	}

	/**
	 * Copy the component's callback count onto this actor.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerDestroyedComponentStopsCallbacks
	 * @Inputs none
	 * @Return ObservedCallbackCount copied off the component
	 */
	UFUNCTION()
	void SnapshotDestroyedComponent()
	{
		ObservedCallbackCount = DestroyableComponent.CallbackCount;
	}

	/**
	 * Observe that a locally constructed actor keeps its declared defaults.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerDestroyedComponentStopsCallbacks
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both flags are clear, the count is -1 and the component is null
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (bComponentTimerActiveBeforeDestroy)
		{
			return false;
		}
		if (bComponentDestroyed)
		{
			return false;
		}
		if (ObservedCallbackCount != -1)
		{
			return false;
		}
		return DestroyableComponent == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.TimerDestroyedComponentStopsCallbacks
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the destroyed state and the other keeps its defaults
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageTimerDestroyedComponentOwner Second)
	{
		if (Second is null)
		{
			throw("TimerDestroyedComponentStopsCallbacks setup: required Second is null");
		}
		bComponentDestroyed = true;
		ObservedCallbackCount = 0;

		if (!bComponentDestroyed)
		{
			return false;
		}
		if (ObservedCallbackCount != 0)
		{
			return false;
		}
		if (Second.bComponentDestroyed)
		{
			return false;
		}
		return Second.ObservedCallbackCount == -1;
	}
}
/** @end */
