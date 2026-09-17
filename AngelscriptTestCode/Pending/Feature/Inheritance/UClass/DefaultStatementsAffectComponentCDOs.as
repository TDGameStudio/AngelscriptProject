/**
 * @version v1
 * @summary Default statements write DefaultComponent CDO values. C++ verifies Sphere radius 128, Mesh hidden, CastShadow false and relative yaw 45. A zero radius mutation is copy-independent.
 * @topic Feature
 */
/**
 * @version root
 * @summary Default statements write DefaultComponent CDO values. C++ verifies Sphere radius 128, Mesh hidden, CastShadow false and relative yaw 45. A zero radius mutation is copy-independent.
 * @topic Baseline
 */
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

	/**
	 * Observe the Sphere CDO radius written by the default statement.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DefaultStatementsAffectComponentCDOs
	 * @Inputs the DefaultComponent Sphere
	 * @Return Sphere.SphereRadius, expected to be 128
	 */
	UFUNCTION()
	float SphereRadius()
	{
		if (Sphere == nullptr)
		{
			throw("DefaultStatementsAffectComponentCDOs setup: required Sphere component is null");
		}
		return Sphere.SphereRadius;
	}

	/**
	 * Observe the Mesh relative yaw written by the default statement.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DefaultStatementsAffectComponentCDOs
	 * @Inputs the DefaultComponent Mesh
	 * @Return Mesh relative yaw, expected to be 45
	 */
	UFUNCTION()
	float MeshYaw()
	{
		if (Mesh == nullptr)
		{
			throw("DefaultStatementsAffectComponentCDOs setup: required Mesh component is null");
		}
		return Mesh.GetRelativeRotation().Yaw;
	}

	/**
	 * Observe that zeroing this Sphere radius leaves another actor at 128.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DefaultStatementsAffectComponentCDOs
	 * @Inputs this actor plus a second actor
	 * @Return true when this radius is 0 and the other stays 128
	 * @Param Second the other actor, expected to keep radius 128
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(AFunctionalDefaultOverrideActor Second)
	{
		if (Second == nullptr || Sphere == nullptr || Second.Sphere == nullptr)
		{
			throw("DefaultStatementsAffectComponentCDOs setup: required actors are null");
		}
		Sphere.SphereRadius = 0.0;
		if (Math::Abs(Second.Sphere.SphereRadius - 128.0) >= 0.001)
		{
			return false;
		}
		return Math::Abs(Sphere.SphereRadius) < 0.001;
	}
}
/** @end */
