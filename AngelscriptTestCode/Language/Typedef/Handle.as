/**
 * @version v1
 * @summary Typedef aliases of class handle types.
 * @topic Language
 * @topic Typedef
 *
 * typedef-handle        // typedef AHolder@ HolderRef can be passed and used to read Value.
 * handle-alias-local    // A HolderRef local can alias a constructed AHolder and read 6.
 */
/**
 * @begin typedef-handle
 * @summary typedef AHolder@ HolderRef can be passed and used to read Value.
 * @topic Typedef
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
 * @begin handle-alias-local
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
