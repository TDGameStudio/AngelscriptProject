/**
 * FTransform.ToMatrixWithScale returns an FMatrix by value, so the return type
 * is a struct rather than a handle. Two calls produce equal matrices, and an
 * identity transform produces the identity matrix.
 * This is a math struct return rather than a jump, so it belongs with the math
 * subject; it sits here until moved to a Math geometric-struct directory.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.FMatrixReturnApi
 * @Harness Function
 * @Tag Language.ControlFlow.FMatrixReturnApi
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageMathGeometricStructs.cpp::FMatrixReturnApiCompiles
 * @Provenance sha256=591ddbe5710227697d366fa8b8b0cf0c0a1f5eeecc4f849b9e954840bcbbabcb; lines 621-626.
 * @Provenance Oracle: FTransform.ToMatrixWithScale() compiles as an FMatrix return.
 * @Provenance Extra: identity transform matrix matches FMatrix::Identity().
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace ControlFlowTest
{
	/**
	 * Return the matrix for an identity transform.
	 *
	 * @Covers ControlFlow.Return
	 * @Inputs FTransform::Identity.ToMatrixWithScale()
	 * @Return the identity transform expressed as a matrix
	 */
	FMatrix IdentityTransformAsMatrix()
	{
		return FTransform::Identity.ToMatrixWithScale();
	}

	/**
	 * Observe that repeated calls produce equal matrices.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Call the returning function twice
	 * @Return true when both results are equal
	 */
	UFUNCTION()
	bool MatrixReturnIsStableAcrossCalls()
	{
		FMatrix First = IdentityTransformAsMatrix();
		FMatrix Second = IdentityTransformAsMatrix();
		return First == Second;
	}

	/**
	 * Observe that an identity transform produces the identity matrix.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Compare the returned matrix against the identity
	 * @Return true when the result is the identity matrix
	 * @Boundary identity transform
	 */
	UFUNCTION()
	bool IdentityTransformYieldsIdentityMatrix()
	{
		return IdentityTransformAsMatrix() == FMatrix::Identity();
	}
}
