// Purpose: Observe process rendering capability and the current Unreal
// project name from FApp. The bool return is the runner-readable oracle.
// AS-facing API: bool FApp::CanEverRender(); FString FApp::GetProjectName();
// Inputs: Runner-supplied bExpectCanRender for this process, plus two
// GetProjectName reads with no extra keys.
// Expected observations: CanEverRender matches bExpectCanRender. GetProjectName
// is stable across two reads and non-empty for a named Unreal project.
// Boundary/ownership: These helpers report process state. GetProjectName
// returns a new FString and does not own engine identity.

namespace TS_FApp_Queries_01
{
	bool Observe_CanEverRender_Nominal(bool bExpectCanRender)
	{
		return FApp::CanEverRender() == bExpectCanRender;
	}

	bool Observe_GetProjectName_Nominal()
	{
		FString First = FApp::GetProjectName();
		FString Second = FApp::GetProjectName();
		return First == Second && First.Len() > 0;
	}
}
