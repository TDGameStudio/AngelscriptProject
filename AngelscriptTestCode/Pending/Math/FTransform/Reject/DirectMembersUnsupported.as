/**
 * @version v1
 * @summary The direct Location, Scale3D and Rotation members are not exposed on the current binding surface, so this program is rejected. C++ compiles it as the module ASCovFTransformExpr_DirectMembersUnsupported and expects a.
 * @topic Math
 */
/**
 * @version root
 * @summary The direct Location, Scale3D and Rotation members are not exposed on the current binding surface, so this program is rejected. C++ compiles it as the module ASCovFTransformExpr_DirectMembersUnsupported and expects a.
 * @topic Negative
 */
/**
 * The isolated failing program: the three direct members do not exist on FTransform.
 *
 * @Kind CompileReject
 * @Covers FTransform.DirectMembersUnsupported
 * @Inputs none
 * @Return does not compile; Location, Scale3D and Rotation are not exposed members
 */
void TryDirectMembers()
{
	FTransform T = FTransform::Identity;
	FVector Location = T.Location;
	FVector Scale = T.Scale3D;
	T.Rotation = FQuat::Identity;
}
/** @end */
