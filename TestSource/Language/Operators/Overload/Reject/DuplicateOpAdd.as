/**
 * Declaring opAdd twice in one type is rejected: the operator would have no
 * single definition. This file is the illegal program itself; do not drop
 * either overload or rename one, since the duplication is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.DuplicateOpAdd
 * @Harness CompileReject
 * @Tag Language.Operators.DuplicateOpAdd
 * @Kind CompileReject
 * @Covers Operators.Overload
 * @Inputs A struct declaring two identical opAdd overloads
 * @Return does not compile; diagnostic "duplicate opAdd overload should fail"
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative AssertFailsToCompile ASSyntaxOODuplicateAdd; lines 322-330;
 * @Provenance sha256=accd20214cbae6077e0de6c8bd277e5a2bbd9fbf825028f1f71428ff79e13a20.
 * @Provenance Expected diagnostic: duplicate opAdd overload should fail.
 * @Provenance Do not drop either overload or rename one to make this compile.
 * @Provenance DiagnosticOnly.
 */

struct FVecDupAdd
{
	int X = 0;

	/**
	 * The first of two identical opAdd declarations.
	 */
	FVecDupAdd opAdd(const FVecDupAdd&in Other) const
	{
		return FVecDupAdd();
	}

	/**
	 * The second of two identical opAdd declarations.
	 */
	FVecDupAdd opAdd(const FVecDupAdd&in Other) const
	{
		return FVecDupAdd();
	}
}
