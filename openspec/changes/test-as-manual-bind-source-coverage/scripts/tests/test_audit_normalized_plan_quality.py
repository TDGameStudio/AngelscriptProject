from __future__ import annotations

import sys
from pathlib import Path
import unittest


SCRIPTS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS))

from AuditNormalizedPlanQuality import audit_file_rows, audit_row  # noqa: E402
from NormalizeExhaustiveContractV2Plan import inject_quality_blockers  # noqa: E402


def make_row(**overrides):
    row = {
        "taskId": "W01.B01.F0001.C0001",
        "sourcePath": "TestSource/Language/Sample.as",
        "sourceOnly": False,
        "proposal": {
            "semanticName": "ReadValue",
            "disposition": "hard-rename",
            "requiredNameReason": None,
            "declaration": "int ReadValue(int Input)",
            "parameters": [
                {
                    "declaration": "int Input",
                    "name": "Input",
                    "asType": "int",
                    "direction": "value",
                    "default": None,
                    "valueSource": "contract vector",
                }
            ],
            "returnType": "int",
            "writebacks": [],
            "bodyPlan": ["Return the supplied value without comparing it to an expected literal."],
            "prohibitedCalls": [],
        },
        "comment": {
            "exactText": "// Return the supplied raw integer so the runner owns the comparison."
        },
        "vectors": [
            {
                "vectorId": "sample/nominal",
                "arguments": {"Input": {"asType": "int", "value": 7}},
                "expected": {"return": {"asType": "int", "value": 7}},
            }
        ],
        "fixture": {
            "executionMode": "Runtime",
            "invocationDriver": "typed contract runner",
        },
        "coverage": {"cppEvidence": [], "highRiskDirectives": []},
        "status": {"design": "review-ready"},
        "blockers": [],
    }
    for key, value in overrides.items():
        row[key] = value
    return row


class AuditNormalizedPlanQualityTests(unittest.TestCase):
    def test_accepts_raw_value_contract_with_structured_input_vector(self):
        self.assertEqual([], audit_row(make_row()))

    def test_rejects_comparison_derived_observed_condition_writebacks(self):
        row = make_row()
        row["proposal"] = {
            **row["proposal"],
            "semanticName": "AddFileRepeatCall",
            "declaration": "void AddFileRepeatCall(bool&out FirstObservedCondition, bool&out SecondObservedCondition)",
            "parameters": [],
            "returnType": "void",
            "writebacks": [
                {"name": "FirstObservedCondition", "direction": "out", "type": "bool&out"},
                {"name": "SecondObservedCondition", "direction": "out", "type": "bool&out"},
            ],
            "bodyPlan": [
                "FirstObservedCondition <- Entry() == 9; SecondObservedCondition <- Entry() == 9."
            ],
        }
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("derived-condition-output", codes)

    def test_allows_a_raw_boolean_api_result(self):
        row = make_row()
        row["proposal"] = {
            **row["proposal"],
            "semanticName": "IsArrayEmpty",
            "declaration": "bool IsArrayEmpty(const TArray<int>&in Values)",
            "parameters": [
                {
                    "declaration": "const TArray<int>&in Values",
                    "name": "Values",
                    "asType": "const TArray<int>&in",
                    "direction": "in",
                    "default": None,
                    "valueSource": "contract vector",
                }
            ],
            "returnType": "bool",
            "writebacks": [],
            "bodyPlan": ["Return Values.IsEmpty() directly; the runner compares the raw API result."],
        }
        row["vectors"][0]["arguments"] = {
            "Values": {"asType": "TArray<int>", "elements": []}
        }
        self.assertNotIn(
            "derived-condition-output", {finding["code"] for finding in audit_row(row)}
        )

    def test_rejects_generic_surface_owned_comment(self):
        row = make_row()
        row["comment"]["exactText"] = (
            "// ReadValue is the function surface owned by ::; inputs: int Input; returns raw int."
        )
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("generic-purpose-comment", codes)

    def test_rejects_covers_and_role_only_comment_templates(self):
        for exact_text in (
            "// Purpose: ReadValue covers the integer behavior surface.",
            "// Role: semantic operation/reader. Boundary and expected values live in typed vectors.",
        ):
            with self.subTest(exact_text=exact_text):
                row = make_row()
                row["comment"]["exactText"] = exact_text
                codes = {finding["code"] for finding in audit_row(row)}
                self.assertIn("generic-purpose-comment", codes)

    def test_rejects_required_name_without_protocol_reason(self):
        row = make_row()
        row["proposal"]["disposition"] = "required-name"
        row["proposal"]["requiredNameReason"] = None
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("required-name-reason-missing", codes)

    def test_rejects_ordinal_placeholder_semantic_names(self):
        for name in (
            "ReadFixtureForSubcase003",
            "CompileParamsNegative03",
            "Handler1",
            "ServerAction2",
            "LambdaAtLine38",
        ):
            with self.subTest(name=name):
                row = make_row()
                row["proposal"]["semanticName"] = name
                codes = {finding["code"] for finding in audit_row(row)}
                self.assertIn("semantic-name-ordinal-placeholder", codes)

    def test_rejects_uppercase_b_boolean_output_prefix(self):
        row = make_row()
        row["proposal"] = {
            **row["proposal"],
            "declaration": "void ReadState(bool&out BRepNotifyExecuted)",
            "parameters": [],
            "returnType": "void",
            "writebacks": [
                {
                    "name": "BRepNotifyExecuted",
                    "direction": "out",
                    "type": "bool",
                }
            ],
        }
        row["vectors"] = [
            {
                "vectorId": "state",
                "arguments": {},
                "expected": {
                    "rawExpectations": [
                        {
                            "name": "BRepNotifyExecuted",
                            "type": "bool",
                            "relation": "==",
                            "value": False,
                        }
                    ]
                },
            }
        ]
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("boolean-prefix-style", codes)

    def test_rejects_runtime_signature_with_duplicate_parameter_names(self):
        row = make_row()
        row["proposal"]["declaration"] = (
            "void BrightenColor(FLinearColor&inout c, float amount, FLinearColor&inout c)"
        )
        row["proposal"]["returnType"] = "void"
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("duplicate-runtime-parameter-name", codes)

    def test_allows_duplicate_parameter_names_for_exact_compile_negative(self):
        row = make_row()
        row["proposal"]["declaration"] = (
            "UFUNCTION()\nvoid RejectDuplicateNames(int X, float X)"
        )
        row["proposal"]["returnType"] = "void"
        row["fixture"]["executionMode"] = "CompileOnly"
        row["vectors"] = [
            {
                "vectorId": "compile-negative",
                "arguments": {},
                "expected": {
                    "expectedCompileDiagnostic": {
                        "matcherKind": "exact",
                        "text": "Parameter name 'X' is duplicated",
                    }
                },
            }
        ]
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertNotIn("duplicate-runtime-parameter-name", codes)

    def test_rejects_declaration_return_type_mismatch(self):
        row = make_row()
        row["proposal"]["declaration"] = "bool ReadValue()"
        row["proposal"]["parameters"] = []
        row["proposal"]["returnType"] = "void"
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("declaration-return-type-mismatch", codes)

    def test_rejects_review_ready_input_contract_with_text_only_vector(self):
        row = make_row()
        row["vectors"][0]["arguments"] = {}
        row["vectors"][0]["expected"] = {"evidence": "Input=7 -> return 7"}
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("unstructured-input-vector", codes)

    def test_rejects_inout_parameter_without_writeback_channel(self):
        row = make_row()
        row["proposal"]["declaration"] = "void Increment(int&inout Value)"
        row["proposal"]["parameters"] = [
            {
                "declaration": "int&inout Value",
                "name": "Value",
                "asType": "int&inout",
                "direction": "inout",
                "default": None,
                "valueSource": "contract vector",
            }
        ]
        row["proposal"]["returnType"] = "void"
        row["proposal"]["writebacks"] = []
        row["vectors"][0]["arguments"] = {"Value": {"asType": "int", "value": 1}}
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("writeback-channel-missing", codes)

    def test_rejects_success_vector_without_each_writeback_oracle(self):
        row = make_row()
        row["proposal"] = {
            **row["proposal"],
            "declaration": "void ReadState(int&out Count)",
            "parameters": [],
            "returnType": "void",
            "writebacks": [
                {"name": "Count", "direction": "out", "type": "int"}
            ],
        }
        row["vectors"] = [
            {"vectorId": "success", "arguments": {}, "expected": {"rawExpectations": []}}
        ]
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("success-writeback-oracle-missing", codes)

    def test_rejects_failure_vector_without_mutable_post_state(self):
        row = make_row()
        row["proposal"] = {
            **row["proposal"],
            "declaration": "void Mutate(int&inout Value)",
            "parameters": [
                {
                    "declaration": "int&inout Value",
                    "name": "Value",
                    "asType": "int&inout",
                    "direction": "inout",
                    "default": None,
                    "valueSource": "contract vector",
                }
            ],
            "returnType": "void",
            "writebacks": [
                {"name": "Value", "direction": "inout", "type": "int"}
            ],
        }
        row["vectors"] = [
            {
                "vectorId": "runtime-exception",
                "arguments": {"Value": {"exactType": "int", "typedLiteral": "7"}},
                "expected": {"expectedException": {"message": "failure"}},
                "postFailureState": [],
            }
        ]
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("failure-post-state-missing", codes)

    def test_rejects_null_oracle_placeholders(self):
        row = make_row()
        row["vectors"][0]["expected"] = {"expectedReturn": None}
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("null-oracle-placeholder", codes)

    def test_rejects_nominal_and_default_pseudo_typed_literals(self):
        for literal in ("nominal(FVector)", "default(FTransform)"):
            with self.subTest(literal=literal):
                row = make_row()
                row["vectors"][0]["arguments"]["Input"] = {
                    "exactType": "int",
                    "typedLiteral": literal,
                }
                codes = {finding["code"] for finding in audit_row(row)}
                self.assertIn("pseudo-typed-literal", codes)

    def test_requires_explicit_and_omitted_default_parameter_vectors(self):
        row = make_row()
        row["proposal"]["declaration"] = "int ReadValue(int Input = 7)"
        row["proposal"]["parameters"][0]["default"] = "7"
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("default-argument-branch-missing", codes)

    def test_flags_preprocessor_metadata_case_without_external_source_contract(self):
        row = make_row()
        row["sourcePath"] = "TestSource/Definitions/Meta/Test_AddFile.as"
        row["coverage"]["cppEvidence"] = [
            "AngelscriptVirtualScriptPathPreprocessorTests.cpp::AddFileEmitsGameVirtualPathMetadata"
        ]
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("external-oracle-classification-required", codes)

    def test_normalizer_projects_quality_findings_as_execution_blockers(self):
        row = make_row()
        row["comment"]["exactText"] = (
            "// ReadValue is the function surface owned by ::; returns raw int."
        )
        row["proposal"]["disposition"] = "required-name"
        row["proposal"]["requiredNameReason"] = None

        inject_quality_blockers([row])

        codes = {blocker["code"] for blocker in row["blockers"]}
        self.assertIn("comment-unresolved", codes)
        self.assertIn("signature-unresolved", codes)

    def test_rejects_diagnostic_only_mode_without_a_diagnostic_vector(self):
        row = make_row()
        row["fixture"]["executionMode"] = "DiagnosticOnly"
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("diagnostic-only-runtime-contract", codes)

    def test_rejects_diagnostic_only_mode_mixed_with_runtime_success_oracle(self):
        row = make_row()
        row["fixture"]["executionMode"] = "DiagnosticOnly"
        row["vectors"].append(
            {
                "vectorId": "negative",
                "arguments": {"Input": {"exactType": "int", "typedLiteral": "0"}},
                "expected": {
                    "expectedDiagnostic": {
                        "exactMessage": "Input must be non-zero",
                        "count": 1,
                    }
                },
            }
        )
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("diagnostic-only-mixed-runtime-contract", codes)

    def test_rejects_generic_high_risk_engine_driver_and_vector_phase(self):
        row = make_row()
        row["coverage"]["highRiskDirectives"] = [
            "High map — timers require real TimerManager phases"
        ]
        row["fixture"]["invocationDriver"] = (
            "runner/engine/native/reflection according to vector phase"
        )
        row["vectors"][0]["phase"] = "invoke"
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("high-risk-driver-generic", codes)
        self.assertIn("high-risk-phase-matrix-missing", codes)

    def test_rejects_default_component_handle_without_identity_oracle(self):
        row = make_row()
        row["sourcePath"] = "TestSource/World/Component/Test_BoxComponent.as"
        row["coverage"]["highRiskDirectives"] = [
            "High map — DefaultComponent null false positives"
        ]
        row["proposal"]["declaration"] = "UBoxComponent GetBoxComponent(AActor Actor)"
        row["proposal"]["returnType"] = "UBoxComponent"
        row["vectors"][0]["expected"] = {
            "rawReturn": {"exactType": "UBoxComponent", "relation": "non-null"}
        }
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("component-identity-oracle-missing", codes)

    def test_rejects_debugger_row_without_dap_semantic_oracle(self):
        row = make_row()
        row["sourcePath"] = "TestSource/Debugger/Test_Block_01.as"
        row["fixture"]["invocationDriver"] = "debugger evaluation request"
        row["vectors"][0]["expected"] = {"rawExpectations": []}
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("debugger-semantic-oracle-missing", codes)

    def test_rejects_nonvoid_contract_without_raw_return_oracle(self):
        row = make_row()
        row["vectors"][0]["expected"] = {"rawExpectations": []}
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("raw-return-oracle-missing", codes)

    def test_rejects_negated_or_comparison_writeback_as_raw_state(self):
        row = make_row()
        row["proposal"] = {
            **row["proposal"],
            "declaration": "void ReadState(bool&out NotCreated)",
            "parameters": [],
            "returnType": "void",
            "writebacks": [
                {
                    "name": "NotCreated",
                    "direction": "out",
                    "type": "bool",
                    "rawExpression": "!Actor.NewObjectCreated",
                    "typeEvidence": "raw-boolean-expression",
                }
            ],
        }
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("derived-condition-output", codes)

    def test_rejects_known_new_object_false_state_as_post_begin_play_oracle(self):
        row = make_row()
        row["coverage"]["highRiskDirectives"] = [
            "High map — NewObject identity, Outer, name, class, and flags"
        ]
        row["vectors"][0]["expected"] = {
            "rawExpectations": [
                {"name": "NotActorNewObjectCreated", "type": "bool", "value": "true"}
            ]
        }
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("known-lifecycle-oracle-contradiction", codes)

    def test_rejects_direct_callback_name_when_direct_dispatch_is_prohibited(self):
        row = make_row()
        row["proposal"]["semanticName"] = "InvokeDirectCallback"
        row["proposal"]["declaration"] = "void InvokeDirectCallback()"
        row["proposal"]["parameters"] = []
        row["proposal"]["prohibitedCalls"] = ["direct-call:OnTimer"]
        codes = {finding["code"] for finding in audit_row(row)}
        self.assertIn("direct-dispatch-contract-contradiction", codes)

    def test_file_audit_requires_reader_for_engine_dispatched_actor_callbacks(self):
        begin_play = make_row()
        begin_play["sourcePath"] = "TestSource/World/Actor/Test_ActorCollisionEvents.as"
        begin_play["proposal"] = {
            **begin_play["proposal"],
            "semanticName": "BeginPlay",
            "disposition": "required-name",
            "requiredNameReason": "Unreal lifecycle dispatch.",
            "declaration": "UFUNCTION(BlueprintOverride)\nvoid BeginPlay()",
            "parameters": [],
            "returnType": "void",
            "writebacks": [],
        }
        callback = make_row()
        callback["sourcePath"] = begin_play["sourcePath"]
        callback["proposal"] = {
            **callback["proposal"],
            "semanticName": "OnActorHitEvent",
            "disposition": "required-name",
            "requiredNameReason": "FName delegate binding.",
            "declaration": "UFUNCTION()\nvoid OnActorHitEvent(AActor SelfActor, AActor OtherActor)",
            "returnType": "void",
            "writebacks": [],
        }
        codes = {item[1]["code"] for item in audit_file_rows([begin_play, callback])}
        self.assertIn("post-dispatch-reader-missing", codes)

    def test_file_audit_requires_blueprint_instance_state_reader(self):
        begin_play = make_row()
        begin_play["sourcePath"] = "TestSource/World/Blueprint/Test_RecreateDoesNotLeakState.as"
        begin_play["fixture"]["instanceKind"] = (
            "runner-owned script class/CDO/Blueprint child class/CDO/spawned instance matrix"
        )
        begin_play["proposal"] = {
            **begin_play["proposal"],
            "semanticName": "BeginPlay",
            "disposition": "required-name",
            "requiredNameReason": "Unreal lifecycle dispatch.",
            "declaration": "UFUNCTION(BlueprintOverride)\nvoid BeginPlay()",
            "parameters": [],
            "returnType": "void",
            "writebacks": [],
        }
        bump = make_row()
        bump["sourcePath"] = begin_play["sourcePath"]
        bump["fixture"] = dict(begin_play["fixture"])
        bump["proposal"] = {
            **bump["proposal"],
            "semanticName": "BumpState",
            "declaration": "UFUNCTION()\nvoid BumpState()",
            "parameters": [],
            "returnType": "void",
            "writebacks": [],
        }
        codes = {item[1]["code"] for item in audit_file_rows([begin_play, bump])}
        self.assertIn("blueprint-state-reader-missing", codes)

    def test_file_audit_requires_explicit_retirement_transfer_links(self):
        row = make_row()
        row["proposal"] = {
            **row["proposal"],
            "declaration": None,
            "returnType": None,
            "disposition": "retire-with-replacement",
        }
        codes = {item[1]["code"] for item in audit_file_rows([row])}
        self.assertIn("retirement-transfer-link-missing", codes)

    def test_file_audit_requires_exact_process_event_driver(self):
        row = make_row()
        row["sourcePath"] = "TestSource/Feature/Inheritance/Test_ProcessEvent.as"
        row["coverage"]["highRiskDirectives"] = ["ProcessEvent native dispatch"]
        row["fixture"]["invocationDriver"] = "typed contract runner"
        codes = {item[1]["code"] for item in audit_file_rows([row])}
        self.assertIn("process-event-driver-missing", codes)

    def test_file_audit_requires_timer_or_delegate_state_reader(self):
        callback = make_row()
        callback["sourcePath"] = "TestSource/Gameplay/Timer/Test_TimerBasicUsage.as"
        callback["coverage"]["highRiskDirectives"] = [
            "High map — timers require real TimerManager phases"
        ]
        callback["proposal"] = {
            **callback["proposal"],
            "semanticName": "TimerCallback",
            "declaration": "UFUNCTION()\nvoid TimerCallback()",
            "parameters": [],
            "returnType": "void",
            "writebacks": [],
        }
        codes = {item[1]["code"] for item in audit_file_rows([callback])}
        self.assertIn("post-dispatch-reader-missing", codes)

    def test_file_audit_requires_gc_cross_invocation_host_phases(self):
        begin_play = make_row()
        begin_play["sourcePath"] = (
            "TestSource/Language/Syntax/EdgeCases/Test_GCBasicReclaim.as"
        )
        begin_play["proposal"] = {
            **begin_play["proposal"],
            "semanticName": "BeginPlay",
            "declaration": "UFUNCTION(BlueprintOverride)\nvoid BeginPlay()",
            "parameters": [],
            "returnType": "void",
            "writebacks": [],
            "bodyPlan": ["Preserve the current body and execution phase."],
        }
        codes = {item[1]["code"] for item in audit_file_rows([begin_play])}
        self.assertIn("gc-host-phase-contract-missing", codes)

    def test_normalizer_projects_file_relationship_findings(self):
        row = make_row()
        row["proposal"] = {
            **row["proposal"],
            "declaration": None,
            "returnType": None,
            "disposition": "retire-with-replacement",
        }

        inject_quality_blockers([row])

        codes = {blocker["code"] for blocker in row["blockers"]}
        self.assertIn("coverage-unresolved", codes)


if __name__ == "__main__":
    unittest.main()
