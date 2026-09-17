/**
 * @version v1
 * @summary Pure, default, and UFUNCTION methods on a script interface are rejected. Keep all three forms; stripping any of them would change the boundary.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Pure, default, and UFUNCTION methods on a script interface are rejected. Keep all three forms; stripping any of them would change the boundary.
 * @topic Negative
 */
interface ICoverageUnsupportedMethodInterface
{
	/**
	 * A pure method declaration inside the unsupported script interface.
	 *
	 * @Covers UInterface.ScriptInterfaceMethodsRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void PureMethod();

	/**
	 * A defaulted method whose body sits inside the unsupported script interface.
	 *
	 * @Covers UInterface.ScriptInterfaceMethodsRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void DefaultMethod()
	{
	}

	/**
	 * A reflected method whose UFUNCTION annotation sits inside the unsupported interface.
	 *
	 * @Covers UInterface.ScriptInterfaceMethodsRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	UFUNCTION()
	void ReflectedMethod();
}
/** @end */
