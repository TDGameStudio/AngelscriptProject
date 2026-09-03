/**
 * Reading a member that was never declared inside a namespace is rejected.
 * The namespace itself exists and holds a member, but the qualified name
 * names one that does not.
 *
 * @Theme Language.Namespace
 * @Subject Namespace.MissingMember
 * @Harness CompileReject
 * @Tag Language.Namespace.NamespaceMissingMember
 * @Kind CompileReject
 * @Covers Namespace.QualifiedAccess
 * @Inputs namespace MySpaceBadAcc { int X = 1; } then read MySpaceBadAcc::NonExistent
 * @Return does not compile; diagnostic "NonExistent is not a member of MySpaceBadAcc"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Namespace_Mixed block 5.
 * @Provenance sha256=eaef48fa2595e7e0ea5775d40e4760f480694426dff8e9059d0cf3b45f94d91c; lines 525-528.
 * @Provenance Expected diagnostic: NonExistent is not a member of MySpaceBadAcc.
 * @Provenance CSV SourceShape is Positive / DefaultSafe; C++ uses AssertFailsToCompile.
 */

namespace MySpaceBadAcc
{
	int X = 1;
}

void Test()
{
	int Y = MySpaceBadAcc::NonExistent;
}
