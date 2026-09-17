/**
 * @version v1
 * @summary Observe FTransform3f declaration/constructors, Inverse, and Blend.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FTransform3f declaration/constructors, Inverse, and Blend.
 * @topic Baseline
 */
// axes; FTransform conversion; Inverse(); Blend.
// Inputs: Default identity, copy, translation (1,2,3), identity quat, yaw 90,
// world axes plus translation, FTransform conversion, Inverse of (10,0,0),
// blend translations 0 and 10 at alpha 0/0.5/1.
// Expected observations: Declaration and default construction equal Identity.
// Copy is independent. Conversion constructors store the supplied parts.
// Inverse of +10 X is -10 X. Blend alpha 0/1 selects endpoints; 0.5 is
// midpoint.
// Boundary/ownership: Inverse returns a new transform. Blend mutates the
// receiver and does not mutate the source atoms.

namespace TS_FTransform3f_Behavior_01
{
	// FTransform3f Value; default construction equals Identity. No fixture.
	bool Observe_Surface001_Nominal()
	{
		FTransform3f Value;
		return Value.Equals(FTransform3f::Identity);
	}

	// FTransform3f constructors: copy, translation, quat, rotator, axes, FTransform conversion.
	bool Observe_Value_Nominal()
	{
		FTransform3f DefaultValue;
		FTransform3f Copied(FTransform3f(FVector3f(1.0, 2.0, 3.0)));
		FTransform3f FromTranslation(FVector3f(1.0, 2.0, 3.0));
		FTransform3f FromQuat(FQuat4f::Identity);
		FTransform3f FromRotator(FRotator3f(0.0, 90.0, 0.0));
		FTransform3f FromAxes(FVector3f::ForwardVector, FVector3f::RightVector, FVector3f::UpVector, FVector3f(4.0, 5.0, 6.0));
		FTransform DoublePrecision(FVector(7.0, 8.0, 9.0));
		FTransform3f FromDouble(DoublePrecision);
		FTransform3f Original = Copied;
		Copied.SetTranslation(FVector3f::ZeroVector);
		return DefaultValue.Equals(FTransform3f::Identity) &&
			Original.GetTranslation().X == 1.0 &&
			FromTranslation.GetTranslation().Equals(FVector3f(1.0, 2.0, 3.0)) &&
			FromQuat.GetRotation().Equals(FQuat4f::Identity) &&
			FromRotator.Rotator().Equals(FRotator3f(0.0, 90.0, 0.0)) &&
			FromAxes.GetTranslation().Equals(FVector3f(4.0, 5.0, 6.0)) &&
			FromAxes.GetRotation().Equals(FQuat4f::Identity) &&
			FromDouble.GetTranslation().Equals(FVector3f(7.0, 8.0, 9.0));
	}

	// Inverse of translation +10 X is -10 X; Identity inverse stays Identity. Source is unchanged.
	bool Observe_Inverse_Nominal()
	{
		FTransform3f Moved(FVector3f(10.0, 0.0, 0.0));
		FTransform3f Inverse = Moved.Inverse();
		FTransform3f IdentityInverse = FTransform3f::Identity.Inverse();
		return Inverse.GetTranslation().Equals(FVector3f(-10.0, 0.0, 0.0)) &&
			IdentityInverse.Equals(FTransform3f::Identity) &&
			Moved.GetTranslation().X == 10.0;
	}

	// Blend mutates the receiver: alpha 0/1 are endpoints, 0.5 is midpoint. Source atoms stay put.
	bool Observe_Blend_Nominal()
	{
		FTransform3f Atom1(FVector3f::ZeroVector);
		FTransform3f Atom2(FVector3f(10.0, 0.0, 0.0));
		FTransform3f Blended;
		Blended.Blend(Atom1, Atom2, 0.0);
		bool bAlpha0 = Blended.GetTranslation().IsNearlyZero();
		Blended.Blend(Atom1, Atom2, 1.0);
		bool bAlpha1 = Blended.GetTranslation().Equals(FVector3f(10.0, 0.0, 0.0));
		Blended.Blend(Atom1, Atom2, 0.5);
		bool bAlphaHalf = Blended.GetTranslation().Equals(FVector3f(5.0, 0.0, 0.0));
		return bAlpha0 && bAlpha1 && bAlphaHalf && Atom2.GetTranslation().X == 10.0;
	}
}
/** @end */
