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
		renameRigs = "Rename",
		renamePlaceholder = "Prefix (e.g. Rig)",
		renameStartPlaceholder = "Start",
		rigsRenamed = "Renamed %d rig(s)!",
		noRigsToRename = "Define rigs first to rename!",
		pedestalsTitle = "Pedestals",
		noPedestalsDefined = "No pedestals defined",
		setPedestals = "Set Pedestals (from selection)",
		clearPedestals = "Clear Pedestals",
		alignButton = "Align Rigs on Pedestals",
		offsetTitle = "Offset (fine tuning)",
		applyOffset = "Apply Offset",
		rotationTitle = "Rotation (Y axis)",
		applyRotation = "Apply Rotation",
		noRigsSelected = "Select rigs in the workspace!",
		rotationApplied = "Rotated %d rig(s)!",
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
		experimentalSection = "Experimental",
		experimentalShopLabel = "Outfit Builder",
		experimentalShopDesc = "Enable the Outfit Builder tab (experimental, may not work correctly)",

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

		-- JSON Import
		jsonImportTitle = "JSON Import",
		jsonImportDesc = "Paste the Avatar Scanner JSON to create rigs.",
		jsonPastePlaceholder = "Paste JSON here...",
		jsonLoadSingle = "LOAD 1 RIG",
		jsonLoadAll = "LOAD ALL RIGS",
		jsonParsing = "Parsing JSON...",
		jsonCreatingSingle = "Creating rig from JSON...",
		jsonCreatingBatch = "Creating rigs... %d/%d",
		jsonSingleCreated = "JSON rig created: %s",
		jsonBatchDone = "%d rig(s) created, %d failed",
		jsonEmptyInput = "Paste the JSON first!",
		jsonInvalidFormat = "Invalid JSON format!",
		jsonBatchNotDetected = "JSON does not contain a rigs array!",
		jsonSingleNotDetected = "JSON does not contain player data!",

		-- Outfit Builder
		outfitBuilderTitle = "Outfit Builder",
		outfitBuilderDesc = "Build a custom outfit from any base avatar.\nBrowse the catalog, add items, and create the rig.",
		pickBaseAvatar = "Pick Base Avatar",
		baseAvatarLabel = "Base: @%s",
		addedItemsTitle = "Added Items",
		addedItemsCount = "%d item(s) added",
		noItemsAdded = "No items added yet",
		cleanItemsButton = "Clean Items",
		createOutfitRig = "CREATE RIG",
		updatingPreview = "Updating preview...",
		itemAdded = "'%s' added to outfit!",
		itemRemoved = "'%s' removed from outfit",
		itemsCleaned = "%d item(s) cleaned",
		baseAvatarLoaded = "Base avatar loaded: %s",
		baseAvatarError = "Could not load base avatar",
		outfitRigCreated = "Outfit rig created: ",
		outfitRigError = "Error creating outfit rig: ",
		noBaseAvatar = "Pick a base avatar first!",
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
		renameRigs = "Renomear",
		renamePlaceholder = "Prefixo (ex: Rig)",
		renameStartPlaceholder = "Início",
		rigsRenamed = "%d rig(s) renomeado(s)!",
		noRigsToRename = "Defina os rigs primeiro para renomear!",
		pedestalsTitle = "Pedestais",
		noPedestalsDefined = "Nenhum pedestal definido",
		setPedestals = "Definir Pedestais (da selecao)",
		clearPedestals = "Limpar Pedestais",
		alignButton = "Alinhar Rigs nos Pedestais",
		offsetTitle = "Offset (ajuste fino)",
		applyOffset = "Aplicar Offset",
		rotationTitle = "Rotação (eixo Y)",
		applyRotation = "Aplicar Rotação",
		noRigsSelected = "Selecione rigs no workspace!",
		rotationApplied = "Rotacionou %d rig(s)!",
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
		experimentalSection = "Experimental",
		experimentalShopLabel = "Construtor de Outfit",
		experimentalShopDesc = "Habilitar aba do Construtor de Outfit (experimental, pode nao funcionar corretamente)",

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

		-- JSON Import
		jsonImportTitle = "Importar JSON",
		jsonImportDesc = "Cole o JSON do Avatar Scanner para criar rigs.",
		jsonPastePlaceholder = "Cole o JSON aqui...",
		jsonLoadSingle = "CARREGAR 1 RIG",
		jsonLoadAll = "CARREGAR TODOS",
		jsonParsing = "Processando JSON...",
		jsonCreatingSingle = "Criando rig do JSON...",
		jsonCreatingBatch = "Criando rigs... %d/%d",
		jsonSingleCreated = "Rig JSON criado: %s",
		jsonBatchDone = "%d rig(s) criado(s), %d falha(s)",
		jsonEmptyInput = "Cole o JSON primeiro!",
		jsonInvalidFormat = "Formato JSON invalido!",
		jsonBatchNotDetected = "JSON nao contem array de rigs!",
		jsonSingleNotDetected = "JSON nao contem dados de player!",

		-- Outfit Builder
		outfitBuilderTitle = "Construtor de Outfit",
		outfitBuilderDesc = "Monte um outfit customizado a partir de qualquer avatar base.\nNavegue o catalogo, adicione itens e crie o rig.",
		pickBaseAvatar = "Escolher Avatar Base",
		baseAvatarLabel = "Base: @%s",
		addedItemsTitle = "Itens Adicionados",
		addedItemsCount = "%d item(s) adicionado(s)",
		noItemsAdded = "Nenhum item adicionado ainda",
		cleanItemsButton = "Limpar Itens",
		createOutfitRig = "CRIAR RIG",
		updatingPreview = "Atualizando preview...",
		itemAdded = "'%s' adicionado ao outfit!",
		itemRemoved = "'%s' removido do outfit",
		itemsCleaned = "%d item(s) limpo(s)",
		baseAvatarLoaded = "Avatar base carregado: %s",
		baseAvatarError = "Nao foi possivel carregar avatar base",
		outfitRigCreated = "Rig de outfit criado: ",
		outfitRigError = "Erro ao criar rig: ",
		noBaseAvatar = "Escolha um avatar base primeiro!",
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
