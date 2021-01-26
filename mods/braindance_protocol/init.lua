local BraindanceProtocol = {
description = "",
rootPath =	"plugins.cyber_engine_tweaks.mods.braindance_protocol."
}

local BD = require(BraindanceProtocol.rootPath.."BD")

registerForEvent("onInit", function()
	CPS = require(BraindanceProtocol.rootPath.."CPStyling")
	fact = require(BraindanceProtocol.rootPath.."fact")
	i18n = require(BraindanceProtocol.rootPath.."i18n")
	languages = require(BraindanceProtocol.rootPath.."lang.lang")
	theme = CPS.theme
	color = CPS.color
	currentWorkingDir = CPS.getCWD("braindance_protocol")
	config = loadConfig(currentWorkingDir)
	protocols = require(BraindanceProtocol.rootPath.."protocols")
	drawWindow = false
	wWidth, wHeight = GetDisplayResolution()
	-- Execute Braindance protocols
	BD.Examples.Initialise()
end)

registerHotkey("braindance_protocol_interface", "Open Protocol Interface", function()
	if not drawWindow then
		for i in pairs(protocols.Items) do
			if protocols.Items[i].parent == "Facts" and protocols.Items[i].type ~= "Button" then
				protocols.Items[i].value = fact.GetValue(protocols.Items[i].id)
			end
		end
	end
	drawWindow = not drawWindow
end)

registerForEvent("onUpdate", function()
	for l in pairs(languages) do
		if languages[l].selLang then
			setLang(languages[l].id, currentWorkingDir)
			languages[l].selLang = false
		end
	end
	for i in pairs(protocols.Items) do
		if protocols.Items[i].press then
			if protocols.Items[i].type ~= "Button" and protocols.Items[i].value ~= nil then
				protocols.Items[i].cmd(protocols.Items[i].value)
			else
				protocols.Items[i].cmd()
			end
		end
	end
end)

registerForEvent("onDraw", function()
	if drawWindow then
		CPS.setThemeBegin()
		CPS.styleBegin("WindowPadding", 5, 5)
		drawWindow = ImGui.Begin(i18n("window_title"), true, ImGuiWindowFlags.NoResize | ImGuiWindowFlags.NoTitleBar)
		ImGui.SetWindowSize(400, 620)
		ImGui.SetWindowPos(wWidth-600, wHeight/2-180, ImGuiCond.FirstUseEver)
		ImGui.AlignTextToFramePadding()
		ImGui.Text(i18n("window_title"))
		ImGui.SameLine(390-ImGui.CalcTextSize(i18n("button_language")))
		ImGui.Text(i18n("button_language"))
		if ImGui.IsItemClicked() then
			ImGui.OpenPopup("Language")
		end
		if ImGui.BeginPopup("Language") then
			for l in pairs(languages) do
				languages[l].selLang = ImGui.Selectable(languages[l].name, false)
			end
			ImGui.EndPopup()
		end
		local Childx, Childy = ImGui.GetContentRegionAvail()
		ImGui.BeginChild("List", Childx+6, Childy)
		for i in pairs(protocols.Parents) do
			if i <= 2 then ImGui.SetNextItemOpen(true, ImGuiCond.FirstUseEver) end
			CPS.colorBegin("Text" , color.white)
			CPS.colorBegin("Header", { 0.08, 0.08, 0.15, 0.8 })
			local headerOpen = ImGui.CollapsingHeader(protocols.Parents[i].name)
			CPS.colorEnd(2)
			if headerOpen then
				ImGui.Indent(3)
				for t in pairs(protocols.Items) do
					local btnWidth = 130
					if protocols.Items[t].parent == protocols.Parents[i].id then
						ImGui.BeginGroup()
						ImGui.PushID(t)
						if protocols.Items[t].type == "Button" then
							protocols.Items[t].press = CPS.CPButton(protocols.Items[t].button_label, btnWidth, 0)
						elseif protocols.Items[t].type == "Input" then
							ImGui.PushItemWidth(btnWidth*2/3-2)
							protocols.Items[t].value = ImGui.InputInt("##input" , protocols.Items[t].value, 0)
							ImGui.PopItemWidth()
							ImGui.SameLine(btnWidth*2/3)
							protocols.Items[t].press = CPS.CPButton(protocols.Items[t].button_label, btnWidth/3, 0)
						elseif protocols.Items[t].type == "Toggle" then
							protocols.Items[t].value, protocols.Items[t].press = CPS.CPToggle( nil, protocols.Items[t].button_label1, protocols.Items[t].button_label2, protocols.Items[t].value, btnWidth, 0)
						elseif protocols.Items[t].type == "Select" then
							ImGui.PushItemWidth(btnWidth)
							protocols.Items[t].value, protocols.Items[t].press = ImGui.Combo("##select", protocols.Items[t].value, protocols.Items[t].options)
							ImGui.PopItemWidth()
						end
						ImGui.SameLine()
						ImGui.Text(protocols.Items[t].name)
						ImGui.PopID()
						ImGui.EndGroup()
						if ImGui.IsItemHovered() then
							ImGui.SetTooltip(protocols.Items[t].description)
						end
					end
				end
				ImGui.Unindent(3)
			end
		end
		ImGui.EndChild()
		ImGui.End()
		CPS.styleEnd(1)
		CPS.setThemeEnd()
	end
end)

function saveConfig(config_file, config)
	local file = io.open(config_file, "w")
	io.output(file)
	local jconfig = json.encode(config)
	io.write(jconfig)
	file:close()
end

function loadConfig(currentWorkingDir)
	local config_file = currentWorkingDir.."config.json"
	local config
	if CPS.fileExists(config_file) then
		local file = io.open(config_file, "r")
		io.input(file)
		config = json.decode(io.read("*a"))
		file:close()
		if config.lang == nil then
			config.lang = "en"
			saveConfig(config_file, config)
		end
	else
		config = { lang = "en" }
		saveConfig(config_file, config)
	end
	if config.lang ~= "en" then
		i18n.loadFile(currentWorkingDir.."lang/en.lua")
	end
	i18n.loadFile(currentWorkingDir.."lang/"..config.lang..".lua")
	i18n.setLocale(config.lang)
	return config
end

function setLang(language, currentWorkingDir)
	i18n.loadFile(currentWorkingDir.."lang/"..language..".lua")
	i18n.setLocale(language)
	config.lang = language
	saveConfig(currentWorkingDir.."config.json", config)
end

return BD
