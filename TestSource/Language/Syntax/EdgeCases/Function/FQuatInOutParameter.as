/**
 * An FQuat inverted in place through an inout parameter. The observers confirm
 * the inversion, the identity boundary, and that inverting twice restores the
 * original.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FQuatInOutParameter
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.FQuatInOutParameter
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageFQuatFunctionTests.cpp::FunctionParametersInOut
 * @Provenance sha256=e1d4400e8882501989b49d3e554d199318f345884953ba05b2bfc4ebe0c6dd90; lines 179-184.
 * @Provenance Oracle: InverseQuat(yaw 90) equals that quat's Inverse. Extra: Identity stays Identity.
 * @Provenance DefaultSafe. &inout mutates caller storage.
 */

namespace SyntaxTest
{
	/**
	 * Inverts a quaternion in place through an inout parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the inout parameter to invert
	 * @Return nothing; the caller's quaternion is replaced by its inverse
	 * @Param q the inout parameter
	 */
	void InverseQuat(FQuat&inout q)
	{
		q = q.Inverse();
	}

	/**
	 * Observe that a yaw-90 quaternion inverts correctly.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a yaw-90 quaternion inverted in place
	 * @Return true when the result equals the pre-computed inverse
	 */
	UFUNCTION()
	bool FQuatInOutNominal()
	{
		FQuat Value = FQuat(FRotator(0, 90, 0));
		FQuat Baseline = Value.Inverse();
		InverseQuat(Value);
		return Value.Equals(Baseline, 0.01);
	}

	/**
	 * Observe that the identity is its own inverse.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the identity quaternion inverted in place
	 * @Return true when the result is still identity
	 * @Boundary identity input
	 */
	UFUNCTION()
	bool FQuatInOutIdentityEmpty()
	{
		FQuat Value = FQuat::Identity;
		InverseQuat(Value);
		return Value.IsIdentity(0.001);
	}

	/**
	 * Observe that inverting twice restores the original.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a yaw-90 quaternion inverted twice
	 * @Return true when the result equals the original
	 * @Boundary double inverse
	 */
	UFUNCTION()
	bool FQuatInOutDoubleInverseBoundary()
	{
		FQuat Original = FQuat(FRotator(0, 90, 0));
		FQuat Value = Original;
		InverseQuat(Value);
		InverseQuat(Value);
		return Value.Equals(Original, 0.01);
	}
}
