/**
 * @version v1
 * @summary The advanced FQuat operators and methods: copy construction and assignment, the compound and scalar operators, the axis-angle and direction accessors, the interpolation and error helpers, and the swing-twist.
 * @topic Math
 */
/**
 * @version root
 * @summary The advanced FQuat operators and methods: copy construction and assignment, the compound and scalar operators, the axis-angle and direction accessors, the interpolation and error helpers, and the swing-twist.
 * @topic Baseline
 */
namespace FQuatTest
{
	/**
	 * Observe that copy construction and assignment both reproduce the source, and that
	 * the equality operator agrees with the toleranced comparison.
	 *
	 * @Kind Observe
	 * @Covers FQuat.AdvancedOperatorsAndMethods
	 * @Inputs a quarter-turn quaternion
	 * @Return true when the assignment compares equal both exactly and within tolerance
	 */
	UFUNCTION()
	bool CopyAssignAndEquality()
	{
		FQuat Source = FQuat(FVector::UpVector, 1.5707963267948966);
		FQuat Copy(Source);
		FQuat Assigned;
		Assigned = Copy;

		if (Assigned != Source)
		{
			return false;
		}
		return Assigned.Equals(Source, 0.001);
	}

	/**
	 * Observe that the compound, scalar, addition and subtraction operators round-trip a
	 * quarter turn.
	 *
	 * @Kind Observe
	 * @Covers FQuat.AdvancedOperatorsAndMethods
	 * @Inputs none
	 * @Return true when both the scaled and the added-then-subtracted results match
	 */
	UFUNCTION()
	bool CompoundAndScalarOperators()
	{
		FQuat QuarterTurn = FQuat(FVector::UpVector, 1.5707963267948966);
		FQuat Working = FQuat::Identity;
		Working *= QuarterTurn;
		FQuat Inflated = Working * 2.0;
		Inflated /= 2.0;
		FQuat AddedThenSubtracted = (Working + FQuat::Identity) - FQuat::Identity;

		if (!Inflated.Equals(QuarterTurn, 0.001))
		{
			return false;
		}
		return AddedThenSubtracted.Equals(QuarterTurn, 0.001);
	}

	/**
	 * Observe that the axis-angle decomposition recovers the construction axis and angle,
	 * and that the direction accessors agree with the axes.
	 *
	 * @Kind Observe
	 * @Covers FQuat.AdvancedOperatorsAndMethods
	 * @Inputs a quarter turn about the up axis
	 * @Return true when the axis, the angle and both direction accessors agree
	 */
	UFUNCTION()
	bool AxisAngleAndDirectionMethods()
	{
		FQuat QuarterTurn = FQuat(FVector::UpVector, 1.5707963267948966);
		FVector Axis;
		float64 Angle = 0.0;
		QuarterTurn.ToAxisAndAngle(Axis, Angle);

		if (!Axis.Equals(FVector::UpVector, 0.001))
		{
			return false;
		}
		if (Math::Abs(Angle - 1.5707963267948966) >= 0.001)
		{
			return false;
		}
		if (!QuarterTurn.GetForwardVector().Equals(QuarterTurn.GetAxisX(), 0.001))
		{
			return false;
		}
		return QuarterTurn.Vector().Equals(QuarterTurn.GetAxisX(), 0.001);
	}

	/**
	 * Observe that the fast and full interpolation paths stay normalized and close
	 * together, including through the auto-normalizing error helper.
	 *
	 * @Kind Observe
	 * @Covers FQuat.AdvancedOperatorsAndMethods
	 * @Inputs the identity and a quarter turn to interpolate between
	 * @Return true when both midpoints are normalized and the error stays below 0.1
	 */
	UFUNCTION()
	bool InterpolationAndErrorMethods()
	{
		FQuat Start = FQuat::Identity;
		FQuat End = FQuat(FVector::UpVector, 1.5707963267948966);
		FQuat Fast = FQuat::FastLerp(Start, End, 0.5).GetNormalized();
		FQuat Full = FQuat::SlerpFullPath(Start, End, 0.5);
		float64 Error = FQuat::Error(Fast, Full);

		if (!Fast.IsNormalized())
		{
			return false;
		}
		if (!Full.IsNormalized())
		{
			return false;
		}
		if (Error >= 0.1)
		{
			return false;
		}
		return FQuat::ErrorAutoNormalize(Fast * 2.0, Full * 3.0) < 0.1;
	}

	/**
	 * Observe that the swing-twist decomposition stays normalized, that the twist angle
	 * recovers the construction angle, and that the computed tangent is finite.
	 *
	 * @Kind Observe
	 * @Covers FQuat.AdvancedOperatorsAndMethods
	 * @Inputs a quarter turn and a half turn about the up axis
	 * @Return true when both parts are normalized, the twist angle matches and the tangent
	 * holds no NaN
	 */
	UFUNCTION()
	bool SwingTwistAndTangents()
	{
		FQuat Rotation = FQuat(FVector::UpVector, 1.5707963267948966);
		FQuat Swing;
		FQuat Twist;
		Rotation.ToSwingTwist(FVector::UpVector, Swing, Twist);

		FQuat Tangent;
		FQuat::CalcTangents(FQuat::Identity, Rotation, FQuat(FVector::UpVector, 3.1415926535897932), 0.0, Tangent);

		if (!Twist.IsNormalized())
		{
			return false;
		}
		if (!Swing.IsNormalized())
		{
			return false;
		}
		if (Math::Abs(Rotation.GetTwistAngle(FVector::UpVector) - 1.5707963267948966) >= 0.001)
		{
			return false;
		}
		return !Tangent.ContainsNaN();
	}

	/**
	 * Observe that copy construction and assignment reproduce the source.
	 *
	 * @Kind Observe
	 * @Covers FQuat.AdvancedOperatorsAndMethods
	 * @Inputs none
	 * @Return CopyAssignAndEquality(), expected true
	 */
	UFUNCTION()
	bool CopyAssignAndEqualityNominal()
	{
		return CopyAssignAndEquality();
	}

	/**
	 * Observe that the compound and scalar operators round-trip.
	 *
	 * @Kind Observe
	 * @Covers FQuat.AdvancedOperatorsAndMethods
	 * @Inputs none
	 * @Return CompoundAndScalarOperators(), expected true
	 */
	UFUNCTION()
	bool CompoundAndScalarOperatorsNominal()
	{
		return CompoundAndScalarOperators();
	}

	/**
	 * Observe that the axis-angle and direction accessors agree.
	 *
	 * @Kind Observe
	 * @Covers FQuat.AdvancedOperatorsAndMethods
	 * @Inputs none
	 * @Return AxisAngleAndDirectionMethods(), expected true
	 */
	UFUNCTION()
	bool AxisAngleAndDirectionMethodsNominal()
	{
		return AxisAngleAndDirectionMethods();
	}

	/**
	 * Observe that the interpolation and error helpers agree.
	 *
	 * @Kind Observe
	 * @Covers FQuat.AdvancedOperatorsAndMethods
	 * @Inputs none
	 * @Return InterpolationAndErrorMethods(), expected true
	 */
	UFUNCTION()
	bool InterpolationAndErrorMethodsNominal()
	{
		return InterpolationAndErrorMethods();
	}

	/**
	 * Observe that the swing-twist decomposition holds.
	 *
	 * @Kind Observe
	 * @Covers FQuat.AdvancedOperatorsAndMethods
	 * @Inputs none
	 * @Return SwingTwistAndTangents(), expected true
	 */
	UFUNCTION()
	bool SwingTwistAndTangentsNominal()
	{
		return SwingTwistAndTangents();
	}

	/**
	 * Observe that a default-assigned quaternion is the identity.
	 *
	 * @Kind Observe
	 * @Covers FQuat.AdvancedOperatorsAndMethods
	 * @Inputs a default-constructed quaternion
	 * @Return true when it equals the identity constant
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmptyAssigned()
	{
		FQuat Assigned;
		return Assigned.Equals(FQuat::Identity, 0.001);
	}

	/**
	 * Observe that mutating a copy leaves the source quaternion untouched.
	 *
	 * @Kind Observe
	 * @Covers FQuat.AdvancedOperatorsAndMethods
	 * @Inputs a quarter turn and a mutated copy of it
	 * @Return true when the source still holds the quarter turn
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyAssignCopyIndependence()
	{
		FQuat Source = FQuat(FVector::UpVector, 1.5707963267948966);
		FQuat Copy(Source);
		Copy.X = 0.0;
		return Source.Equals(FQuat(FVector::UpVector, 1.5707963267948966), 0.001);
	}
}
/** @end */
