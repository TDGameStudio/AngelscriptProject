/**
 * @version v1
 * @summary Class field assignment and in-class initializers.
 * @topic Language
 * @topic Class
 *
 * field-assign               // Object.Value = 5 is read back as 5.
 * field-compound-assign      // A field accepts += after a first write.
 * field-initializer          // int Value = 3 is read back as 3 on a default-constructed instance.
 * float-field-initializer    // A float field initializer is read back after default construction.
 * initializer-then-assign    // A later field write replaces the in-class initializer.
 * two-int-fields             // Two integer fields can be written and read independently.
 * bool-field-initializer     // A bool field initializer is read back after default construction.
 */
/**
 * @begin field-assign
 * @summary Object.Value = 5 is read back as 5.
 * @topic Class
 */
class AHolder
{
	int Value;
}

int AssignThenRead()
{
	AHolder Object;
	Object.Value = 5;
	return Object.Value;
}
/** @end */
/**
 * @begin field-compound-assign
 * @summary A field accepts += after a first write.
 * @topic Class
 */
class AHolder
{
	int Value;
}

int Compound()
{
	AHolder Object;
	Object.Value = 2;
	Object.Value += 7;
	return Object.Value;
}
/** @end */
/**
 * @begin field-initializer
 * @summary int Value = 3 is read back as 3 on a default-constructed instance.
 * @topic Class
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
 * @begin float-field-initializer
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
 * @begin initializer-then-assign
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
/**
 * @begin two-int-fields
 * @summary Two integer fields can be written and read independently.
 * @topic Class
 */
class APoint
{
	int X;
	int Y;
}

int UseTwoFields()
{
	APoint Object;
	Object.X = 1;
	Object.Y = 2;
	return Object.X + Object.Y;
}
/** @end */
/**
 * @begin bool-field-initializer
 * @summary A bool field initializer is read back after default construction.
 * @topic Class
 */
class AFlag
{
	bool Ready = true;
}

bool ReadReady()
{
	AFlag Object;
	return Object.Ready;
}
/** @end */
