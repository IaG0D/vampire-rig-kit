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
		rotationTitle = "Rotation (Y axis)",
		modeTitle = "Rigs per Pedestal",
		modeSolo = "Solo",
		modeDuo = "Duo",
		modeTrio = "Trio",
		spreadLabel = "Spacing (studs)",
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

		-- Amigos e confirmacao
		friendsTitle = "Friends",
		friendsLoading = "Loading friends...",
		friendsNone = "No friends found.",
		friendsError = "Could not load friends.",
		friendsLoadButton = "LOAD",
		friendsPlaceholder = "Username or UserId...",
		goButton = "Go",
		confirmTitle = "Confirm Rig",
		rigNameLabel = "Rig Name",
		nameTagLabel = "Name Tag",
		nameTagDesc = "BillboardGui above the head",
		spawnRigButton = "SPAWN RIG",
		updateRigButton = "UPDATE RIG",
		backButton = "Back",
		updatingRig = "Updating rig...",
		rigUpdated = "Rig updated: ",
		selectRigToUpdate = "Select a rig to update!",

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
		rotationTitle = "Rotação (eixo Y)",
		modeTitle = "Rigs por Pedestal",
		modeSolo = "Solo",
		modeDuo = "Duo",
		modeTrio = "Trio",
		spreadLabel = "Espaçamento (studs)",
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

		-- Amigos e confirmacao
		friendsTitle = "Amigos",
		friendsLoading = "Carregando amigos...",
		friendsNone = "Nenhum amigo encontrado.",
		friendsError = "Nao foi possivel carregar amigos.",
		friendsLoadButton = "CARREGAR",
		friendsPlaceholder = "Username ou UserId...",
		goButton = "Ir",
		confirmTitle = "Confirmar Rig",
		rigNameLabel = "Nome do Rig",
		nameTagLabel = "Name Tag",
		nameTagDesc = "BillboardGui acima da cabeca",
		spawnRigButton = "CRIAR RIG",
		updateRigButton = "ATUALIZAR RIG",
		backButton = "Voltar",
		updatingRig = "Atualizando rig...",
		rigUpdated = "Rig atualizado: ",
		selectRigToUpdate = "Selecione um rig para atualizar!",

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
