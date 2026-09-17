/**
 * @version v1
 * @summary A public field can be written after default construction and read back.
 * @topic Language
 * @topic Class
 */
/**
 * @version root
 * @summary Object.Value = 5 is read back as 5.
 * @topic Baseline
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
 * @version valid-field-compound-assign
 * @parent root
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
 * @version invalid-unknown-field
 * @parent root
 * @summary Writing a name that is not a member is rejected.
 * @topic Negative
 */
class AHolder
{
	int Value;
}

void Test()
{
	AHolder Object;
	Object.Missing = 1;
}
/** @end */
