--[[
	vulpy-rig-kit | Plugin Entry Point

	Plugin completo para criacao e ajuste de rigs de avatar no Roblox Studio.
	Created by VampireSonata.

	Funcionalidades:
	  1. Alinhar rigs sobre pedestais automaticamente
	  2. Criar rigs a partir de userId/username
	  3. Buscar e aplicar itens do catalogo Roblox (painel visual com grid)
	  4. Temas (Default / Vampire) e idiomas (EN / PT-BR) configuraveis
]]

local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local AlignService = require(script.modules.AlignService)
local RigCreatorService = require(script.modules.RigCreatorService)
local Locale = require(script.modules.Locale)
local UIHelpers = require(script.modules.UIHelpers)
local UI = require(script.modules.UI)

-- ════════════════════════════════════════════════════════════════
-- Carregar idioma e tema salvos ANTES de criar widget
-- ════════════════════════════════════════════════════════════════
local savedLang = plugin:GetSetting("VulpyRigKit_Language") or "en"
local savedTheme = plugin:GetSetting("VulpyRigKit_Theme") or "default"

Locale.setLanguage(savedLang)
UIHelpers.applyTheme(savedTheme)

-- ════════════════════════════════════════════════════════════════
-- Estado do plugin
-- ════════════════════════════════════════════════════════════════
local rigs: { Model } = {}
local pedestais: { Model | BasePart } = {}
local OFFSET_STEP = 0.5

-- ════════════════════════════════════════════════════════════════
-- Helpers
-- ════════════════════════════════════════════════════════════════
local statusLabel: TextLabel? = nil

local function setStatus(msg: string)
	if statusLabel then
		statusLabel.Text = msg
	end
end

local function getRigSelecionado(): Model?
	local selected = Selection:Get()
	for _, obj in selected do
		if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
			return obj
		end
	end
	return nil
end

local function onItemSelected(item: any)
	local rig = getRigSelecionado()
	if not rig then
		setStatus(Locale.get("selectRigFirst"))
		return
	end

	local ShopService = require(script.modules.ShopService)

	setStatus(Locale.fmt("applying", item.name or "item"))

	task.spawn(function()
		local recording = ChangeHistoryService:TryBeginRecording("AplicarItem")
		local ok = ShopService.aplicarItem(rig, item.id)
		if recording then
			ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		end

		if ok then
			setStatus(Locale.fmt("appliedSuccess", item.name or "Item", rig.Name))
		else
			setStatus(Locale.get("applyFailed"))
		end
	end)
end

local function onLimparRig()
	local rig = getRigSelecionado()
	if not rig then
		setStatus(Locale.get("selectRigFirst"))
		return
	end

	local ShopService = require(script.modules.ShopService)

	local recording = ChangeHistoryService:TryBeginRecording("LimparRig")
	local removed = ShopService.limparRig(rig)
	if recording then
		ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
	end

	setStatus(Locale.fmt("itemsRemoved", removed, rig.Name))
end

-- ════════════════════════════════════════════════════════════════
-- Toolbar e botao
-- ════════════════════════════════════════════════════════════════
local toolbar = plugin:CreateToolbar("Vampire Rigs")
local toggleButton = toolbar:CreateButton(
	"Vampire Rigs",
	"Vampire Rigs - by VampireSonata",
	"rbxassetid://84002289501048"
)

-- ════════════════════════════════════════════════════════════════
-- Conectar handlers nos elementos do widget
-- ════════════════════════════════════════════════════════════════
local elements: any = nil
local connections: { RBXScriptConnection } = {}

local function limparConnections()
	for _, conn in connections do
		conn:Disconnect()
	end
	connections = {}
end

local function getOffsetFromInputs(): Vector3
	return Vector3.new(
		tonumber(elements.offsetX.Text) or 0,
		tonumber(elements.offsetY.Text) or 0,
		tonumber(elements.offsetZ.Text) or 0
	)
end

local function executarAlinhamento()
	if #rigs == 0 then
		setStatus(Locale.get("defineRigsFirst"))
		return
	end
	if #pedestais == 0 then
		setStatus(Locale.get("definePedestalsFirst"))
		return
	end

	local recording = ChangeHistoryService:TryBeginRecording("AlinharRigs")

	local offset = getOffsetFromInputs()
	local sucessos, total = AlignService.alinharTodos(rigs, pedestais, offset)

	if recording then
		ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
	end

	local msg = Locale.fmt("alignedResult", sucessos, total)
	if #rigs ~= #pedestais then
		msg ..= Locale.fmt("alignedWarning", #rigs, #pedestais)
	end
	setStatus(msg)
end

local function conectarBotoesOffset(textBox: TextBox, minusBtn: TextButton, plusBtn: TextButton)
	table.insert(connections, minusBtn.MouseButton1Click:Connect(function()
		local val = tonumber(textBox.Text) or 0
		textBox.Text = string.format("%.1f", val - OFFSET_STEP)
	end))

	table.insert(connections, plusBtn.MouseButton1Click:Connect(function()
		local val = tonumber(textBox.Text) or 0
		textBox.Text = string.format("%.1f", val + OFFSET_STEP)
	end))
end

local function conectarHandlers()
	limparConnections()

	statusLabel = elements.statusLabel

	-- Definir Rigs
	table.insert(connections, elements.setRigsButton.MouseButton1Click:Connect(function()
		local selected = Selection:Get()
		local models: { Model } = {}
		for _, obj in selected do
			if obj:IsA("Model") then
				table.insert(models, obj)
			end
		end
		if #models == 0 then
			setStatus(Locale.get("noModelSelected"))
			return
		end
		rigs = models
		elements.rigsCountLabel.Text = Locale.fmt("rigsCount", #rigs)
		setStatus(Locale.fmt("rigsCaptured", #rigs))
	end))

	-- Limpar Rigs
	table.insert(connections, elements.clearRigsButton.MouseButton1Click:Connect(function()
		rigs = {}
		elements.rigsCountLabel.Text = Locale.get("noRigsDefined")
		setStatus(Locale.get("rigsCleared"))
	end))

	-- Definir Pedestais
	table.insert(connections, elements.setPedestaisButton.MouseButton1Click:Connect(function()
		local selected = Selection:Get()
		local items: { Model | BasePart } = {}
		for _, obj in selected do
			if obj:IsA("Model") or obj:IsA("BasePart") then
				table.insert(items, obj)
			end
		end
		if #items == 0 then
			setStatus(Locale.get("noPartSelected"))
			return
		end
		pedestais = items
		elements.pedestaisCountLabel.Text = Locale.fmt("pedestalsCount", #items)
		setStatus(Locale.fmt("pedestalsCaptured", #items))
	end))

	-- Limpar Pedestais
	table.insert(connections, elements.clearPedestaisButton.MouseButton1Click:Connect(function()
		pedestais = {}
		elements.pedestaisCountLabel.Text = Locale.get("noPedestalsDefined")
		setStatus(Locale.get("pedestalsCleared"))
	end))

	-- Alinhar
	table.insert(connections, elements.alignButton.MouseButton1Click:Connect(executarAlinhamento))
	table.insert(connections, elements.applyOffsetButton.MouseButton1Click:Connect(executarAlinhamento))

	-- Botoes +/- de offset
	conectarBotoesOffset(elements.offsetX, elements.offsetXMinus, elements.offsetXPlus)
	conectarBotoesOffset(elements.offsetY, elements.offsetYMinus, elements.offsetYPlus)
	conectarBotoesOffset(elements.offsetZ, elements.offsetZMinus, elements.offsetZPlus)

	-- Rig Creator
	table.insert(connections, elements.createRigButton.MouseButton1Click:Connect(function()
		local input = elements.rigCreatorInput.Text
		if input == "" then
			setStatus(Locale.get("typeUsernameOrId"))
			return
		end

		local rigName = elements.rigNameInput.Text
		setStatus(Locale.get("creatingRig"))

		task.spawn(function()
			local model, err = RigCreatorService.criarRig(input, rigName, workspace)
			if model then
				Selection:Set({ model })
				setStatus(Locale.get("rigCreated") .. model.Name)
			else
				setStatus(Locale.get("rigError") .. (err or "unknown"))
			end
		end)
	end))
end

-- ════════════════════════════════════════════════════════════════
-- Callback de mudanca de configuracoes (idioma/tema)
-- ════════════════════════════════════════════════════════════════
local function onSettingsChanged(lang: string, theme: string)
	-- Salva
	plugin:SetSetting("VulpyRigKit_Language", lang)
	plugin:SetSetting("VulpyRigKit_Theme", theme)

	-- Aplica
	Locale.setLanguage(lang)
	UIHelpers.applyTheme(theme)

	-- Rebuild widget e reconecta handlers
	elements.rebuild()
	conectarHandlers()

	setStatus(Locale.get("settingsSaved"))
end

-- ════════════════════════════════════════════════════════════════
-- Widget UI
-- ════════════════════════════════════════════════════════════════
elements = UI.criarWidget(plugin, {
	onItemSelected = onItemSelected,
	setStatus = setStatus,
	getRigSelecionado = getRigSelecionado,
	onLimparRig = onLimparRig,
	onSettingsChanged = onSettingsChanged,
})

local widget = elements.widget
conectarHandlers()

toggleButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
	toggleButton:SetActive(widget.Enabled)
end)

widget:GetPropertyChangedSignal("Enabled"):Connect(function()
	toggleButton:SetActive(widget.Enabled)
end)

-- ════════════════════════════════════════════════════════════════
-- Cleanup ao descarregar o plugin
-- ════════════════════════════════════════════════════════════════
plugin.Unloading:Connect(function()
	rigs = {}
	pedestais = {}
	limparConnections()
	if elements.shopPanel then
		elements.shopPanel.destroy()
	end
end)

print("[Vampire Rigs] Plugin loaded! Created by VampireSonata")
