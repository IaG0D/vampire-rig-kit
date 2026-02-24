--[[
	vulpy-rig-kit | FriendsService
	Busca a lista de amigos do usuario logado no Studio.
	Usa StudioService:GetUserId() + Players:GetFriendsAsync().
]]

local Players = game:GetService("Players")
local StudioService = game:GetService("StudioService")

local FriendsService = {}

-- ════════════════════════════════════════════════════════════════
-- Tipos
-- ════════════════════════════════════════════════════════════════
export type FriendInfo = {
	Id: number,
	Username: string,
	DisplayName: string,
	IsOnline: boolean,
}

-- ════════════════════════════════════════════════════════════════
-- Retorna o userId do usuario logado no Studio
-- ════════════════════════════════════════════════════════════════
function FriendsService.getStudioUserId(): number
	return StudioService:GetUserId()
end

-- ════════════════════════════════════════════════════════════════
-- Busca todos os amigos do userId fornecido
-- Retorna lista de FriendInfo ou nil + mensagem de erro
-- ════════════════════════════════════════════════════════════════
function FriendsService.buscarAmigos(userId: number): ({ FriendInfo }?, string?)
	local success, friendsPages = pcall(function()
		return Players:GetFriendsAsync(userId)
	end)

	if not success or not friendsPages then
		return nil, "Falha ao buscar amigos"
	end

	local amigos: { FriendInfo } = {}

	local ok = pcall(function()
		while true do
			for _, item in friendsPages:GetCurrentPage() do
				table.insert(amigos, {
					Id = item.Id,
					Username = item.Username,
					DisplayName = item.DisplayName,
					IsOnline = item.IsOnline,
				})
			end
			if friendsPages.IsFinished then break end
			friendsPages:AdvanceToNextPageAsync()
		end
	end)

	if not ok then
		if #amigos > 0 then
			return amigos, nil
		end
		return nil, "Erro ao iterar paginas de amigos"
	end

	return amigos, nil
end

return FriendsService
