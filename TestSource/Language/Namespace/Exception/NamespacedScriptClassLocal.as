/**
 * Declaring a namespaced script class as a local and reading through it
 * throws at runtime instead of failing to compile: the local is a null
 * handle, so the member access raises a script exception. This module
 * compiles; each entry is a RuntimeException trigger, not a bool Observe.
 * The enum half of the original file compiles and runs, so it lives
 * separately in ../Function/NamespaceWithEnum.
 *
 * @Theme Language.Namespace
 * @Subject Namespace.WithClass
 * @Harness RuntimeException
 * @Tag Language.Namespace.NamespacedScriptClassLocal
 * @Namespace NamespaceTest
 * @Provenance C++: AngelscriptCoverageNamespaceTests.cpp::NamespaceWithTypes
 * @Provenance sha256=a7147b327fb84f4eb918ab0055eb9079d651728b5aa169a1bb4391997b0d1f5a; lines 783-828.
 * @Provenance Oracle: UseNamespacedClass remains the runtime null-pointer boundary.
 * @Provenance C++ BuildModule + ExecuteFunctionExpectingScriptException on UseNamespacedClass (not AssertFailsToCompile).
 */

namespace Types
{
	class MyClass
	{
		int Value;

		/**
		 * Reads the member. Reached through the null local, this is where the
		 * runtime exception surfaces.
		 */
		int GetValue()
		{
			return Value;
		}
	}
}

namespace NamespaceTest
{
	/**
	 * Instantiate a namespaced script class as a local and read through it.
	 *
	 * @Kind RuntimeException
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Declare Types::MyClass Obj; assign Obj.Value = 42; return Obj.GetValue()
	 * @Return does not return; the local is a null handle, so the member access throws
	 * @Boundary namespaced script class used as a local
	 */
	UFUNCTION()
	int UseNamespacedClass()
	{
		Types::MyClass Obj;
		Obj.Value = 42;
		return Obj.GetValue();
	}
}
