// Purpose: Observe EncompassesPoint with and without OutDistanceToPoint.
// Runner owns the Volume fixture and supplies Point plus bExpectInside.
// AS-facing API: bool Volume.EncompassesPoint(const FVector& Point, float32 SphereRadius = 0.f) const;
// bool Volume.EncompassesPoint(const FVector& Point, float32 SphereRadius, float32& OutDistanceToPoint) const;
// Inputs: Runner-owned AVolume, Point, SphereRadius 0 and 50, and an out
// distance seeded by the caller.
// Expected observations: Both overloads match bExpectInside. The distance
// overload writes OutDistanceToPoint. Default SphereRadius 0 is omitable.
// Boundary/ownership: OutDistanceToPoint is a writeback of the distance from
// the volume boundary when the point is outside. SetupOwner=Runner.
// CleanupOwner=Runner. Null Volume throws.

namespace TS_AVolume_Behavior_01
{
	bool Observe_EncompassesPoint_Nominal(AVolume Volume, const FVector& Point, bool bExpectInside, float32& OutDistance)
	{
		if (Volume is null)
		{
			throw("TS_AVolume_Behavior_01 setup: required Volume is null");
		}
		bool bBare = Volume.EncompassesPoint(Point);
		bool bRadius = Volume.EncompassesPoint(Point, 50.0);
		float32 Distance = -1.0;
		bool bWithDistance = Volume.EncompassesPoint(Point, 0.0, Distance);
		OutDistance = Distance;
		if (bExpectInside)
		{
			return bBare && bRadius && bWithDistance;
		}
		return !bBare && !bRadius && !bWithDistance && Distance >= 0.0;
	}
}
