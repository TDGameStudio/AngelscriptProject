/**
 * @version v1
 * @summary Empty class declaration forms.
 * @topic Language
 * @topic Class
 *
 * empty-body                  // An empty class can still be constructed.
 * empty-class-as-parameter    // An empty class can be passed by value.
 */
/**
 * @begin empty-body
 * @summary An empty class can still be constructed.
 * @topic Class
 */
class AEmpty
{
}

int UseEmpty()
{
	AEmpty Object;
	return 0;
}
/** @end */
/**
 * @begin empty-class-as-parameter
 * @summary An empty class can be passed by value.
 * @topic Class
 */
class AEmpty
{
}

int Accept(AEmpty Object)
{
	return 0;
}

int UseParam()
{
	AEmpty Object;
	return Accept(Object);
}
/** @end */
