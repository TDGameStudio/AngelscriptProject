/**
 * @version v1
 * @summary Class handle locals, member reads, and nullptr then construct.
 * @topic Language
 * @topic Class
 *
 * handle-local                  // A local handle produced by Cast<> can read the same field.
 * handle-member-read            // A handle parameter can read a member.
 * handle-null-then-construct    // A handle starts as nullptr and then refers to a constructed instance.
 */
/**
 * @begin handle-local
 * @summary A local handle produced by Cast<> can read the same field.
 * @topic Class
 */
class AHolder
{
	int Value;
}

int UseLocal()
{
	AHolder Object;
	Object.Value = 3;
	AHolder@ Local = Object;
	AHolder@ Again = Cast<AHolder>(Local);
	return Again.Value;
}
/** @end */
/**
 * @begin handle-member-read
 * @summary A handle parameter can read a member.
 * @topic Class
 */
class AHolder
{
	int Value;
}

int ReadMember(AHolder@ Object)
{
	return Object.Value;
}

int UseMemberRead()
{
	AHolder Object;
	Object.Value = 5;
	return ReadMember(Object);
}
/** @end */
/**
 * @begin handle-null-then-construct
 * @summary A handle starts as nullptr and then refers to a constructed instance.
 * @topic Class
 */
class AHolder
{
	int Value;
}

int UseNullThenConstruct()
{
	AHolder@ Object = nullptr;
	AHolder Fresh;
	Fresh.Value = 4;
	Object = Fresh;
	return Object.Value;
}
/** @end */
