/**
 * @version v1
 * @summary A typedef may alias a class handle type.
 * @topic Language
 * @topic Typedef
 */
/**
 * @version root
 * @summary typedef AHolder@ HolderRef can be passed and used to read Value.
 * @topic Baseline
 */
class AHolder
{
	int Value;
}

typedef AHolder@ HolderRef;

int Read(HolderRef Object)
{
	return Object.Value;
}
/** @end */
/**
 * @version valid-handle-alias-local
 * @parent root
 * @summary A HolderRef local can alias a constructed AHolder and read 6.
 * @topic Typedef
 */
class AHolder
{
	int Value;
}

typedef AHolder@ HolderRef;

int UseLocal()
{
	AHolder Object;
	Object.Value = 6;
	HolderRef Ref = Object;
	return Ref.Value;
}
/** @end */
/**
 * @version invalid-handle-alias-of-unknown-class
 * @parent root
 * @summary A handle typedef requires the class type to exist.
 * @topic Negative
 */
typedef AMissing@ HolderRef;
/** @end */
