/**
 * @version v1
 * @summary Declaring a namespaced script class as a local and reading through it throws at runtime instead of failing to compile: the local is a null handle, so the member access raises a script exception. This module compiles.
 * @topic Language
 */
/**
 * @version root
 * @summary Declaring a namespaced script class as a local and reading through it throws at runtime instead of failing to compile: the local is a null handle, so the member access raises a script exception. This module compiles.
 * @topic Baseline
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
/** @end */
