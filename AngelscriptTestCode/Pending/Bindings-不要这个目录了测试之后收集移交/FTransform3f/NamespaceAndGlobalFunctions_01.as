/**
 * @version v1
 * @summary Observe FTransform3f rotation-plus-translation constructors and the Identity constant.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FTransform3f rotation-plus-translation constructors and the Identity constant.
 * @topic Baseline
 */
// const FVector3f& = OneVector); FTransform3f(const FRotator3f&,
// const FVector3f&, const FVector3f& = OneVector);
// const FTransform3f FTransform3f::Identity;
// Inputs: Identity quat, ZeroRotator, translation (1,2,3), omitted scale, and
// explicit scale (2,2,2).
// Expected observations: Omitted scale is OneVector. Explicit scale is stored.
// Identity has zero translation, identity rotation, and unit scale.
// Boundary/ownership: Identity is a shared constant. Omitted InScale3D is
// FVector3f::OneVector.

namespace TS_FTransform3f_NamespaceAndGlobalFunctions_01
{
	// FTransform3f(Quat/Rotator, Translation, Scale=OneVector): omitted scale is OneVector; yaw 90 is kept.
	bool Observe_Value_Nominal()
	{
		FTransform3f FromQuatDefault(FQuat4f::Identity, FVector3f(1.0, 2.0, 3.0));
		FTransform3f FromQuatScale(FQuat4f::Identity, FVector3f(1.0, 2.0, 3.0), FVector3f(2.0, 2.0, 2.0));
		FTransform3f FromRotDefault(FRotator3f::ZeroRotator, FVector3f(1.0, 2.0, 3.0));
		FTransform3f FromRotScale(FRotator3f(0.0, 90.0, 0.0), FVector3f(1.0, 2.0, 3.0), FVector3f(2.0, 2.0, 2.0));
		return FromQuatDefault.GetScale3D().Equals(FVector3f::OneVector) &&
			FromRotDefault.GetScale3D().Equals(FVector3f::OneVector) &&
			FromQuatScale.GetScale3D().Equals(FVector3f(2.0, 2.0, 2.0)) &&
			FromRotScale.GetScale3D().Equals(FVector3f(2.0, 2.0, 2.0)) &&
			FromQuatDefault.GetTranslation().Equals(FVector3f(1.0, 2.0, 3.0)) &&
			FromRotScale.Rotator().Equals(FRotator3f(0.0, 90.0, 0.0));
	}

	// FTransform3f::Identity: zero translation, identity rotation, unit scale. Shared constant.
	bool Observe_Surface060_Nominal()
	{
		FTransform3f Identity = FTransform3f::Identity;
		return Identity.GetTranslation().IsNearlyZero() &&
			Identity.GetScale3D().Equals(FVector3f::OneVector) &&
			Identity.GetRotation().Equals(FQuat4f::Identity);
	}
}
/** @end */
