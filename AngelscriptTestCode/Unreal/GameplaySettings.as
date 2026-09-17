/**
 * @version v1
 * @summary GameplaySettings host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic GameplaySettings
 *
 * actor-owner-and-relevancy-settings
 * character-movement-physics-settings
 * f-vector-specifier-and-set-properties
 * input-binding-collections-visible-after-setup
 * input-settings-and-runtime-mapping-api
 * physics-constraint-component-settings
 * physics-constraint-preset-recipes
 * primitive-collision-setup
 * projectile-movement-settings
 * setup-player-input-component
 * text-block-set-font-applies-slate-font-info-fields
 */
/**
 * @begin actor-owner-and-relevancy-settings
 * @summary FixtureIsolated.
 * @topic Unreal
 */
/**
 * @function ExerciseOwnerAndRelevancy
 * @summary FixtureIsolated.
 * @covers ActorOwnerAndRelevancySettings
 * @inputs gameplay settings previously parked under TSet
 * @return true when the observe comparison holds
 */
UCLASS()
class ACoverageNetworkingOwnerRelevancyActor : AActor
{

	default SetReplicates(true);
	// NOTE: AActor replication bitfields (bOnlyRelevantToOwner, bAlwaysRelevant,
	// bNetUseOwnerRelevancy) are uint8 bitfield UPROPERTYs that the AngelScript binding
	// does not expose as settable `default` members ("'bOnlyRelevantToOwner' is not
	// declared"). Only float/typed replication members such as NetPriority are reachable
	// from AS class defaults, so this surface is limited to NetPriority + SetReplicates.
	// SetReplicates/SetNetUpdateFrequency* are method-call defaults on spawned instances,
	// not on the CDO (see UClassDefaultValueAndCDOMatrix).
	default NetPriority = 3.5f;
	default SetNetUpdateFrequency(24.0f);
	default SetMinNetUpdateFrequency(6.0f);
	default SetNetCullDistanceSquared(4096.0f);

	UPROPERTY()
	bool bOwnerRoundTrip = false;

	UPROPERTY()
	bool bFrequencyRoundTrip = false;

	UFUNCTION()
	void ExerciseOwnerAndRelevancy(AActor NewOwner)
	{
		SetOwner(NewOwner);
		bOwnerRoundTrip = GetOwner() == NewOwner;
		SetNetUpdateFrequency(12.0f);
		SetMinNetUpdateFrequency(4.0f);
		SetNetCullDistanceSquared(1024.0f);
		bFrequencyRoundTrip =
			GetNetUpdateFrequency() == 12.0f
			&& GetMinNetUpdateFrequency() == 4.0f
			&& GetNetCullDistanceSquared() == 1024.0f;
	}
/** @end */
/**
 * @begin character-movement-physics-settings
 * @summary DefaultSafe.
 * @topic Unreal
 */
/**
 * @function Run
 * @summary DefaultSafe.
 * @covers CharacterMovementPhysicsSettings
 * @inputs gameplay settings previously parked under TSet
 * @return true when the observe comparison holds
 */
//

	int Run(UCharacterMovementComponent Movement)
	{
		if (Movement == nullptr)
		{
			return 0;
		}

		Movement.SetMovementMode(EMovementMode::MOVE_Walking);
		Movement.MaxWalkSpeed = 700.0f;
		Movement.MaxAcceleration = 2048.0f;
		Movement.BrakingDecelerationWalking = 1024.0f;
		Movement.GroundFriction = 4.0f;
		Movement.JumpZVelocity = 500.0f;
		Movement.AirControl = 0.35f;
		Movement.GravityScale = 1.25f;

		MovementParametersCovered =
			Movement.MaxWalkSpeed > 699.0f
			&& Movement.GetMaxAcceleration() > 2047.0f
			&& Movement.GetMaxBrakingDeceleration() > 1023.0f
			&& Movement.GroundFriction > 3.9f
			&& Movement.JumpZVelocity > 499.0f
			&& Movement.AirControl > 0.34f
			&& Movement.GravityScale > 1.24f;

		bool bWalkingValueReadable = int(EMovementMode::MOVE_Walking) >= 0;
		bool bNavWalkingValueReadable = int(EMovementMode::MOVE_NavWalking) >= 0;
		bool bFallingValueReadable = int(EMovementMode::MOVE_Falling) >= 0;
		bool bSwimmingValueReadable = int(EMovementMode::MOVE_Swimming) >= 0;
		bool bFlyingValueReadable = int(EMovementMode::MOVE_Flying) >= 0;
		bool bCustomValueReadable = int(EMovementMode::MOVE_Custom) >= 0;

		Movement.SetMovementMode(EMovementMode::MOVE_Flying);
		bool bFlyingSet = Movement.MovementMode == EMovementMode::MOVE_Flying;
		Movement.SetMovementMode(EMovementMode::MOVE_Falling);
		bool bFallingSet = Movement.MovementMode == EMovementMode::MOVE_Falling;
		Movement.SetMovementMode(EMovementMode::MOVE_Swimming);
		bool bSwimmingQueryCallable = Movement.IsSwimming() || !Movement.IsSwimming();
		Movement.SetMovementMode(EMovementMode::MOVE_Walking);
		bool bWalkingSet = Movement.MovementMode == EMovementMode::MOVE_Walking;

		MovementModesCovered =
			bWalkingValueReadable
			&& bNavWalkingValueReadable
			&& bFallingValueReadable
			&& bSwimmingValueReadable
			&& bFlyingValueReadable
			&& bCustomValueReadable
			&& bFlyingSet
			&& bFallingSet
			&& bWalkingSet;

		FVector CurrentAcceleration = Movement.GetCurrentAcceleration();
		bool bWalkingQueryCallable = Movement.IsWalking() || !Movement.IsWalking();
		bool bFallingQueryCallable = Movement.IsFalling() || !Movement.IsFalling();
		bool bFlyingQueryCallable = Movement.IsFlying() || !Movement.IsFlying();
		MovementQueriesCovered =
			bWalkingQueryCallable
			&& bFallingQueryCallable
			&& bSwimmingQueryCallable
			&& bFlyingQueryCallable
			&& CurrentAcceleration.SizeSquared() >= 0.0f;

		return MovementModesCovered && MovementParametersCovered && MovementQueriesCovered ? 1 : 0;
	}
/** @end */
/**
 * @begin f-vector-specifier-and-set-properties
 * @summary FixtureIsolated.
 * @topic Unreal
 */
/**
 * @function BeginPlay
 * @summary FixtureIsolated.
 * @covers FVectorSpecifierAndSetProperties
 * @inputs gameplay settings previously parked under TSet
 * @return true when the observe comparison holds
 */
// CompileScriptModule + spawn + BeginPlay.

	void BeginPlay()
	{
		VectorSet.Add(FVector::ForwardVector);
		VectorSet.Add(FVector::RightVector);
		VectorSet.Add(FVector::UpVector);
	}
/** @end */
/**
 * @begin input-binding-collections-visible-after-setup
 * @summary DefaultSafe.
 * @topic Unreal
 */
/**
 * @function SetupInput
 * @summary DefaultSafe.
 * @covers InputBindingCollectionsVisibleAfterSetup
 * @inputs gameplay settings previously parked under TSet
 * @return true when the observe comparison holds
 */
UCLASS()
class AInputBindingVisibilityPawn : APawn
{
	UPROPERTY()
	int SetupCallCount = 0;

	void SetupInput(UInputComponent PlayerInputComponent)
	{
		SetupCallCount++;

		FInputActionHandlerDynamicSignature JumpPressedDelegate;
		PlayerInputComponent.BindAction(n"Jump", EInputEvent::IE_Pressed, JumpPressedDelegate);

		FInputActionHandlerDynamicSignature JumpReleasedDelegate;
		PlayerInputComponent.BindAction(n"Jump", EInputEvent::IE_Released, JumpReleasedDelegate);

		FInputAxisHandlerDynamicSignature MoveForwardDelegate;
		PlayerInputComponent.BindAxis(n"MoveForward", MoveForwardDelegate);

		FInputAxisHandlerDynamicSignature TurnDelegate;
		PlayerInputComponent.BindAxis(n"Turn", TurnDelegate);

		FInputActionHandlerDynamicSignature SpacePressedDelegate;
		PlayerInputComponent.BindKey(EKeys::SpaceBar, EInputEvent::IE_Pressed, SpacePressedDelegate);

		FInputActionHandlerDynamicSignature LeftMouseReleasedDelegate;
		PlayerInputComponent.BindKey(EKeys::LeftMouseButton, EInputEvent::IE_Released, LeftMouseReleasedDelegate);
	}
/** @end */
/**
 * @begin input-settings-and-runtime-mapping-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function InputSettingsReadApi
 * @summary Observe the container API.
 * @covers InputSettingsAndRuntimeMappingApi
 * @inputs gameplay settings previously parked under TSet
 * @return true when the observe comparison holds
 */
//

 ExecuteAndExpectInt InputSettingsReadApi()==1 and RuntimeMappingSignatureEntry()==1.
// Extra: missing action/axis names stay absent; RuntimeMappingSignatureEntry is the constant 1.
// DefaultSafe. Source owns locals. PlayerInput is not invoked from observations.

int InputSettingsReadApi()
{
	UInputSettings Settings = UInputSettings::GetInputSettings();
	if (Settings == nullptr)
	{
		return 0;
	}

	FName UniqueAction = Settings.GetUniqueActionName(n"CoverageAction");
	FName UniqueAxis = Settings.GetUniqueAxisName(n"CoverageAxis");
	int ActionCount = Settings.GetActionMappings().Num();
	int AxisCount = Settings.GetAxisMappings().Num();
	bool bMissingAction = Settings.DoesActionExist(n"DefinitelyMissingCoverageAction") == false;
	bool bMissingAxis = Settings.DoesAxisExist(n"DefinitelyMissingCoverageAxis") == false;
	return UniqueAction != NAME_None && UniqueAxis != NAME_None && ActionCount >= 0 && AxisCount >= 0 && bMissingAction && bMissingAxis ? 1 : 0;
}
/** @end */
/**
 * @begin physics-constraint-component-settings
 * @summary FixtureIsolated.
 * @topic Unreal
 */
/**
 * @function BeginPlay
 * @summary FixtureIsolated.
 * @covers PhysicsConstraintComponentSettings
 * @inputs gameplay settings previously parked under TSet
 * @return true when the observe comparison holds
 */
UCLASS()
class ACoveragePhysicsConstraintActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USphereComponent BodyA;

	UPROPERTY(DefaultComponent, Attach=Root)
	USphereComponent BodyB;

	UPROPERTY(DefaultComponent, Attach=Root)
	UPhysicsConstraintComponent Constraint;

	UPROPERTY()
	bool ConstrainedComponentsSet = false;

	UPROPERTY()
	bool LinearLimitsSet = false;

	UPROPERTY()
	bool AngularLimitsSet = false;

	UPROPERTY()
	bool LinearDriveSet = false;

	UPROPERTY()
	bool ConstraintBroken = false;

	UFUNCTION(BlueprintOverride)

	void BeginPlay()
	{
		BodyA.SetSimulatePhysics(true);
		BodyB.SetSimulatePhysics(true);
		Constraint.SetConstrainedComponents(BodyA, NAME_None, BodyB, NAME_None);

		UPrimitiveComponent OutA;
		FName BoneA;
		UPrimitiveComponent OutB;
		FName BoneB;
		Constraint.GetConstrainedComponents(OutA, BoneA, OutB, BoneB);
		ConstrainedComponentsSet = OutA == BodyA && OutB == BodyB;

		Constraint.SetLinearXLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetLinearYLimit(ELinearConstraintMotion::LCM_Limited, 25.0f);
		Constraint.SetLinearZLimit(ELinearConstraintMotion::LCM_Free, 0.0f);
		LinearLimitsSet = true;

		Constraint.SetAngularSwing1Limit(EAngularConstraintMotion::ACM_Limited, 45.0f);
		Constraint.SetAngularSwing2Limit(EAngularConstraintMotion::ACM_Locked, 0.0f);
		Constraint.SetAngularTwistLimit(EAngularConstraintMotion::ACM_Free, 0.0f);
		AngularLimitsSet = true;

		Constraint.SetLinearPositionDrive(true, false, true);
		Constraint.SetLinearPositionTarget(FVector(5.0f, 0.0f, 10.0f));
		LinearDriveSet = true;

		Constraint.BreakConstraint();
		ConstraintBroken = true;
	}
/** @end */
/**
 * @begin physics-constraint-preset-recipes
 * @summary FixtureIsolated.
 * @topic Unreal
 */
/**
 * @function BeginPlay
 * @summary FixtureIsolated.
 * @covers PhysicsConstraintPresetRecipes
 * @inputs gameplay settings previously parked under TSet
 * @return true when the observe comparison holds
 */
UCLASS()
class ACoveragePhysicsConstraintPresetRecipesActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USphereComponent BodyA;

	UPROPERTY(DefaultComponent, Attach=Root)
	USphereComponent BodyB;

	UPROPERTY(DefaultComponent, Attach=Root)
	UPhysicsConstraintComponent Constraint;

	UPROPERTY()
	bool HingeRecipeConfigured = false;

	UPROPERTY()
	bool PrismaticRecipeConfigured = false;

	UPROPERTY()
	bool BallSocketRecipeConfigured = false;

	UPROPERTY()
	bool FixedRecipeConfigured = false;

	UPROPERTY()
	bool DriveTargetsConfigured = false;

	UFUNCTION(BlueprintOverride)

	void BeginPlay()
	{
		Constraint.SetConstrainedComponents(BodyA, NAME_None, BodyB, NAME_None);

		Constraint.SetLinearXLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetLinearYLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetLinearZLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetAngularSwing1Limit(EAngularConstraintMotion::ACM_Locked, 0.0f);
		Constraint.SetAngularSwing2Limit(EAngularConstraintMotion::ACM_Locked, 0.0f);
		Constraint.SetAngularTwistLimit(EAngularConstraintMotion::ACM_Free, 0.0f);
		HingeRecipeConfigured = true;

		Constraint.SetLinearXLimit(ELinearConstraintMotion::LCM_Limited, 40.0f);
		Constraint.SetLinearYLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetLinearZLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetAngularSwing1Limit(EAngularConstraintMotion::ACM_Locked, 0.0f);
		Constraint.SetAngularSwing2Limit(EAngularConstraintMotion::ACM_Locked, 0.0f);
		Constraint.SetAngularTwistLimit(EAngularConstraintMotion::ACM_Locked, 0.0f);
		PrismaticRecipeConfigured = true;

		Constraint.SetLinearXLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetLinearYLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetLinearZLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetAngularSwing1Limit(EAngularConstraintMotion::ACM_Limited, 35.0f);
		Constraint.SetAngularSwing2Limit(EAngularConstraintMotion::ACM_Limited, 35.0f);
		Constraint.SetAngularTwistLimit(EAngularConstraintMotion::ACM_Limited, 20.0f);
		BallSocketRecipeConfigured = true;

		Constraint.SetLinearXLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetLinearYLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetLinearZLimit(ELinearConstraintMotion::LCM_Locked, 0.0f);
		Constraint.SetAngularSwing1Limit(EAngularConstraintMotion::ACM_Locked, 0.0f);
		Constraint.SetAngularSwing2Limit(EAngularConstraintMotion::ACM_Locked, 0.0f);
		Constraint.SetAngularTwistLimit(EAngularConstraintMotion::ACM_Locked, 0.0f);
		FixedRecipeConfigured = true;

		Constraint.SetLinearPositionDrive(true, true, true);
		Constraint.SetLinearPositionTarget(FVector(10.0f, 20.0f, 30.0f));
		DriveTargetsConfigured = true;
	}
/** @end */
/**
 * @begin primitive-collision-setup
 * @summary FixtureIsolated.
 * @topic Unreal
 */
/**
 * @function BeginPlay
 * @summary FixtureIsolated.
 * @covers PrimitiveCollisionSetup
 * @inputs gameplay settings previously parked under TSet
 * @return true when the observe comparison holds
 */
UCLASS()
class ACoveragePrimitiveCollisionSetupActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent MeshComp;

	UPROPERTY()
	bool CollisionEnabledSet = false;

	UPROPERTY()
	bool ProfileSet = false;

	UPROPERTY()
	bool GenerateOverlapEventsSet = false;

	UPROPERTY()
	bool CollisionModesCovered = false;

	UPROPERTY()
	bool CommonProfilesCovered = false;

	UPROPERTY()
	bool NotifyRigidBodyCollisionSet = false;

	UFUNCTION(BlueprintOverride)

	void BeginPlay()
	{
		// Set collision enabled
		MeshComp.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		CollisionEnabledSet = (MeshComp.GetCollisionEnabled() == ECollisionEnabled::QueryAndPhysics);

		// Set collision profile
		MeshComp.SetCollisionProfileName(n"BlockAll");
		ProfileSet = (MeshComp.GetCollisionProfileName() == n"BlockAll");

		// Enable overlap events
		MeshComp.SetGenerateOverlapEvents(true);
		GenerateOverlapEventsSet = MeshComp.GetGenerateOverlapEvents();

		// Exercise collision enabled modes with readback.
		MeshComp.SetCollisionEnabled(ECollisionEnabled::NoCollision);
		bool bNoCollision = MeshComp.GetCollisionEnabled() == ECollisionEnabled::NoCollision;
		MeshComp.SetCollisionEnabled(ECollisionEnabled::QueryOnly);
		bool bQueryOnly = MeshComp.GetCollisionEnabled() == ECollisionEnabled::QueryOnly;
		MeshComp.SetCollisionEnabled(ECollisionEnabled::PhysicsOnly);
		bool bPhysicsOnly = MeshComp.GetCollisionEnabled() == ECollisionEnabled::PhysicsOnly;
		MeshComp.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		bool bQueryAndPhysics = MeshComp.GetCollisionEnabled() == ECollisionEnabled::QueryAndPhysics;
		CollisionModesCovered = bNoCollision && bQueryOnly && bPhysicsOnly && bQueryAndPhysics;

		// Exercise common built-in profiles with readback.
		MeshComp.SetCollisionProfileName(n"NoCollision");
		bool bNoCollisionProfile = MeshComp.GetCollisionProfileName() == n"NoCollision";
		MeshComp.SetCollisionProfileName(n"BlockAll");
		bool bBlockAllProfile = MeshComp.GetCollisionProfileName() == n"BlockAll";
		MeshComp.SetCollisionProfileName(n"OverlapAll");
		bool bOverlapAllProfile = MeshComp.GetCollisionProfileName() == n"OverlapAll";
		MeshComp.SetCollisionProfileName(n"BlockAllDynamic");
		bool bBlockAllDynamicProfile = MeshComp.GetCollisionProfileName() == n"BlockAllDynamic";
		MeshComp.SetCollisionProfileName(n"OverlapAllDynamic");
		bool bOverlapAllDynamicProfile = MeshComp.GetCollisionProfileName() == n"OverlapAllDynamic";
		MeshComp.SetCollisionProfileName(n"IgnoreOnlyPawn");
		bool bIgnoreOnlyPawnProfile = MeshComp.GetCollisionProfileName() == n"IgnoreOnlyPawn";
		MeshComp.SetCollisionProfileName(n"OverlapOnlyPawn");
		bool bOverlapOnlyPawnProfile = MeshComp.GetCollisionProfileName() == n"OverlapOnlyPawn";
		MeshComp.SetCollisionProfileName(n"Pawn");
		bool bPawnProfile = MeshComp.GetCollisionProfileName() == n"Pawn";
		MeshComp.SetCollisionProfileName(n"PhysicsActor");
		bool bPhysicsActorProfile = MeshComp.GetCollisionProfileName() == n"PhysicsActor";
		CommonProfilesCovered =
			bNoCollisionProfile
			&& bBlockAllProfile
			&& bOverlapAllProfile
			&& bBlockAllDynamicProfile
			&& bOverlapAllDynamicProfile
			&& bIgnoreOnlyPawnProfile
			&& bOverlapOnlyPawnProfile
			&& bPawnProfile
			&& bPhysicsActorProfile;

		MeshComp.SetNotifyRigidBodyCollision(true);
		NotifyRigidBodyCollisionSet = true;
	}
/** @end */
/**
 * @begin projectile-movement-settings
 * @summary FixtureIsolated.
 * @topic Unreal
 */
/**
 * @function BeginPlay
 * @summary FixtureIsolated.
 * @covers ProjectileMovementSettings
 * @inputs gameplay settings previously parked under TSet
 * @return true when the observe comparison holds
 */
UCLASS()
class ACoveragePhysicsProjectileMovementActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent Projectile;

	UPROPERTY()
	bool ProjectileScalarSettingsSet = false;

	UPROPERTY()
	bool ProjectileHomingTargetSet = false;

	UPROPERTY()
	bool ProjectileRuntimeStateStable = false;

	UFUNCTION(BlueprintOverride)

	void BeginPlay()
	{
		Projectile.InitialSpeed = 1200.0f;
		Projectile.MaxSpeed = 2400.0f;
		Projectile.Bounciness = 0.65f;
		Projectile.ProjectileGravityScale = 0.25f;

		Projectile.SetHomingTargetComponent(Sphere);

		ProjectileScalarSettingsSet =
			Projectile.InitialSpeed > 1199.0f
			&& Projectile.MaxSpeed > 2399.0f
			&& Projectile.Bounciness > 0.64f
			&& Projectile.ProjectileGravityScale > 0.24f;

		ProjectileHomingTargetSet = (Projectile.GetHomingTargetComponent() == Sphere);

		Projectile.SetHomingTargetComponent(nullptr);
		ProjectileRuntimeStateStable = Projectile.GetHomingTargetComponent() == nullptr;
	}
/** @end */
/**
 * @begin setup-player-input-component
 * @summary Isolate the failing pawn.
 * @topic Unreal
 */
/**
 * @function SetupPlayerInputComponent
 * @summary Isolate the failing pawn.
 * @covers SetupPlayerInputComponent
 * @inputs gameplay settings previously parked under TSet
 * @return true when the observe comparison holds
 */
UCLASS()
class AInputSetupPawn : APawn
{
	UPROPERTY()
	bool InputComponentReceived = false;

	UPROPERTY()
	bool InputComponentValid = false;

	UFUNCTION(BlueprintOverride)

	void SetupPlayerInputComponent(UInputComponent PlayerInputComponent)
	{
		InputComponentReceived = true;
		InputComponentValid = (PlayerInputComponent != nullptr);
	}
/** @end */
/**
 * @begin text-block-set-font-applies-slate-font-info-fields
 * @summary Optional font/outline C++ tokens
 * @topic Unreal
 */
/**
 * @function SetFontFromStruct
 * @summary Optional font/outline C++ tokens
 * @covers TextBlockSetFontAppliesSlateFontInfoFields
 * @inputs gameplay settings previously parked under TSet
 * @return true when the observe comparison holds
 */
// Optional font/outline C++ tokens

 stay omitted (empty substitution); only always-present fields.
// Oracle: SetFontFromStruct()==1 after Size 31, Typeface Bold, outline size 2, copy-then-SetFont.
// Extra: default Font.Size is 0; mutating a copy does not change the source Size until assigned.
// DefaultSafe. Widget is created by MakeWidget.

int SetFontFromStruct()
{
	UTextBlock Text = Cast<UTextBlock>(MakeWidget(UTextBlock::StaticClass(), n"FontInfoProbe"));
	if (Text == null)
	{
		return 0;
	}

	FSlateFontInfo Font;
	Font.Size = 31.0f;
	Font.TypefaceFontName = n"Bold";
	Font.OutlineSettings.OutlineSize = 2;
	Font.OutlineSettings.OutlineColor = FLinearColor(0.2f, 0.4f, 0.6f, 0.8f);

	if (Font.FontObject != null || Font.FontMaterial != null)
	{
		return 5;
	}
	if (Font.Size != 31.0f)
	{
		return 10;
	}
	if (Font.TypefaceFontName != n"Bold")
	{
		return 20;
	}
	if (Font.OutlineSettings.OutlineSize != 2
		|| Font.OutlineSettings.OutlineMaterial != null)
	{
		return 45;
	}
	if (Font.OutlineSettings.OutlineColor.R != 0.2f
		|| Font.OutlineSettings.OutlineColor.G != 0.4f
		|| Font.OutlineSettings.OutlineColor.B != 0.6f
		|| Font.OutlineSettings.OutlineColor.A != 0.8f)
	{
		return 46;
	}

	Font.Size += 1.0f;
	Font.OutlineSettings.OutlineSize += 1;
	FSlateFontInfo CopiedFont = Font;
	Text.SetFont(CopiedFont);
	return 1;
}
/** @end */
