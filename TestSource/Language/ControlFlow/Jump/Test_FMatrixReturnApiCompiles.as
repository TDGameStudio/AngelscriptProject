// Theme: Language.ControlFlow.Jump. Positive compile/value oracle from FMatrixReturnApiCompiles.
// C++: AngelscriptCoverageMathGeometricStructs.cpp::FMatrixReturnApiCompiles
// sha256=591ddbe5710227697d366fa8b8b0cf0c0a1f5eeecc4f849b9e954840bcbbabcb; lines 621-626.
// Oracle: FTransform.ToMatrixWithScale() compiles as an FMatrix return.
// Extra: identity transform matrix matches FMatrix::Identity(); default FMatrix is not that identity until SetIdentity.
// DefaultSafe. Source owns locals.

FMatrix TriggerMatrixReturn()
{
	return FTransform::Identity.ToMatrixWithScale();
}

bool Observe_TriggerMatrixReturn_Nominal()
{
	FMatrix First = TriggerMatrixReturn();
	FMatrix Second = TriggerMatrixReturn();
	return First == Second && First == FTransform::Identity.ToMatrixWithScale();
}

bool Observe_TriggerMatrixReturn_Identity()
{
	return TriggerMatrixReturn() == FMatrix::Identity();
}
