// Purpose: Observe remaining FTransform constructors, Inverse, Blend, and
// BlendWith.
// AS-facing API: FTransform(); copy; translation; quat; rotator; axes;
// FTransform3f; Inverse(); Blend; BlendWith.
// Inputs: Default identity, copy, translation (1,2,3), identity quat, yaw 90,
// world axes plus translation, FTransform3f conversion, Inverse of (10,0,0),
// blend translations 0 and 10 at alpha 0/0.5/1.
// Expected observations: Default equals Identity. Copy is independent.
// Translation/quat/rotator/axes/FTransform3f store the supplied parts. Inverse
// of +10 X is -10 X. Blend alpha 0/1 selects endpoints; 0.5 is midpoint.
// BlendWith alpha 0 keeps the receiver.
// Boundary/ownership: Inverse/Blend results do not mutate the source atoms.
// Blend and BlendWith mutate the receiver.

namespace TS_FTransform_Behavior_01
{
	bool Observe_Transform_Nominal()
	{
		FTransform DefaultTransform;
		FTransform Copied(FTransform(FVector(1.0, 2.0, 3.0)));
		FTransform FromTranslation(FVector(1.0, 2.0, 3.0));
		FTransform FromQuat(FQuat::Identity);
		FTransform FromRotator(FRotator(0.0, 90.0, 0.0));
		FTransform FromAxes(FVector::ForwardVector, FVector::RightVector, FVector::UpVector, FVector(4.0, 5.0, 6.0));
		FTransform3f Single(FVector3f(7.0, 8.0, 9.0));
		FTransform FromSingle(Single);
		FTransform Original = Copied;
		Copied.SetTranslation(FVector::ZeroVector);
		return DefaultTransform.Equals(FTransform::Identity) &&
			Original.GetTranslation().X == 1.0 &&
			FromTranslation.GetTranslation().Equals(FVector(1.0, 2.0, 3.0)) &&
			FromQuat.GetRotation().Equals(FQuat::Identity) &&
			FromRotator.Rotator().Equals(FRotator(0.0, 90.0, 0.0)) &&
			FromAxes.GetTranslation().Equals(FVector(4.0, 5.0, 6.0)) &&
			FromAxes.GetRotation().Equals(FQuat::Identity) &&
			FromSingle.GetTranslation().Equals(FVector(7.0, 8.0, 9.0));
	}

	bool Observe_Inverse_Nominal()
	{
		FTransform Moved(FVector(10.0, 0.0, 0.0));
		FTransform Inverse = Moved.Inverse();
		FTransform IdentityInverse = FTransform::Identity.Inverse();
		return Inverse.GetTranslation().Equals(FVector(-10.0, 0.0, 0.0)) &&
			IdentityInverse.Equals(FTransform::Identity) &&
			Moved.GetTranslation().X == 10.0;
	}

	bool Observe_Blend_Nominal()
	{
		FTransform Atom1(FVector::ZeroVector);
		FTransform Atom2(FVector(10.0, 0.0, 0.0));
		FTransform Blended;
		Blended.Blend(Atom1, Atom2, 0.0);
		bool bAlpha0 = Blended.GetTranslation().IsNearlyZero();
		Blended.Blend(Atom1, Atom2, 1.0);
		bool bAlpha1 = Blended.GetTranslation().Equals(FVector(10.0, 0.0, 0.0));
		Blended.Blend(Atom1, Atom2, 0.5);
		bool bAlphaHalf = Blended.GetTranslation().Equals(FVector(5.0, 0.0, 0.0));
		return bAlpha0 && bAlpha1 && bAlphaHalf && Atom2.GetTranslation().X == 10.0;
	}

	bool Observe_BlendWith_Nominal()
	{
		FTransform Current(FVector::ZeroVector);
		FTransform Other(FVector(10.0, 0.0, 0.0));
		Current.BlendWith(Other, 0.0);
		bool bKept = Current.GetTranslation().IsNearlyZero();
		Current.BlendWith(Other, 1.0);
		return bKept && Current.GetTranslation().Equals(FVector(10.0, 0.0, 0.0)) && Other.GetTranslation().X == 10.0;
	}
}
