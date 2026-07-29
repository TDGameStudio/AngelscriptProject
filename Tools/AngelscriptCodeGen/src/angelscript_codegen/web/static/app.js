const elements = {
  scenarioList: document.querySelector("#scenario-list"),
  form: document.querySelector("#preview-form"),
  seed: document.querySelector("#seed"),
  randomSeed: document.querySelector("#random-seed"),
  maxDepth: document.querySelector("#max-depth"),
  maxStatements: document.querySelector("#max-statements"),
  generate: document.querySelector("#generate-preview"),
  error: document.querySelector("#preview-error"),
  source: document.querySelector("#source-preview"),
  copySource: document.querySelector("#copy-source"),
  copyStatus: document.querySelector("#copy-status"),
  metadata: {
    profile: document.querySelector("#metadata-profile"),
    expected: document.querySelector("#metadata-expected"),
    harness: document.querySelector("#metadata-harness"),
    verification: document.querySelector("#metadata-verification"),
  },
};

const state = { scenarios: [], selectedScenario: null };

function setError(message = "") {
  elements.error.textContent = message;
  elements.error.hidden = !message;
}

function applyScenario(scenario) {
  state.selectedScenario = scenario;
  elements.maxDepth.value = scenario.max_depth;
  elements.maxDepth.max = scenario.max_depth;
  elements.maxStatements.value = scenario.max_statements;
  elements.maxStatements.max = scenario.max_statements;
  for (const input of elements.scenarioList.querySelectorAll("input")) {
    input.checked = input.value === scenario.id;
  }
  setError();
}

function renderScenarios() {
  const fragment = document.createDocumentFragment();
  for (const scenario of state.scenarios) {
    const input = document.createElement("input");
    input.type = "radio";
    input.name = "scenario_id";
    input.id = `scenario-${scenario.id}`;
    input.value = scenario.id;
    input.addEventListener("change", () => applyScenario(scenario));

    const label = document.createElement("label");
    label.className = "scenario-card";
    label.htmlFor = input.id;

    const profile = document.createElement("span");
    profile.className = "scenario-card__profile";
    profile.textContent = scenario.profile_id;
    const title = document.createElement("strong");
    title.textContent = scenario.title_zh;
    const description = document.createElement("span");
    description.className = "scenario-card__description";
    description.textContent = scenario.description_zh;
    label.append(profile, title, description);
    fragment.append(input, label);
  }
  elements.scenarioList.replaceChildren(fragment);
}

function createRandomSeed() {
  const words = new Uint32Array(2);
  crypto.getRandomValues(words);
  return ((BigInt(words[0]) << 32n) | BigInt(words[1])).toString();
}

function setMetadata(preview) {
  elements.metadata.profile.textContent = preview.profile;
  elements.metadata.expected.textContent = preview.expected;
  elements.metadata.harness.textContent = preview.harness;
  elements.metadata.verification.textContent = preview.verification;
}

async function loadScenarios() {
  const response = await fetch("/api/scenarios");
  if (!response.ok) {
    throw new Error("无法加载案例列表。请刷新页面后重试。");
  }
  state.scenarios = await response.json();
  renderScenarios();
  applyScenario(state.scenarios[0]);
}

elements.randomSeed.addEventListener("click", () => {
  elements.seed.value = createRandomSeed();
  setError();
});

elements.form.addEventListener("submit", async (event) => {
  event.preventDefault();
  if (!state.selectedScenario) {
    setError("请先选择一个案例。");
    return;
  }

  const payload = {
    scenario_id: state.selectedScenario.id,
    seed: elements.seed.value.trim(),
    max_depth: Number(elements.maxDepth.value),
    max_statements: Number(elements.maxStatements.value),
  };
  elements.generate.disabled = true;
  elements.generate.textContent = "正在生成…";
  setError();
  elements.copyStatus.textContent = "";

  try {
    const response = await fetch("/api/preview", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });
    const body = await response.json();
    if (!response.ok) {
      throw new Error(body.detail || "生成预览失败。请检查参数后重试。");
    }
    elements.source.textContent = body.source;
    setMetadata(body);
    elements.copySource.disabled = false;
  } catch (error) {
    setError(error instanceof Error ? error.message : "生成预览失败。请检查参数后重试。");
  } finally {
    elements.generate.disabled = false;
    elements.generate.textContent = "生成预览";
  }
});

elements.copySource.addEventListener("click", async () => {
  try {
    await navigator.clipboard.writeText(elements.source.textContent);
    elements.copyStatus.textContent = "源码已复制。";
  } catch {
    elements.copyStatus.textContent = "无法访问剪贴板，请手动复制源码。";
  }
});

loadScenarios().catch((error) => {
  setError(error instanceof Error ? error.message : "无法加载案例列表。请刷新页面后重试。");
});
