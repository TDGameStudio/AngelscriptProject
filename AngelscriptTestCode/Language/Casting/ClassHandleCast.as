/**
 * @version v1
 * @summary Upcast, downcast, and round-trip class handle casts.
 * @topic Language
 * @topic Casting
 *
 * implicit-derived-to-base     // implicit Derived@ to Base@
 * cast-to-parent               // cast<Base>(Derived@)
 * cast-downcast                // cast<Derived>(Base@)
 *   cast-downcast-null-guard   // same program + null check; parent cast-downcast
 * cast-round-trip              // upcast then downcast; sibling, not a child
 */
/**
 * @begin implicit-derived-to-base
 * @summary Implicit derived handle converts to base.
 * @topic Casting
 */
class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

/**
 * @function ImplicitDerivedToBase
 * @summary Implicit derived handle converts to base.
 * @covers implicit handle conversion
 * @inputs a live ADerived@
 * @return the same object as ABase@
 */
ABase@ ImplicitDerivedToBase(ADerived@ Child)
{
	ABase@ Parent = Child;
	return Parent;
}
/** @end */
/**
 * @begin cast-to-parent
 * @summary Explicit cast to the parent class.
 * @topic Casting
 */
class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

/**
 * @function CastToParent
 * @summary Explicit cast to the parent class.
 * @covers cast<Base>
 * @inputs a live ADerived@
 * @return the same object as ABase@
 */
ABase@ CastToParent(ADerived@ Child)
{
	return cast<ABase>(Child);
}
/** @end */
/**
 * @begin cast-downcast
 * @summary Explicit downcast from a base handle.
 * @topic Casting
 *
 * cast-downcast                // this case
 *   cast-downcast-null-guard
 */
class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

/**
 * @function CastDowncast
 * @summary Explicit downcast from a base handle.
 * @covers cast<Derived>
 * @inputs an ABase@ that is actually ADerived
 * @return the same object as ADerived@, or null
 */
ADerived@ CastDowncast(ABase@ Parent)
{
	return cast<ADerived>(Parent);
}
/** @end */
/**
 * @begin cast-downcast-null-guard
 * @parent cast-downcast
 * @summary Same downcast, then reject a null result.
 * @topic Casting
 *
 * cast-downcast
 *   cast-downcast-null-guard   // this case; @range null-guard is the diff
 */
class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

/**
 * @function CastDowncast
 * @summary Same downcast, then reject a null result.
 * @covers cast<Derived> plus null guard
 * @inputs an ABase@ that is actually ADerived
 * @return the same object as ADerived@, or null
 */
ADerived@ CastDowncast(ABase@ Parent)
{
	ADerived@ Child = /** @point downcast */cast<ADerived>(Parent);
	/** @range-begin null-guard */
	if (Child is null)
	{
		return null;
	}
	/** @range-end null-guard */
	return Child;
}
/** @end */
/**
 * @begin cast-round-trip
 * @summary Upcast then downcast, with a null check.
 * @topic Casting
 */
class ABase
{
	int Id;
}

class ADerived : ABase
{
	int Extra;
}

/**
 * @function CastRoundTrip
 * @summary Upcast then downcast, with a null check.
 * @covers upcast then downcast
 * @inputs a live ADerived@
 * @return the same object after Base@ and back, or null
 */
ADerived@ CastRoundTrip(ADerived@ Child)
{
	ABase@ Parent = Child;
	ADerived@ Again = cast<ADerived>(Parent);
	if (Again is null)
	{
		return null;
	}
	return Again;
}
/** @end */
