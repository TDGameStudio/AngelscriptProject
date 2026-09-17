/**
 * @version v1
 * @summary Observe ECollisionShape enumerators that identify the primitive kind.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe ECollisionShape enumerators that identify the primitive kind.
 * @topic Baseline
 */
// Line. Sphere and Capsule are distinct from Box.
// Boundary/ownership: Enumerators are shared constants. Script does not own
// the collision-shape kind table.

namespace TS_FCollisionShape_ConstructionAndAssignment_01
{
	// ECollisionShape Line/Box/Sphere/Capsule copy and assignment.
	// Oracle: copy equals Line, assignment to Box differs, Sphere and Capsule are distinct.
	bool Observe_Surface001_Nominal()
	{
		ECollisionShape Line = ECollisionShape::Line;
		ECollisionShape Box = ECollisionShape::Box;
		ECollisionShape Sphere = ECollisionShape::Sphere;
		ECollisionShape Capsule = ECollisionShape::Capsule;
		ECollisionShape Copied = Line;
		bool bCopyEqualsLine = Copied == Line;
		Copied = Box;
		return bCopyEqualsLine && Copied == Box && Line != Box && Sphere != Box && Capsule != Sphere && Capsule != Line;
	}
}
/** @end */
