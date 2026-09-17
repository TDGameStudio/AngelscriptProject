/**
 * @version v1
 * @summary Upcast, downcast, and round-trip class handle casts.
 * @topic Language
 * @topic Casting
 *
 * implicit-derived-to-base      // derived handle converts to base
 * cast-to-parent                // explicit Cast to the parent class
 * cast-downcast                 // explicit downcast from a base handle
 *   cast-downcast-null-guard    // same downcast, reject a nullptr result
 * cast-round-trip               // upcast then downcast, with a nullptr check
 * cast-null-handle              // Cast a nullptr base handle to derived
 * cast-same-type                // Cast a handle to its own class
 */
/**
 * @begin implicit-derived-to-base
 * @summary Implicit derived handle converts to base.
 */
class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

ABase@ ImplicitDerivedToBase(ADerived@ Child)
{
	ABase@ Parent = Child;
	return Parent;
}
/** @end */
/**
 * @begin cast-to-parent
 * @summary Explicit Cast to the parent class.
 */
class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

ABase@ CastToParent(ADerived@ Child)
{
	return Cast<ABase>(Child);
}
/** @end */
/**
 * @begin cast-downcast
 * @summary Explicit downcast from a base handle.
 *
 * cast-downcast                // explicit downcast from a base handle
 *   cast-downcast-null-guard   // same downcast, reject a nullptr result
 */
class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

ADerived@ CastDowncast(ABase@ Parent)
{
	return Cast<ADerived>(Parent);
}
/** @end */
/**
 * @begin cast-downcast-null-guard
 * @parent cast-downcast
 * @summary Same downcast, then reject a nullptr result.
 */
class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

ADerived@ CastDowncast(ABase@ Parent)
{
	ADerived@ Child = Cast<ADerived>(Parent);
	if (Child == nullptr)
	{
		return nullptr;
	}
	return Child;
}
/** @end */
/**
 * @begin cast-round-trip
 * @summary Upcast then downcast, with a nullptr check.
 */
class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

ADerived@ CastRoundTrip(ADerived@ Child)
{
	ABase@ Parent = Child;
	ADerived@ Again = Cast<ADerived>(Parent);
	if (Again == nullptr)
	{
		return nullptr;
	}
	return Again;
}
/** @end */
/**
 * @begin cast-null-handle
 * @summary Cast a nullptr base handle to derived.
 */
class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

ADerived@ CastNullHandle()
{
	ABase@ Parent = nullptr;
	return Cast<ADerived>(Parent);
}
/** @end */
/**
 * @begin cast-same-type
 * @summary Cast a handle to its own class.
 */
class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

ADerived@ CastSameType(ADerived@ Child)
{
	return Cast<ADerived>(Child);
}
/** @end */
