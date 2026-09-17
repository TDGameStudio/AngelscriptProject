/**
 * @version v1
 * @summary A class whose body contains no members.
 * @topic Language
 * @topic Class
 */
/**
 * @version root
 * @summary An empty class can still be constructed.
 * @topic Baseline
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
 * @version valid-empty-class-as-parameter
 * @parent root
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
/**
 * @version invalid-unknown-member-on-empty
 * @parent root
 * @summary An empty class has no members to read.
 * @topic Negative
 */
class AEmpty
{
}

int Test()
{
	AEmpty Object;
	return Object.Missing;
}
/** @end */
