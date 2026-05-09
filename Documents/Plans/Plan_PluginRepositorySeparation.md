# 插件仓库拆分与独立发布计划

## 背景与目标

当前 `AngelscriptProject` 同时承担三类职责：作为 UE 宿主工程验证 `Plugins/Angelscript`，保存插件开发历史、计划文档和本地工具链，并临时承载未来对外发布的插件、GAS 扩展和 Wiki 文档站。这个形态适合快速研发，但不适合作为 GitHub 上的最终消费入口：使用者真正需要 clone 的是插件本体，而不是包含宿主工程、Reference、Agent 文档和本地验证脚本的完整工程仓库。

本计划的目标是记录未来仓库拆分方案：保留 `AngelscriptProject` 作为开发与验证宿主工程，把核心插件、GAS 扩展和 Wiki 文档站拆成独立 GitHub 仓库，并由宿主工程通过 submodule 聚合。拆分时不迁移历史提交，不做 `git filter-repo` 或 `subtree split`；新仓库从当时确认的目录快照初始化，历史上下文继续留在 `AngelscriptProject` 中。

## 范围与边界

- **范围内**
  - 规划 `Plugins/Angelscript` 未来独立为 `Angelscript` 仓库。
  - 规划 `Plugins/AngelscriptGAS` 未来独立为 `AngelscriptGAS` 仓库。
  - 规划 `Wiki` 未来独立为 `AngelscriptWiki` 仓库。
  - 规划 `AngelscriptProject` 未来通过 submodule 聚合这些独立仓库。
  - 明确快照导入、测试模块跟随发布、文档站发布和后续验收规则。
- **范围外**
  - 当前不创建 GitHub 仓库。
  - 当前不移动 `Plugins/Angelscript`、`Plugins/AngelscriptGAS` 或 `Wiki`。
  - 当前不把任何目录改成 submodule。
  - 当前不修改 `.uplugin`、README、AGENTS 或插件源码。
  - 当前不清理工作树中既有未提交改动。

## 当前事实状态快照

1. `Plugins/Angelscript/` 是核心插件目录，已有 `Angelscript.uplugin`、插件级 `.gitignore`、`LICENSE.md` 和 `AGENTS.md`，包含 `AngelscriptRuntime`、`AngelscriptEditor`、`AngelscriptTest`、`AngelscriptUHTTool`。
2. `Plugins/Angelscript/Angelscript.uplugin` 当前把 `AngelscriptTest` 作为 Editor 模块列入插件；用户已确认 `AngelscriptTest` 可以跟随核心插件共同发布。
3. `Plugins/AngelscriptGAS/` 当前是可选 GAS 扩展插件，`AngelscriptGAS.uplugin` 已声明依赖 `Angelscript` 和 `GameplayAbilities`，包含 `AngelscriptGAS` 与 `AngelscriptGASTest`。
4. `Wiki/` 当前是本地 MkDocs Material 文档站工作区，包含 `mkdocs.yml`、`docs/`、`requirements.txt`、`README.md`，并已被根 `.gitignore` 排除。
5. `AngelscriptProject` 当前远端和历史仍作为完整开发上下文保存；新插件仓库不要求保留目录级历史。
6. 当前工作树存在大量既有修改和未跟踪文件；实际执行拆分前必须先冻结要导入新仓库的快照状态。

## 目标仓库结构

### `AngelscriptProject`

`AngelscriptProject` 继续作为开发、验证和路线图宿主工程。未来目标结构：

```text
AngelscriptProject/
├── Plugins/
│   ├── Angelscript/        # git submodule -> Angelscript
│   └── AngelscriptGAS/     # git submodule -> AngelscriptGAS
├── Wiki/                   # git submodule -> AngelscriptWiki，或保持 ignored local clone
├── AngelscriptProject.uproject
├── Config/
├── Source/AngelscriptProject/
├── Script/
├── Tools/
├── Documents/
└── Reference/
```

默认建议 `Wiki` 也作为 submodule 进入宿主工程，便于一键拉齐文档；如果后续希望 Wiki 只作为本地预览工作区，也可以继续保持 ignored local clone。

### `Angelscript`

核心插件仓库根目录就是 UE 插件目录：

```text
Angelscript/
├── Angelscript.uplugin
├── Source/
│   ├── AngelscriptRuntime/
│   ├── AngelscriptEditor/
│   ├── AngelscriptTest/
│   └── AngelscriptUHTTool/
├── AGENTS.md
├── LICENSE.md
├── README.md
└── .gitignore
```

`AngelscriptTest` 跟随核心插件一起发布。它是源码插件的验证模块，不需要在第一阶段从公开仓库中裁剪。

### `AngelscriptGAS`

GAS 扩展插件仓库根目录就是 UE 插件目录：

```text
AngelscriptGAS/
├── AngelscriptGAS.uplugin
├── Config/
├── Source/
│   ├── AngelscriptGAS/
│   └── AngelscriptGASTest/
├── README.md
└── .gitignore
```

`AngelscriptGAS` 是独立仓库，但不是完全独立能力；它依赖 `Angelscript`，并要求用户工程同时安装核心插件。

### `AngelscriptWiki`

Wiki 仓库作为普通 GitHub 仓库和 MkDocs 文档站源码，而不是 GitHub 内置 `.wiki.git`：

```text
AngelscriptWiki/
├── mkdocs.yml
├── docs/
├── requirements.txt
├── README.md
└── .gitignore
```

文档站后续通过 GitHub Pages 发布，`Angelscript.uplugin` 的 `DocsURL` 应指向该站点。

## 关键决策

1. **不迁移历史提交**
   - 新仓库使用快照导入，首个提交可命名为 `Initial import from AngelscriptProject`。
   - 插件演进历史、计划文档和早期上下文继续在 `AngelscriptProject` 中查询。

2. **核心插件和 GAS 扩展分别作为子仓库**
   - `Angelscript` 是基础仓库，承载语言运行时、编辑器集成、测试模块和 UHT 工具链。
   - `AngelscriptGAS` 是依赖核心插件的可选扩展仓库，承载 GAS 基类、绑定、工具库和专项测试。

3. **测试模块跟随各自插件仓库发布**
   - `AngelscriptTest` 跟随 `Angelscript`。
   - `AngelscriptGASTest` 跟随 `AngelscriptGAS`。
   - 宿主工程只负责运行和组合测试，不再拥有插件内部测试源码的主仓职责。

4. **Wiki 使用独立 MkDocs 仓库**
   - `Wiki` 内容进入 `AngelscriptWiki` 普通仓库。
   - 不使用 GitHub 内置 Wiki 作为主文档源，因为当前文档站依赖 MkDocs Material、导航配置、双语目录和构建流程。

5. **宿主工程使用 submodule 聚合**
   - `Plugins/Angelscript` 指向 `Angelscript`。
   - `Plugins/AngelscriptGAS` 指向 `AngelscriptGAS`。
   - `Wiki` 默认指向 `AngelscriptWiki`，除非后续决定继续作为 ignored local clone。

## 影响范围

本计划未来执行时涉及以下操作（按需组合）：

- **快照导入**：把当前确认状态下的目录内容复制到新仓库根目录，并提交为初始快照。
- **生成物清理**：从新仓库中排除 `Binaries/`、`Intermediate/`、`Source/*/obj/`、`site/`、日志、缓存等生成物。
- **子模块替换**：在宿主工程中将原目录替换为指向新仓库的 git submodule。
- **入口文档补齐**：为三个新仓库补齐 README、安装说明、依赖说明和维护说明。
- **元数据回填**：在后续执行阶段把 `.uplugin` 的 `DocsURL`、`SupportURL` 等字段指向正式仓库和文档站。
- **索引同步**：更新 `AngelscriptProject` 的 README、AGENTS、计划索引和相关指南，使后续贡献者知道源码边界已移动到子仓库。

### 未来受影响文件与目录

`AngelscriptProject`（宿主工程）：
- `Plugins/Angelscript/` — 替换为 `Angelscript` submodule。
- `Plugins/AngelscriptGAS/` — 替换为 `AngelscriptGAS` submodule。
- `Wiki/` — 替换为 `AngelscriptWiki` submodule，或继续作为 ignored local clone。
- `README.md` — 更新宿主工程定位与 submodule 拉取说明。
- `AGENTS.md` / `AGENTS_ZH.md` — 更新开发边界、提交边界和子仓库工作规则。
- `Documents/Plans/Plan_OpportunityIndex.md` — 纳入本计划状态。
- `Documents/Plans/Plan_StatusPriorityRoadmap.md` — 需要时同步独立发布路线状态。

`Angelscript` 新仓库：
- `Angelscript.uplugin` — 未来补齐仓库 URL、DocsURL、SupportURL 等公开元数据。
- `README.md` — 新增核心插件安装、依赖、测试模块和许可说明。
- `.gitignore` — 保留并补齐插件仓库生成物忽略规则。

`AngelscriptGAS` 新仓库：
- `AngelscriptGAS.uplugin` — 未来补齐公开元数据。
- `README.md` — 新增核心插件依赖、GameplayAbilities 依赖和安装路径说明。
- `.gitignore` — 新增插件仓库生成物忽略规则。

`AngelscriptWiki` 新仓库：
- `mkdocs.yml` — 保留文档站配置，后续调整 `site_url`。
- `docs/` — 保留双语文档源。
- `README.md` — 更新为独立文档站仓库说明。
- `.gitignore` — 忽略 `site/`、日志、虚拟环境和缓存。

## 分阶段执行计划

### Phase 0：冻结快照和仓库命名

> 目标：在真正移动任何目录前，先确定导入快照、远端命名和执行边界，避免把当前脏工作树中的临时状态误发布。

- [ ] **P0.1** 确认三个目标 GitHub 仓库的 owner 与名称
  - 默认候选为 `TDGameStudio/Angelscript`、`TDGameStudio/AngelscriptGAS`、`TDGameStudio/AngelscriptWiki`；如果最终使用 `UnrealEngine-Angelscript-ZH` 组织，只替换远端 URL，不改变仓库结构。
  - 这一步只锁定命名，不创建仓库、不推送代码。
- [ ] **P0.1** 📦 Git 提交：`[Docs/Repository] Docs: record plugin repository naming decision`

- [ ] **P0.2** 冻结要导入新仓库的目录快照
  - 在执行拆分前检查 `Plugins/Angelscript`、`Plugins/AngelscriptGAS` 和 `Wiki` 的未提交状态，确认哪些改动属于首次公开快照。
  - 若存在临时生成物、实验文件或未完成迁移，先在原宿主工程中处理清楚，再执行快照导入。
- [ ] **P0.2** 📦 Git 提交：`[Docs/Repository] Chore: freeze repository separation import snapshot`

### Phase 1：初始化 `Angelscript` 核心插件仓库

> 目标：把 `Plugins/Angelscript` 作为独立插件仓库发布入口，保留测试模块和 UHT 工具链。

- [ ] **P1.1** 使用当前确认快照初始化 `Angelscript` 仓库
  - 将 `Plugins/Angelscript/` 内容作为新仓库根目录导入。
  - 保留 `Source/AngelscriptRuntime`、`Source/AngelscriptEditor`、`Source/AngelscriptTest`、`Source/AngelscriptUHTTool`、`Angelscript.uplugin`、`LICENSE.md`、`AGENTS.md` 和 `.gitignore`。
  - 排除 `Binaries/`、`Intermediate/`、`Source/*/obj/`、缓存文件和本地 IDE 文件。
- [ ] **P1.1** 📦 Git 提交：`[Repository] Chore: import Angelscript plugin snapshot`

- [ ] **P1.2** 补齐核心插件仓库入口文档
  - 新增或重写 `README.md`，明确安装路径为 `Project/Plugins/Angelscript`。
  - 说明 UE 版本、依赖插件、模块结构、`AngelscriptTest` 的用途、构建测试入口和许可证。
  - 文档应避免引用宿主工程本地绝对路径，必要路径通过相对路径或 `AgentConfig.ini` 说明。
- [ ] **P1.2** 📦 Git 提交：`[Repository] Docs: add Angelscript plugin repository README`

### Phase 2：初始化 `AngelscriptGAS` 扩展插件仓库

> 目标：把 GAS 能力从宿主工程中独立为可选扩展插件仓库，保持对核心插件的显式依赖。

- [ ] **P2.1** 使用当前确认快照初始化 `AngelscriptGAS` 仓库
  - 将 `Plugins/AngelscriptGAS/` 内容作为新仓库根目录导入。
  - 保留 `Config/`、`Source/AngelscriptGAS`、`Source/AngelscriptGASTest` 和 `AngelscriptGAS.uplugin`。
  - 排除 `Binaries/`、`Intermediate/`、缓存文件和本地 IDE 文件。
- [ ] **P2.1** 📦 Git 提交：`[Repository] Chore: import AngelscriptGAS plugin snapshot`

- [ ] **P2.2** 补齐 GAS 插件仓库入口文档
  - 新增 `README.md` 和 `.gitignore`。
  - README 明确 `AngelscriptGAS` 依赖 `Angelscript`，安装时两个插件目录都必须位于 `Project/Plugins/`。
  - 说明 `GameplayAbilities`、`GameplayTasks`、`GameplayTags` 等 UE 插件依赖，以及 `AngelscriptGASTest` 的用途。
- [ ] **P2.2** 📦 Git 提交：`[Repository] Docs: add AngelscriptGAS repository README`

### Phase 3：初始化 `AngelscriptWiki` 文档站仓库

> 目标：把当前 MkDocs 文档站从本地 ignored 工作区变成可发布、可协作的独立文档源。

- [ ] **P3.1** 使用当前确认快照初始化 `AngelscriptWiki` 仓库
  - 将 `Wiki/` 内容作为新仓库根目录导入。
  - 保留 `mkdocs.yml`、`docs/`、`requirements.txt` 和 `README.md`。
  - 排除 `site/`、`mkdocs-serve*.log`、虚拟环境和缓存目录。
- [ ] **P3.1** 📦 Git 提交：`[Repository] Chore: import Angelscript wiki snapshot`

- [ ] **P3.2** 配置 Wiki 仓库的发布入口
  - 添加 `.gitignore`，明确文档站生成物和本地环境不入库。
  - 添加 GitHub Pages workflow 或等效发布流程，使用 `python -m mkdocs build --strict` 作为文档构建验证。
  - 更新 `site_url` 为最终 Pages URL。
- [ ] **P3.2** 📦 Git 提交：`[Docs/Wiki] Feat: add MkDocs Pages publishing flow`

### Phase 4：将宿主工程切换为 submodule 聚合

> 目标：让 `AngelscriptProject` 回到宿主职责，通过子仓库组合插件源码和文档站。

- [ ] **P4.1** 将核心插件目录替换为 `Angelscript` submodule
  - 在确认 `Angelscript` 仓库已推送并可 clone 后，将 `Plugins/Angelscript` 替换为 submodule。
  - 保持路径仍为 `Plugins/Angelscript`，避免 `.uproject` 和 UE 插件发现路径变化。
  - 替换前必须确认宿主工程中没有尚未导入核心插件仓库的本地改动。
- [ ] **P4.1** 📦 Git 提交：`[Repository] Chore: use Angelscript plugin submodule`

- [ ] **P4.2** 将 GAS 插件目录替换为 `AngelscriptGAS` submodule
  - 在确认 `AngelscriptGAS` 仓库已推送并可 clone 后，将 `Plugins/AngelscriptGAS` 替换为 submodule。
  - 保持路径仍为 `Plugins/AngelscriptGAS`，让 `AngelscriptGAS.uplugin` 的依赖关系继续按 UE 插件规则解析。
- [ ] **P4.2** 📦 Git 提交：`[Repository] Chore: use AngelscriptGAS plugin submodule`

- [ ] **P4.3** 决定并处理 `Wiki` 在宿主工程中的形态
  - 默认方案是将 `Wiki` 替换为 `AngelscriptWiki` submodule，便于宿主工程完整拉取文档。
  - 如果后续决定继续把 `Wiki` 当本地 ignored clone，则必须在 README 和 AGENTS 中说明文档仓库的独立拉取方式。
- [ ] **P4.3** 📦 Git 提交：`[Repository] Chore: document wiki repository linkage`

### Phase 5：同步元数据、文档和验证入口

> 目标：拆分完成后，消除“源码已经移动但文档仍指向旧结构”的割裂状态。

- [ ] **P5.1** 更新插件公开元数据
  - 在 `Angelscript` 仓库更新 `Angelscript.uplugin` 的 `DocsURL`、`SupportURL`，分别指向 `AngelscriptWiki` Pages 和核心插件 GitHub Issues。
  - 在 `AngelscriptGAS` 仓库更新 `AngelscriptGAS.uplugin` 的对应公开字段。
  - `MarketplaceURL` 如未上架 Marketplace，不伪造 URL；保持为空或在文档中解释延后策略。
- [ ] **P5.1** 📦 Git 提交：`[Repository] Chore: update plugin repository support metadata`

- [ ] **P5.2** 更新宿主工程文档和 Agent 规则
  - 更新 `AngelscriptProject` 根 README，说明它现在是开发宿主，不是插件源码主仓。
  - 更新 `AGENTS.md` / `AGENTS_ZH.md`，明确插件源码、GAS 扩展、Wiki 分别在对应 submodule 仓库提交。
  - 更新构建测试说明，补充 `git submodule update --init --recursive` 作为首次准备步骤。
- [ ] **P5.2** 📦 Git 提交：`[Docs/Repository] Docs: describe submodule-based plugin development flow`

- [ ] **P5.3** 同步计划索引和状态路线图
  - 将本计划加入 `Plan_OpportunityIndex.md` 的工具链 / 交付类计划中。
  - 必要时在 `Plan_StatusPriorityRoadmap.md` 中补充“独立仓库发布基线”状态。
  - 本计划完成后按 `Documents/Plans/Plan.md` 规则归档，并同步 `Documents/Plans/Archives/README.md`。
- [ ] **P5.3** 📦 Git 提交：`[Docs/Roadmap] Chore: sync repository separation plan status`

## 验收标准

1. `Angelscript`、`AngelscriptGAS`、`AngelscriptWiki` 三个独立仓库均已创建，并包含从当前确认快照导入的首个提交。
2. `Angelscript` 仓库保留 `AngelscriptTest`，且可作为 `Project/Plugins/Angelscript` 被 UE 工程识别。
3. `AngelscriptGAS` 仓库保留 `AngelscriptGASTest`，且 README 明确依赖 `Angelscript` 与 GAS 相关 UE 插件。
4. `AngelscriptWiki` 仓库可执行 `python -m mkdocs build --strict`，并能通过 GitHub Pages 或等效流程发布。
5. `AngelscriptProject` 中 `Plugins/Angelscript` 和 `Plugins/AngelscriptGAS` 已由 submodule 管理，路径保持不变。
6. 首次拉取宿主工程后，执行 `git submodule update --init --recursive` 能完整恢复插件和文档目录。
7. 宿主工程仍可通过标准入口构建：
   `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label submodule-build -TimeoutMs 180000`
8. 核心 smoke 测试仍可通过标准入口运行：
   `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -Group AngelscriptSmoke -Label submodule-smoke -TimeoutMs 600000`
9. 根 README、AGENTS、AGENTS_ZH 和计划索引均已同步新仓库边界。
10. 历史提交仍留在 `AngelscriptProject`，新仓库不要求目录级历史或 blame 连续性。

## 风险与注意事项

### 风险

1. **快照状态不干净**
   - 当前工作树存在大量既有修改和未跟踪文件，如果直接导入，可能把临时文件、实验内容或未验证改动发布到新仓库。
   - **缓解**：执行拆分前必须先冻结快照，逐项确认导入内容；生成物和本地文件按 `.gitignore` 排除。

2. **submodule 增加协作复杂度**
   - 使用者和贡献者需要理解更新子模块指针、在子仓库提交、再回宿主工程更新引用的流程。
   - **缓解**：README、AGENTS 和贡献指南必须写清楚 `git submodule update --init --recursive`、子仓库提交边界和宿主工程指针更新规则。

3. **核心插件与 GAS 版本不匹配**
   - `AngelscriptGAS` 依赖 `Angelscript`，两个仓库分开后可能出现不兼容组合。
   - **缓解**：在 `AngelscriptGAS` README 中记录兼容的 `Angelscript` tag / commit，宿主工程 submodule 指针作为已验证组合来源。

4. **Wiki 与插件元数据不同步**
   - 文档仓库独立后，`.uplugin` 的 `DocsURL`、README 链接和 Pages 地址可能不同步。
   - **缓解**：将 URL 回填纳入 Phase 5 验收，文档站发布后再更新插件元数据。

5. **历史查询入口变化**
   - 新仓库不保留旧历史，单独查看新仓库 blame 时只能看到导入后的演进。
   - **缓解**：README 明确新仓库为快照导入，历史上下文在 `AngelscriptProject` 中保留。

### 已知行为变化

1. **宿主工程不再直接拥有插件源码主仓职责**
   - 插件源码主提交位置变为 `Angelscript` 和 `AngelscriptGAS` 子仓库；宿主工程只更新 submodule 指针和验证组合。

2. **`Plugins/AngelscriptGAS` 从宿主目录变为可选扩展仓库**
   - GAS 能力仍可在宿主工程中开发和测试，但发布节奏与核心插件分离。

3. **Wiki 从 ignored 本地工作区变为独立文档源**
   - 文档站源码进入 `AngelscriptWiki`，宿主工程中的 `Wiki` 只作为 submodule 或本地 clone 使用。

4. **新仓库历史从导入点开始**
   - 这是有意选择，不是遗漏；完整早期历史继续保存在 `AngelscriptProject`。
