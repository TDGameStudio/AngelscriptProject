/**
 * @version v1
 * @summary Isolated compile-fail: a virtual property get/set block on Health. C++ VirtualPropertyFails AssertFailsWithError "Virtual property syntax has been removed".
 * @topic Feature
 */
/**
 * @version root
 * @summary Isolated compile-fail: a virtual property get/set block on Health. C++ VirtualPropertyFails AssertFailsWithError "Virtual property syntax has been removed".
 * @topic Negative
 */
class AActorPAVirtual : AActor
{
	int Health
	{
		get
		{
			return 100;
		}

		set
		{
		}
	}
}
/** @end */
