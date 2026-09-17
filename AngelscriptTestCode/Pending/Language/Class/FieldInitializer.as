/**
 * @version v1
 * @summary An in-class field initializer is the value read after default construction.
 * @topic Language
 * @topic Class
 */
/**
 * @version root
 * @summary int Value = 3 is read back as 3 on a default-constructed instance.
 * @topic Baseline
 */
class AHolder
{
	int Value = 3;
}

int ReadDefault()
{
	AHolder Object;
	return Object.Value;
}
/** @end */
/**
 * @version valid-float-field-initializer
 * @parent root
 * @summary A float field initializer is read back after default construction.
 * @topic Class
 */
class AScale
{
	float Amount = 2.5f;
}

float ReadAmount()
{
	AScale Object;
	return Object.Amount;
}
/** @end */
/**
 * @version valid-initializer-then-assign
 * @parent root
 * @summary A later field write replaces the in-class initializer.
 * @topic Class
 */
class AHolder
{
	int Value = 3;
}

int Overwrite()
{
	AHolder Object;
	Object.Value = 9;
	return Object.Value;
}
/** @end */
