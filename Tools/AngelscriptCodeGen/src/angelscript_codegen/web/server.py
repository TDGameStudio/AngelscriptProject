from __future__ import annotations

import threading
import webbrowser
from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field

from angelscript_codegen.generation.valid import ValidProgramGenerator
from angelscript_codegen.lifting.angelscript import lift_case
from angelscript_codegen.profiles.loader import built_in_profile_directory, load_profile
from angelscript_codegen.web.scenarios import ScenarioNotFoundError, get_scenario, list_scenarios


STATIC_DIRECTORY = Path(__file__).with_name("static")


class ScenarioResponse(BaseModel):
    id: str
    profile_id: str
    title_zh: str
    description_zh: str
    max_depth: int
    max_statements: int


class PreviewRequest(BaseModel):
    scenario_id: str
    seed: int = Field(ge=0, lt=2**64)
    max_depth: int = Field(ge=1)
    max_statements: int = Field(ge=1)


class PreviewResponse(BaseModel):
    case_id: str
    profile: str
    expected: str
    harness: str
    verification: str
    source: str


def create_app() -> FastAPI:
    app = FastAPI(title="AngelScript CodeGen 预览", docs_url=None, redoc_url=None)
    app.mount("/assets", StaticFiles(directory=STATIC_DIRECTORY), name="assets")

    @app.get("/", include_in_schema=False)
    def preview_page() -> FileResponse:
        return FileResponse(STATIC_DIRECTORY / "index.html")

    @app.get("/api/scenarios", response_model=list[ScenarioResponse])
    def get_scenarios() -> list[ScenarioResponse]:
        return [ScenarioResponse(**scenario.__dict__) for scenario in list_scenarios()]

    @app.post("/api/preview", response_model=PreviewResponse)
    def preview_source(request: PreviewRequest) -> PreviewResponse:
        try:
            scenario = get_scenario(request.scenario_id)
        except ScenarioNotFoundError as error:
            raise HTTPException(status_code=404, detail=f"未知案例：{request.scenario_id}") from error

        if request.max_depth > scenario.max_depth:
            raise HTTPException(
                status_code=422,
                detail=f"max_depth 不能超过案例限制 {scenario.max_depth}。",
            )
        if request.max_statements > scenario.max_statements:
            raise HTTPException(
                status_code=422,
                detail=f"max_statements 不能超过案例限制 {scenario.max_statements}。",
            )

        profile = load_profile(scenario.profile_id, built_in_profile_directory())
        case = ValidProgramGenerator(
            profile,
            seed=request.seed,
            max_depth=request.max_depth,
            max_statements=request.max_statements,
        ).generate(ordinal=0)
        return PreviewResponse(
            case_id=case.case_id,
            profile=case.profile,
            expected=case.expected,
            harness=case.harness,
            verification=case.verification,
            source=lift_case(case),
        )

    return app


def run_preview_server(*, port: int, open_browser: bool) -> int:
    import uvicorn

    address = f"http://127.0.0.1:{port}/"
    if open_browser:
        threading.Timer(0.25, webbrowser.open, args=(address,)).start()
    uvicorn.run(create_app(), host="127.0.0.1", port=port)
    return 0
