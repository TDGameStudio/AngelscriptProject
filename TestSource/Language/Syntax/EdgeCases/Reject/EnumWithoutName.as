/**
 * An enum declaration with no name is rejected. C++ currently wraps this
 * AssertFailsToCompile in #if 0 because an anonymous enum trips a preprocessor
 * ensure crash, but the case remains a reject by intent. This file is the
 * illegal program itself; do not invent an enum name, since the missing name is
 * the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.EnumWithoutName
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.EnumWithoutName
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs an enum declaration with no identifier
 * @Return does not compile; a successful compile counts as failure
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Enum_Negative block 1 is #if 0
 * @Provenance AssertFailsToCompile (preprocessor-ensure-crash on anonymous enum).
 * @Provenance sha256=d3f44f1c169a1264b6e73d05ba95325591f3f2113d73231dd6f47770a1afdae6; lines 379-381.
 * @Provenance Expected diagnostic: unnamed enum / DetectEnum ensure. Successful compile is failure.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

enum
{
	Value1
}
