/**
 * The direct Location, Scale3D and Rotation members are not exposed on the current
 * binding surface, so this program is rejected. C++ compiles it as the module
 * ASCovFTransformExpr_DirectMembersUnsupported and expects a diagnostic naming each of the
 * three. The accessor and mutator methods are the bound path and are covered separately.
 * The CSV Positive label is wrong; C++ does not compile this.
 *
 * @Theme Math.FTransform
 * @Subject FTransform.DirectMembersUnsupported
 * @Harness CompileReject
 * @Tag Math.FTransform.DirectMembersUnsupported
 * @Provenance Theme: Gameplay.FTransform. Isolated compile-fail: direct Location/Scale3D/Rotation members.
 * @Provenance C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformMemberAccess (failing block)
 * @Provenance CSV Positive; C++ CompileAndExpectFailure.
 * @Provenance Diagnostics: 'Location' is not a member of 'FTransform';
 * @Provenance 'Scale3D' is not a member of 'FTransform';
 * @Provenance 'Rotation' is not a member of 'FTransform'.
 * @Provenance DiagnosticOnly. Do not drop TryDirectMembers.
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
