/**
 * Isolated compile-fail: a virtual property get/set block on Health. C++
 * VirtualPropertyFails AssertFailsWithError "Virtual property syntax has been removed".
 *
 * @Theme Feature.PropertyAccess
 * @Subject PropertyAccess.VirtualPropertyFails
 * @Harness CompileReject
 * @Tag Feature.PropertyAccess.VirtualPropertyFails
 * @Kind CompileReject
 * @Covers PropertyAccess.VirtualPropertyFails
 * @Inputs int Health { get { return 100; } set { } }
 * @Return does not compile; "Virtual property syntax has been removed"
 * @Provenance Theme: Feature.PropertyAccess. Isolated compile-fail: virtual property get/set block.
 * @Provenance CSV WorldStory. C++ VirtualPropertyFails AssertFailsWithError
 * @Provenance "Virtual property syntax has been removed".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

class AActorPAVirtual : AActor
{
	int Health
	{
		get
		{
			return 100;
		}

		set
		{
		}
	}
}
