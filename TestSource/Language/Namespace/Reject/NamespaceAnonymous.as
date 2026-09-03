/**
 * An anonymous namespace is rejected: a namespace must carry a name. This
 * file is the illegal program itself; it compiles only in the sense that it
 * is supposed to fail.
 *
 * @Theme Language.Namespace
 * @Subject Namespace.Anonymous
 * @Harness CompileReject
 * @Tag Language.Namespace.NamespaceAnonymous
 * @Kind CompileReject
 * @Covers Namespace.Declaration
 * @Inputs namespace { int X; }
 * @Return does not compile; diagnostic "anonymous namespace"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Namespace_Mixed block 4.
 * @Provenance sha256=76b5afd15f61c26f4b5c44741781c967457d76be72992181b5a8554966ea2d22; lines 518-520.
 * @Provenance Expected diagnostic: anonymous namespace.
 * @Provenance CSV SourceShape is Positive; C++ uses AssertFailsToCompile (currently #if 0: compile still succeeds with an error log).
 */

namespace
{
	int X;
}
