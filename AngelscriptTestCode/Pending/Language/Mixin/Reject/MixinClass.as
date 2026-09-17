/**
 * @version v1
 * @summary Mixin class syntax is unsupported; isolate the declaration with no host actor.
 * @topic Language
 * @topic Mixin
 */
/**
 * @version root
 * @summary A mixin class declaration is rejected.
 * @topic Negative
 */
mixin class UCoverageMixin
{
	int SharedValue = 1;
}
/** @end */
/**
 * @version invalid-mixin-class-with-method
 * @parent root
 * @summary A mixin class that also declares a method is still rejected.
 * @topic Negative
 */
mixin class UHealthMixin
{
	int Health = 100;

	void TakeDamage(int Amount)
	{
		Health -= Amount;
	}
}
/** @end */
