--[[
	vulpy-rig-kit | EquippedPanel
	Mostra todos os itens equipados no rig selecionado.
	Preview 3D + lista de itens com botao de remover individual.
]]

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

local UIHelpers = require(script.Parent.Parent.UIHelpers)
local RigPreview = require(script.Parent.RigPreview)

local COLORS = UIHelpers.COLORS

local EquippedPanel = {}

-- Tipos de item que escaneamos no rig
local ITEM_TYPES = {
	{ class = "Accessory", label = "Acessorio", icon = "" },
	{ class = "Shirt", label = "Camisa", icon = "" },
	{ class = "Pants", label = "Calca", icon = "" },
	{ class = "ShirtGraphic", label = "Camiseta", icon = "" },
}

function EquippedPanel.create(parent: GuiObject, callbacks: {
	setStatus: (string) -> (),
	getRigSelecionado: () -> Model?,
})
	-- Container principal
	local container = Instance.new("ScrollingFrame")
	container.Name = "EquippedPanel"
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.ScrollBarThickness = 4
	container.ScrollBarImageColor3 = COLORS.separator
	container.CanvasSize = UDim2.new(0, 0, 0, 0)
	container.AutomaticCanvasSize = Enum.AutomaticSize.Y
	container.Parent = parent

	local mainLayout = Instance.new("UIListLayout")
	mainLayout.Padding = UDim.new(0, 6)
	mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
	mainLayout.Parent = container

	local mainPad = Instance.new("UIPadding")
	mainPad.PaddingTop = UDim.new(0, 10)
	mainPad.PaddingBottom = UDim.new(0, 10)
	mainPad.PaddingLeft = UDim.new(0, 12)
	mainPad.PaddingRight = UDim.new(0, 12)
	mainPad.Parent = container

	-- Titulo
	UIHelpers.criarLabel(container, {
		text = "Itens Equipados",
		size = UDim2.new(1, 0, 0, 20),
		bold = true,
		textSize = 15,
	}).LayoutOrder = 0

	local infoLabel = UIHelpers.criarLabel(container, {
		text = "Selecione um rig no workspace",
		size = UDim2.new(1, 0, 0, 14),
		color = COLORS.textDim,
		textSize = 11,
	})
	infoLabel.LayoutOrder = 1

	-- ═══════════════════════════════════════════════════
	-- Preview 3D
	-- ═══════════════════════════════════════════════════
	local preview = RigPreview.create(container, {
		height = 180,
		layoutOrder = 2,
	})

	UIHelpers.criarSeparador(container).LayoutOrder = 3

	-- ═══════════════════════════════════════════════════
	-- Contador de itens
	-- ═══════════════════════════════════════════════════
	local countLabel = UIHelpers.criarLabel(container, {
		text = "0 itens equipados",
		size = UDim2.new(1, 0, 0, 14),
		color = COLORS.textDim,
		textSize = 11,
		bold = true,
	})
	countLabel.LayoutOrder = 4

	-- ═══════════════════════════════════════════════════
	-- Lista de itens equipados
	-- ═══════════════════════════════════════════════════
	local itemListFrame = Instance.new("Frame")
	itemListFrame.Name = "ItemList"
	itemListFrame.Size = UDim2.new(1, 0, 0, 0)
	itemListFrame.AutomaticSize = Enum.AutomaticSize.Y
	itemListFrame.BackgroundTransparency = 1
	itemListFrame.LayoutOrder = 5
	itemListFrame.Parent = container

	local itemListLayout = Instance.new("UIListLayout")
	itemListLayout.Padding = UDim.new(0, 4)
	itemListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	itemListLayout.Parent = itemListFrame

	-- Label quando nao tem nada
	local emptyLabel = UIHelpers.criarLabel(container, {
		text = "Nenhum item equipado",
		size = UDim2.new(1, 0, 0, 30),
		color = COLORS.textDim,
		textSize = 12,
	})
	emptyLabel.LayoutOrder = 6
	emptyLabel.TextXAlignment = Enum.TextXAlignment.Center

	UIHelpers.criarSeparador(container).LayoutOrder = 7

	-- ═══════════════════════════════════════════════════
	-- Botao Remover Tudo
	-- ═══════════════════════════════════════════════════
	local removeAllBtn = UIHelpers.criarBotao(container, {
		text = "Remover Tudo",
		size = UDim2.new(1, 0, 0, 32),
		color = COLORS.red,
	})
	removeAllBtn.Font = Enum.Font.GothamBold
	removeAllBtn.TextSize = 13
	removeAllBtn.LayoutOrder = 8

	-- ═══════════════════════════════════════════════════
	-- Estado
	-- ═══════════════════════════════════════════════════
	local itemRows: { Instance } = {}

	local function clearItemRows()
		for _, row in itemRows do
			row:Destroy()
		end
		itemRows = {}
	end

	-- Cria uma row para um item equipado
	local function createItemRow(item: Instance, itemType: string, order: number)
		local row = Instance.new("Frame")
		row.Name = "Item_" .. item.Name
		row.Size = UDim2.new(1, 0, 0, 40)
		row.BackgroundColor3 = COLORS.surface
		row.LayoutOrder = order
		row.Parent = itemListFrame

		UIHelpers.criarCorner(row, 6)

		-- Thumbnail (tenta pegar asset ID para thumbnail)
		local thumb = Instance.new("ImageLabel")
		thumb.Name = "Thumb"
		thumb.Size = UDim2.new(0, 36, 0, 36)
		thumb.Position = UDim2.new(0, 2, 0, 2)
		thumb.BackgroundColor3 = COLORS.cardBg
		thumb.ScaleType = Enum.ScaleType.Fit
		thumb.Parent = row
		UIHelpers.criarCorner(thumb, 4)

		-- Tenta extrair asset ID para thumbnail
		-- Prioriza o atributo VulpyAssetId (salvo quando aplicamos da loja)
		local vulpyId = nil
		pcall(function()
			vulpyId = item:GetAttribute("VulpyAssetId")
		end)

		if vulpyId then
			thumb.Image = "rbxthumb://type=Asset&id=" .. tostring(vulpyId) .. "&w=150&h=150"
		elseif item:IsA("Shirt") then
			local templateId = tostring(item.ShirtTemplate):match("(%d+)")
			if templateId then
				thumb.Image = "rbxthumb://type=Asset&id=" .. templateId .. "&w=150&h=150"
			end
		elseif item:IsA("Pants") then
			local templateId = tostring(item.PantsTemplate):match("(%d+)")
			if templateId then
				thumb.Image = "rbxthumb://type=Asset&id=" .. templateId .. "&w=150&h=150"
			end
		elseif item:IsA("ShirtGraphic") then
			local graphicId = tostring(item.Graphic):match("(%d+)")
			if graphicId then
				thumb.Image = "rbxthumb://type=Asset&id=" .. graphicId .. "&w=150&h=150"
			end
		elseif item:IsA("Accessory") then
			local handle = item:FindFirstChild("Handle")
			if handle then
				local mesh = handle:FindFirstChildOfClass("SpecialMesh")
				if mesh and mesh.TextureId ~= "" then
					local texId = mesh.TextureId:match("(%d+)")
					if texId then
						thumb.Image = "rbxthumb://type=Asset&id=" .. texId .. "&w=150&h=150"
					end
				end
			end
		elseif item:IsA("Decal") then
			local texId = tostring(item.Texture):match("(%d+)")
			if texId then
				thumb.Image = "rbxthumb://type=Asset&id=" .. texId .. "&w=150&h=150"
			end
		end

		-- Nome do item
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "ItemName"
		nameLabel.Size = UDim2.new(1, -82, 0, 22)
		nameLabel.Position = UDim2.new(0, 42, 0, 2)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = item.Name
		nameLabel.TextColor3 = COLORS.text
		nameLabel.TextSize = 11
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
		nameLabel.Parent = row

		-- Tipo
		local typeLabel = Instance.new("TextLabel")
		typeLabel.Size = UDim2.new(1, -82, 0, 14)
		typeLabel.Position = UDim2.new(0, 42, 0, 24)
		typeLabel.BackgroundTransparency = 1
		typeLabel.Text = itemType
		typeLabel.TextColor3 = COLORS.textDim
		typeLabel.TextSize = 9
		typeLabel.Font = Enum.Font.GothamMedium
		typeLabel.TextXAlignment = Enum.TextXAlignment.Left
		typeLabel.Parent = row

		-- Botao remover (X)
		local removeBtn = Instance.new("TextButton")
		removeBtn.Name = "Remove"
		removeBtn.Size = UDim2.new(0, 32, 0, 32)
		removeBtn.Position = UDim2.new(1, -36, 0, 4)
		removeBtn.BackgroundColor3 = COLORS.red
		removeBtn.Text = "X"
		removeBtn.TextColor3 = Color3.new(1, 1, 1)
		removeBtn.TextSize = 12
		removeBtn.Font = Enum.Font.GothamBold
		removeBtn.AutoButtonColor = true
		removeBtn.Parent = row
		UIHelpers.criarCorner(removeBtn, 6)

		removeBtn.MouseButton1Click:Connect(function()
			local itemName = item.Name
			local recording = ChangeHistoryService:TryBeginRecording("RemoverItem")
			if not recording then return end
			item:Destroy()
			ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
			callbacks.setStatus("'" .. itemName .. "' removido!")
			task.defer(function()
				local api = EquippedPanel._currentApi
				if api then api.refresh() end
			end)
		end)

		table.insert(itemRows, row)
	end

	-- Scan do rig e populacao da lista
	local function scanRig(rig: Model)
		clearItemRows()

		if not rig then
			infoLabel.Text = "Selecione um rig no workspace"
			countLabel.Text = "0 itens equipados"
			emptyLabel.Visible = true
			removeAllBtn.Visible = false
			return
		end

		infoLabel.Text = "Rig: " .. rig.Name

		local count = 0

		-- Acessorios
		for _, child in rig:GetChildren() do
			if child:IsA("Accessory") then
				count += 1
				local accType = "Acessorio"
				pcall(function()
					accType = tostring(child.AccessoryType)
				end)
				createItemRow(child, accType, count)
			end
		end

		-- Shirt
		local shirt = rig:FindFirstChildOfClass("Shirt")
		if shirt then
			count += 1
			createItemRow(shirt, "Camisa", count)
		end

		-- Pants
		local pants = rig:FindFirstChildOfClass("Pants")
		if pants then
			count += 1
			createItemRow(pants, "Calca", count)
		end

		-- ShirtGraphic (T-Shirt)
		local tshirt = rig:FindFirstChildOfClass("ShirtGraphic")
		if tshirt then
			count += 1
			createItemRow(tshirt, "Camiseta", count)
		end

		-- Face (Decal no Head)
		local head = rig:FindFirstChild("Head")
		if head then
			for _, child in head:GetChildren() do
				if child:IsA("Decal") and (child.Name == "face" or child.Name == "Face") then
					count += 1
					createItemRow(child, "Rosto", count)
					break
				end
			end
		end

		countLabel.Text = tostring(count) .. " iten(s) equipado(s)"
		emptyLabel.Visible = count == 0
		removeAllBtn.Visible = count > 0
	end

	-- ═══════════════════════════════════════════════════
	-- Remover tudo
	-- ═══════════════════════════════════════════════════
	removeAllBtn.MouseButton1Click:Connect(function()
		local rig = callbacks.getRigSelecionado()
		if not rig then return end

		local recording = ChangeHistoryService:TryBeginRecording("RemoverTudo")
		if not recording then return end

		local removed = 0

		for _, child in rig:GetChildren() do
			if child:IsA("Accessory") then
				child:Destroy()
				removed += 1
			end
		end

		local shirt = rig:FindFirstChildOfClass("Shirt")
		if shirt then shirt:Destroy(); removed += 1 end

		local pants = rig:FindFirstChildOfClass("Pants")
		if pants then pants:Destroy(); removed += 1 end

		local tshirt = rig:FindFirstChildOfClass("ShirtGraphic")
		if tshirt then tshirt:Destroy(); removed += 1 end

		local head = rig:FindFirstChild("Head")
		if head then
			for _, child in head:GetChildren() do
				if child:IsA("Decal") and (child.Name == "face" or child.Name == "Face") then
					child:Destroy()
					removed += 1
					break
				end
			end
		end

		ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		callbacks.setStatus(tostring(removed) .. " iten(s) removido(s)!")

		task.defer(function()
			local api = EquippedPanel._currentApi
			if api then api.refresh() end
		end)
	end)

	-- ═══════════════════════════════════════════════════
	-- API
	-- ═══════════════════════════════════════════════════
	local api = {}

	function api.getContainer()
		return container
	end

	function api.refresh()
		local rig = callbacks.getRigSelecionado()
		preview.setRig(rig)
		scanRig(rig)
	end

	function api.destroy()
		preview.destroy()
		container:Destroy()
	end

	-- Guarda referencia para os callbacks de remocao
	EquippedPanel._currentApi = api

	-- Listener de selecao
	local selectionConn = Selection.SelectionChanged:Connect(function()
		api.refresh()
	end)

	local oldDestroy = api.destroy
	function api.destroy()
		selectionConn:Disconnect()
		oldDestroy()
	end

	return api
end

return EquippedPanel
