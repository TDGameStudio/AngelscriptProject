// Purpose: Observe FBodyInstance.GetBodySetup on a default body and a
// primitive-component body when one is available.
// Runner owns the expected CDO BodySetup presence. A null Box CDO is setup
// failure. The bool return is the runner-readable oracle.
// AS-facing API: UBodySetup FBodyInstance.GetBodySetup() const;
// Inputs: Default FBodyInstance, UBoxComponent CDO BodyInstance, and
// bExpectBoxSetup for whether that CDO already has collision geometry.
// Expected observations: Default GetBodySetup is null. Box CDO setup matches
// bExpectBoxSetup.
// Boundary/ownership: The returned UBodySetup is borrowed. Null means no
// collision geometry asset is attached.

namespace TS_FBodyInstance_Queries_01
{
	bool Observe_GetBodySetup_Nominal(bool bExpectBoxSetup)
	{
		FBodyInstance Body;
		UBodySetup DefaultSetup = Body.GetBodySetup();
		UBoxComponent BoxCdo = TSubclassOf<UBoxComponent>(UBoxComponent::StaticClass()).GetDefaultObject();
		if (BoxCdo is null)
		{
			throw("TS_FBodyInstance_Queries_01 setup: required BoxCdo is null");
		}
		UBodySetup BoxSetup = BoxCdo.BodyInstance.GetBodySetup();
		if (bExpectBoxSetup)
		{
			return DefaultSetup is null && BoxSetup != nullptr;
		}
		return DefaultSetup is null && BoxSetup is null;
	}
}
