/**
 * @version v1
 * @summary Class handle casts that compile and fail when executed.
 * @topic Language
 * @topic Casting
 *
 * use-failed-downcast    // write through a null downcast
 */
/**
 * @begin use-failed-downcast
 * @summary A failed downcast is null; writing through it must not succeed.
 * @topic Negative
 */
class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

void UseFailedDowncast()
{
	ABase Object;
	ADerived@ Child = cast<ADerived>(Object);
	Child.Extra = 1;
}
/** @end */
