// Theme: Gameplay.FQuat. Positive advanced operator / method oracles.
// C++: AngelscriptCoverageFQuatExpressionTests.cpp::QuatAdvancedOperatorsAndMethods
// Oracle: CopyAssignAndEquality true; CompoundAndScalarOperators true;
// AxisAngleAndDirectionMethods true; InterpolationAndErrorMethods true;
// SwingTwistAndTangents true.
// Extra: default Assigned Identity; copy independence of Source. DefaultSafe.

bool CopyAssignAndEquality()
{
	FQuat Source = FQuat(FVector::UpVector, 1.5707963267948966);
	FQuat Copy(Source);
	FQuat Assigned;
	Assigned = Copy;
	return Assigned == Source && Assigned.Equals(Source, 0.001);
}

bool CompoundAndScalarOperators()
{
	FQuat QuarterTurn = FQuat(FVector::UpVector, 1.5707963267948966);
	FQuat Working = FQuat::Identity;
	Working *= QuarterTurn;
	FQuat Inflated = Working * 2.0;
	Inflated /= 2.0;
	FQuat AddedThenSubtracted = (Working + FQuat::Identity) - FQuat::Identity;
	return Inflated.Equals(QuarterTurn, 0.001)
		&& AddedThenSubtracted.Equals(QuarterTurn, 0.001);
}

bool AxisAngleAndDirectionMethods()
{
	FQuat QuarterTurn = FQuat(FVector::UpVector, 1.5707963267948966);
	FVector Axis;
	float64 Angle = 0.0;
	QuarterTurn.ToAxisAndAngle(Axis, Angle);
	return Axis.Equals(FVector::UpVector, 0.001)
		&& Math::Abs(Angle - 1.5707963267948966) < 0.001
		&& QuarterTurn.GetForwardVector().Equals(QuarterTurn.GetAxisX(), 0.001)
		&& QuarterTurn.Vector().Equals(QuarterTurn.GetAxisX(), 0.001);
}

bool InterpolationAndErrorMethods()
{
	FQuat Start = FQuat::Identity;
	FQuat End = FQuat(FVector::UpVector, 1.5707963267948966);
	FQuat Fast = FQuat::FastLerp(Start, End, 0.5).GetNormalized();
	FQuat Full = FQuat::SlerpFullPath(Start, End, 0.5);
	float64 Error = FQuat::Error(Fast, Full);
	return Fast.IsNormalized()
		&& Full.IsNormalized()
		&& Error < 0.1
		&& FQuat::ErrorAutoNormalize(Fast * 2.0, Full * 3.0) < 0.1;
}

bool SwingTwistAndTangents()
{
	FQuat Rotation = FQuat(FVector::UpVector, 1.5707963267948966);
	FQuat Swing;
	FQuat Twist;
	Rotation.ToSwingTwist(FVector::UpVector, Swing, Twist);

	FQuat Tangent;
	FQuat::CalcTangents(FQuat::Identity, Rotation, FQuat(FVector::UpVector, 3.1415926535897932), 0.0, Tangent);

	return Twist.IsNormalized()
		&& Swing.IsNormalized()
		&& Math::Abs(Rotation.GetTwistAngle(FVector::UpVector) - 1.5707963267948966) < 0.001
		&& !Tangent.ContainsNaN();
}

bool Observe_CopyAssignAndEquality()
{
	return CopyAssignAndEquality() == true;
}

bool Observe_CompoundAndScalarOperators()
{
	return CompoundAndScalarOperators() == true;
}

bool Observe_AxisAngleAndDirectionMethods()
{
	return AxisAngleAndDirectionMethods() == true;
}

bool Observe_InterpolationAndErrorMethods()
{
	return InterpolationAndErrorMethods() == true;
}

bool Observe_SwingTwistAndTangents()
{
	return SwingTwistAndTangents() == true;
}

bool Observe_CopyAssign_DefaultEmptyAssigned()
{
	FQuat Assigned;
	return Assigned.Equals(FQuat::Identity, 0.001);
}

bool Observe_CopyAssign_CopyIndependence()
{
	FQuat Source = FQuat(FVector::UpVector, 1.5707963267948966);
	FQuat Copy(Source);
	Copy.X = 0.0;
	return Source.Equals(FQuat(FVector::UpVector, 1.5707963267948966), 0.001);
}
