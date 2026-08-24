// Purpose: Observe FTransform::Identity and the rotation-plus-translation
// constructors, including omitted default scale.
// AS-facing API: const FTransform FTransform::Identity;
// FTransform(const FQuat&, const FVector&, const FVector& = OneVector);
// FTransform(const FRotator&, const FVector&, const FVector& = OneVector);
// Inputs: Identity, identity quat, ZeroRotator, translation (1,2,3), omitted
// scale, and explicit scale (2,2,2).
// Expected observations: Identity has zero translation and unit scale. Omitted
// scale is OneVector. Explicit scale is stored. Rotation constructors keep
// the supplied translation.
// Boundary/ownership: Identity is a shared constant. Omitted InScale3D is
// FVector::OneVector.

namespace TS_FTransform_NamespaceAndGlobalFunctions_01
{
	// FTransform::Identity: zero translation, identity rotation, unit scale. Shared constant.
	bool Observe_Surface003_Nominal()
	{
		FTransform Identity = FTransform::Identity;
		return Identity.GetTranslation().IsNearlyZero() &&
			Identity.GetScale3D().Equals(FVector::OneVector) &&
			Identity.GetRotation().Equals(FQuat::Identity);
	}

	// FTransform(Quat/Rotator, Translation, Scale=OneVector): omitted scale is OneVector; explicit (2,2,2) is stored.
	bool Observe_Transform_Nominal()
	{
		FTransform FromQuatDefault(FQuat::Identity, FVector(1.0, 2.0, 3.0));
		FTransform FromQuatScale(FQuat::Identity, FVector(1.0, 2.0, 3.0), FVector(2.0, 2.0, 2.0));
		FTransform FromRotDefault(FRotator::ZeroRotator, FVector(1.0, 2.0, 3.0));
		FTransform FromRotScale(FRotator(0.0, 90.0, 0.0), FVector(1.0, 2.0, 3.0), FVector(2.0, 2.0, 2.0));
		return FromQuatDefault.GetScale3D().Equals(FVector::OneVector) &&
			FromRotDefault.GetScale3D().Equals(FVector::OneVector) &&
			FromQuatScale.GetScale3D().Equals(FVector(2.0, 2.0, 2.0)) &&
			FromRotScale.GetScale3D().Equals(FVector(2.0, 2.0, 2.0)) &&
			FromQuatDefault.GetTranslation().Equals(FVector(1.0, 2.0, 3.0)) &&
			FromRotScale.Rotator().Equals(FRotator(0.0, 90.0, 0.0));
	}
}
