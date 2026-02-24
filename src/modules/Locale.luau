--[[
	vulpy-rig-kit | Locale
	Sistema de traducao para Ingles e Portugues Brasileiro.
	Usa plugin:GetSetting/SetSetting para persistir a escolha.
]]

local Locale = {}

-- ════════════════════════════════════════════════════════════════
-- Tabelas de traducao
-- ════════════════════════════════════════════════════════════════
local STRINGS = {
	["en"] = {
		-- Geral
		pluginTitle = "Vampire Rigs",
		ready = "Ready.",
		credits = "Created by VampireSonata",

		-- Seletor de idioma
		langTitle = "Choose Language",
		langSubtitle = "Select your preferred language",
		langEnglish = "English",
		langPortuguese = "Portugues BR",
		langConfirm = "Confirm",

		-- Tabs principais
		tabAlign = "Align",
		tabCreator = "Create Rig",
		tabShop = "Shop",

		-- Alinhamento
		rigsTitle = "Rigs",
		noRigsDefined = "No rigs defined",
		setRigs = "Set Rigs (from selection)",
		clearRigs = "Clear Rigs",
		pedestalsTitle = "Pedestals",
		noPedestalsDefined = "No pedestals defined",
		setPedestals = "Set Pedestals (from selection)",
		clearPedestals = "Clear Pedestals",
		alignButton = "Align Rigs on Pedestals",
		offsetTitle = "Offset (fine tuning)",
		applyOffset = "Apply Offset",
		rigsCount = "%d rig(s) defined",
		pedestalsCount = "%d pedestal(s) defined",
		rigsCaptured = "%d rig(s) captured from selection.",
		pedestalsCaptured = "%d pedestal(s) captured from selection.",
		rigsCleared = "Rigs cleared.",
		pedestalsCleared = "Pedestals cleared.",
		noModelSelected = "No Model selected!",
		noPartSelected = "No Model or Part selected!",
		defineRigsFirst = "Define rigs first!",
		definePedestalsFirst = "Define pedestals first!",
		alignedResult = "Aligned %d/%d rigs!",
		alignedWarning = " (warning: %d rigs, %d pedestals)",

		-- Rig Creator
		createRigTitle = "Create Avatar Rig",
		createRigDesc = "Generates a RIG from any player's avatar.\nThe model is anchored and ready for use.",
		usernameOrId = "Username or UserId",
		usernameOrIdPlaceholder = "e.g. Roblox or 1",
		rigNameOptional = "Rig Name (optional)",
		rigNamePlaceholder = "Uses username if empty",
		createRigButton = "Create Rig",
		creatingRig = "Creating rig...",
		rigCreated = "Rig created: ",
		rigError = "Error: ",
		typeUsernameOrId = "Type a username or userId!",

		-- Loja
		searchPlaceholder = "Search or paste ID...",
		searchButton = "Search",
		cleanRigButton = "Clean Selected Rig",
		chooseCategory = "Choose a category or search",
		searching = "Searching...",
		loadingMore = "Loading more...",
		results = "%d result(s)",
		noResults = "No results",
		searchError = "Search error",
		applying = "Applying %s...",
		appliedSuccess = "'%s' applied to %s!",
		applyFailed = "Failed to apply item. Check if the asset exists.",
		itemFound = "Item found: ",
		itemNotFound = "Item not found: ",
		itemsFound = "%d items found",
		noItemFound = "No item found",
		catalogError = "Error searching catalog",
		selectRigFirst = "Select a rig (Model with Humanoid) in workspace!",
		itemsRemoved = "%d item(s) removed from %s",

		-- Categorias
		all = "All",
		clothing = "Clothing",
		shirts = "Shirts",
		pants = "Pants",
		tshirts = "T-Shirts",
		animations = "Animations",
		emotes = "Emotes",

		-- Bundles
		bundleTitle = "Bundle",
		bundleIdPlaceholder = "Bundle ID...",
		bundleLoad = "Load",
		bundleLoading = "Loading bundle...",
		bundleLoaded = "Bundle '%s' - %d item(s)",
		bundleNotFound = "Bundle not found",
		bundleError = "Error loading bundle",
		bundleApplyAll = "Apply All",

		-- Configuracoes
		tabSettings = "Settings",
		settingsTitle = "Settings",
		languageSection = "Language",
		themeSection = "Theme",
		themeDefault = "Default",
		themeVampire = "Vampire",
		themeDefaultDesc = "Dark modern style",
		themeVampireDesc = "Gothic blood red",
		settingsSaved = "Settings saved!",
	},

	["pt-br"] = {
		-- Geral
		pluginTitle = "Vampire Rigs",
		ready = "Pronto.",
		credits = "Criado por VampireSonata",

		-- Seletor de idioma
		langTitle = "Escolha o Idioma",
		langSubtitle = "Selecione seu idioma preferido",
		langEnglish = "English",
		langPortuguese = "Portugues BR",
		langConfirm = "Confirmar",

		-- Tabs principais
		tabAlign = "Alinhar",
		tabCreator = "Criar Rig",
		tabShop = "Loja",

		-- Alinhamento
		rigsTitle = "Rigs",
		noRigsDefined = "Nenhum rig definido",
		setRigs = "Definir Rigs (da selecao)",
		clearRigs = "Limpar Rigs",
		pedestalsTitle = "Pedestais",
		noPedestalsDefined = "Nenhum pedestal definido",
		setPedestals = "Definir Pedestais (da selecao)",
		clearPedestals = "Limpar Pedestais",
		alignButton = "Alinhar Rigs nos Pedestais",
		offsetTitle = "Offset (ajuste fino)",
		applyOffset = "Aplicar Offset",
		rigsCount = "%d rig(s) definido(s)",
		pedestalsCount = "%d pedestal(is) definido(s)",
		rigsCaptured = "%d rig(s) capturado(s) da selecao.",
		pedestalsCaptured = "%d pedestal(is) capturado(s) da selecao.",
		rigsCleared = "Rigs limpos.",
		pedestalsCleared = "Pedestais limpos.",
		noModelSelected = "Nenhum Model selecionado!",
		noPartSelected = "Nenhum Model ou Part selecionado!",
		defineRigsFirst = "Defina os rigs primeiro!",
		definePedestalsFirst = "Defina os pedestais primeiro!",
		alignedResult = "Alinhados %d/%d rigs!",
		alignedWarning = " (aviso: %d rigs, %d pedestais)",

		-- Rig Creator
		createRigTitle = "Criar Rig de Avatar",
		createRigDesc = "Gera um RIG a partir do avatar de qualquer jogador.\nO model fica ancorado e pronto pra uso no mapa.",
		usernameOrId = "Username ou UserId",
		usernameOrIdPlaceholder = "Ex: Roblox ou 1",
		rigNameOptional = "Nome do Rig (opcional)",
		rigNamePlaceholder = "Usa o username se vazio",
		createRigButton = "Criar Rig",
		creatingRig = "Criando rig...",
		rigCreated = "Rig criado: ",
		rigError = "Erro: ",
		typeUsernameOrId = "Digite um username ou userId!",

		-- Loja
		searchPlaceholder = "Buscar ou colar ID...",
		searchButton = "Buscar",
		cleanRigButton = "Limpar Rig Selecionado",
		chooseCategory = "Escolha uma categoria ou busque",
		searching = "Buscando...",
		loadingMore = "Carregando mais...",
		results = "%d resultado(s)",
		noResults = "Nenhum resultado",
		searchError = "Erro na busca",
		applying = "Aplicando %s...",
		appliedSuccess = "'%s' aplicado em %s!",
		applyFailed = "Falha ao aplicar item. Verifique se o asset existe.",
		itemFound = "Item encontrado: ",
		itemNotFound = "Item nao encontrado: ",
		itemsFound = "%d itens encontrados",
		noItemFound = "Nenhum item encontrado",
		catalogError = "Erro ao buscar no catalogo",
		selectRigFirst = "Selecione um rig (Model com Humanoid) no workspace!",
		itemsRemoved = "%d item(s) removido(s) de %s",

		-- Categorias
		all = "Todos",
		clothing = "Roupas",
		shirts = "Camisas",
		pants = "Calcas",
		tshirts = "Camisetas",
		animations = "Animacoes",
		emotes = "Emotes",

		-- Bundles
		bundleTitle = "Bundle",
		bundleIdPlaceholder = "ID do Bundle...",
		bundleLoad = "Carregar",
		bundleLoading = "Carregando bundle...",
		bundleLoaded = "Bundle '%s' - %d item(s)",
		bundleNotFound = "Bundle nao encontrado",
		bundleError = "Erro ao carregar bundle",
		bundleApplyAll = "Aplicar Tudo",

		-- Configuracoes
		tabSettings = "Config",
		settingsTitle = "Configuracoes",
		languageSection = "Idioma",
		themeSection = "Tema",
		themeDefault = "Padrao",
		themeVampire = "Vampiro",
		themeDefaultDesc = "Estilo dark moderno",
		themeVampireDesc = "Gotico vermelho sangue",
		settingsSaved = "Configuracoes salvas!",
	},
}

-- ════════════════════════════════════════════════════════════════
-- Estado
-- ════════════════════════════════════════════════════════════════
local currentLang = "en"

function Locale.setLanguage(lang: string)
	currentLang = lang
end

function Locale.getLanguage(): string
	return currentLang
end

function Locale.get(key: string): string
	local table_ = STRINGS[currentLang] or STRINGS["en"]
	return table_[key] or STRINGS["en"][key] or key
end

-- Atalho para string.format com traducao
function Locale.fmt(key: string, ...: any): string
	return string.format(Locale.get(key), ...)
end

return Locale
