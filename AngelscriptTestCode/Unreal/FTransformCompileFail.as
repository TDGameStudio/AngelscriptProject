/**
 * @version v1
 * @summary FTransform instantiations that must not compile.
 * @topic Unreal
 * @topic FTransform
 *
 * direct-members-unsupported
 * math-lerp-unsupported
 */
/**
 * @begin direct-members-unsupported
 * @summary The isolated failing program: the three direct members do not exist on FTransform.
 * @topic Negative
 */
void TryDirectMembers()
{
	FTransform T = FTransform::Identity;
	FVector Location = T.Location;
	FVector Scale = T.Scale3D;
	T.Rotation = FQuat::Identity;
}
/** @end */
/**
 * @begin math-lerp-unsupported
 * @summary Math::Lerp is not bound for FTransform, so this program is rejected.
 * @topic Negative
 */
/**
 * The isolated failing program: Math::Lerp has no overload taking two transforms.
 *
 * @Kind CompileReject
 * @Covers FTransform.MathLerpUnsupported
 * @Inputs none
 * @Return does not compile; Math::Lerp is not bound for FTransform
 */
FTransform TryMathLerp()
{
	FTransform A = FTransform(FVector(0, 0, 0));
	FTransform B = FTransform(FVector(100, 100, 100));
	return Math::Lerp(A, B, 0.5f);
}
/** @end */
