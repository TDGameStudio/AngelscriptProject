/*
 * This is an example of an object that simply moves left
 * and right over time. Several features of script classes
 * are used here, and this is an easy way to demonstrate
 * hot reload as well by changing the behavior.
 */

class AExampleMovingObject : AActor
{
	/**
	 * Properties set to DefaultComponent will be
	 * created as components on the class automatically.
	 * Without this, it would just be a reference to any component.
	 * Setting RootComponent makes this component the default root for this class.
	 */
	UPROPERTY()
	USceneComponent Mesh;

	/**
	 * The 'default' keyword is used to set properties on subobjects or
	 * parent classes. This is equivalent to setting them in the constructor in C++.
	 */
	default bReplicates = true;

	/**
	 * Setting the Attach specifier determines
	 * where a default component gets attached in the hierarchy
	 * without having to code it manually.
	 */
	UPROPERTY()
	USceneComponent Billboard;

	UPROPERTY()
	float MovementPerSecond = 100.0;

	/* Properties can be edited on the instance by default unless NotEditable is specified. */
	UPROPERTY(NotEditable, BlueprintReadOnly)
	FVector OriginalPosition;

	/* Not all properties need to be known by unreal. */
	bool bHeadingBack = false;

	/* We can override beginplay to execute script when the actor enters the level. */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Record the position of the object on BeginPlay so we know where to go back to.
		OriginalPosition = FVector::ZeroVector;
	}

	/* Override the tick function to do the actual movement logic. */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		FVector NewLocation = OriginalPosition;
		if (bHeadingBack)
		{
			NewLocation -= FVector(DeltaSeconds * MovementPerSecond, 0, 0);

			if (NewLocation.X < OriginalPosition.X - 100)
				bHeadingBack = false;
		}
		else
		{
			NewLocation += FVector(DeltaSeconds * MovementPerSecond, 0, 0);

			if (NewLocation.X > OriginalPosition.X + 100)
				bHeadingBack = true;
		}

		OriginalPosition = NewLocation;
	}
};
