/**
 * @version v1
 * @summary Writing a private base member from a derived class is rejected. This file is the illegal program itself; do not make Secret protected, since the derived write is the point.
 * @topic Feature
 */
/**
 * @version root
 * @summary Writing a private base member from a derived class is rejected. This file is the illegal program itself; do not make Secret protected, since the derived write is the point.
 * @topic Negative
 */
/**
 * A base actor whose only member is private.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile once Secret is written from a derived class
 */
class ABaseActorPrivDeriv : AActor
{
	private int Secret = 42;
}

/**
 * A derived actor that tries to write the private base member.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
class ADerivedActorPriv : ABaseActorPrivDeriv
{
	/**
	 * Attempt to assign the private base member.
	 *
	 * @Covers Access.Specifier
	 * @Inputs none
	 * @Return does not compile
	 */
	void Foo()
	{
		Secret = 10;
	}
}
/** @end */
