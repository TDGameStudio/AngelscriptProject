// Theme: Gameplay.FTransform. Isolated compile-fail: direct Location/Scale3D/Rotation members.
// C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformMemberAccess (failing block)
// CSV Positive; C++ CompileAndExpectFailure.
// Diagnostics: 'Location' is not a member of 'FTransform';
// 'Scale3D' is not a member of 'FTransform';
// 'Rotation' is not a member of 'FTransform'.
// DiagnosticOnly. Do not drop TryDirectMembers.

void TryDirectMembers()
{
	FTransform T = FTransform::Identity;
	FVector Location = T.Location;
	FVector Scale = T.Scale3D;
	T.Rotation = FQuat::Identity;
}
