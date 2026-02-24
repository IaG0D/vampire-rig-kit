--[[
	vulpy-rig-kit | Tipos Compartilhados
	Definicoes de tipos usados pelos modulos do plugin.
]]

export type OffsetValues = {
	X: number,
	Y: number,
	Z: number,
}

export type WidgetElements = {
	widget: DockWidgetPluginGui,
	setRigsButton: TextButton,
	clearRigsButton: TextButton,
	setPedestaisButton: TextButton,
	clearPedestaisButton: TextButton,
	alignButton: TextButton,
	applyOffsetButton: TextButton,
	rigsCountLabel: TextLabel,
	pedestaisCountLabel: TextLabel,
	statusLabel: TextLabel,
	offsetX: TextBox,
	offsetY: TextBox,
	offsetZ: TextBox,
	offsetXMinus: TextButton,
	offsetXPlus: TextButton,
	offsetYMinus: TextButton,
	offsetYPlus: TextButton,
	offsetZMinus: TextButton,
	offsetZPlus: TextButton,
}

return nil
