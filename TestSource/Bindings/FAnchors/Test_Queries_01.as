// Purpose: Observe stretched-vertical and stretched-horizontal queries.
// The bool return is the runner-readable oracle.
// AS-facing API: bool Anchors.IsStretchedVertical() const;
// bool Anchors.IsStretchedHorizontal() const;
// Inputs: Point anchors (0.5, 0.5) as the empty/unstretched state, range
// (0,0,1,1) as both-axes stretch, and (0,0.5,1,0.5) as horizontal-only.
// Expected observations: Point anchors are not stretched. Full range is
// stretched on both axes. Horizontal-only is stretched horizontally and not
// vertically.
// Boundary/ownership: Stretch means min != max on that axis. Queries do not
// mutate the anchors.

namespace TS_FAnchors_Queries_01
{
	bool Observe_IsStretchedVertical_Nominal()
	{
		FAnchors Point(0.5, 0.5);
		FAnchors Full(0.0, 0.0, 1.0, 1.0);
		FAnchors HorizontalOnly(0.0, 0.5, 1.0, 0.5);
		return !Point.IsStretchedVertical() && Full.IsStretchedVertical() && !HorizontalOnly.IsStretchedVertical();
	}

	bool Observe_IsStretchedHorizontal_Nominal()
	{
		FAnchors Point(0.5, 0.5);
		FAnchors Full(0.0, 0.0, 1.0, 1.0);
		FAnchors HorizontalOnly(0.0, 0.5, 1.0, 0.5);
		return !Point.IsStretchedHorizontal() && Full.IsStretchedHorizontal() && HorizontalOnly.IsStretchedHorizontal();
	}
}
