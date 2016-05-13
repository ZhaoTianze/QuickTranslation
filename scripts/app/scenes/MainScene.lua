
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
	self.support = {
		en = 1,
		zhs = 1,
		zht = 1,
	}

	local newItem1 = ui.newTTFLabelMenuItem({listener = handler(self,self.distribute),text = "分发", size = 30})
	local newItem2 = ui.newTTFLabelMenuItem({listener = handler(self,self.merge),text = "合并", size = 30})

	newItem1:setPosition(cc.p(display.cx, display.cy+200))
	newItem2:setPosition(cc.p(display.cx, display.cy-200))
	local menu = ui.newMenu({newItem1,newItem2})
	self:addChild(menu)
end

function MainScene:onEnter()
	lfs.checkDir("born2play/Solitaire")
end

function MainScene:openLanguage_()
	local languageFile = "Language.json"
	local languageFilePath = lfs.getFilePath(languageFile)
	local language = lfs.readFile(languageFilePath)
	assert(language and type(language) == "table","错误的language解析")
	return language
end
--分发
function MainScene:distribute()
	printf("MainScene:distribute")
	local needTranList = {}
	local language = self:openLanguage_()
	for keyTitle,lanList in pairs(language) do
		for languageKey,v in pairs(self.support) do
			if not lanList[languageKey] or lanList[languageKey] == "" then
				--有需要翻译的内容
				-- printf("%s 需要被翻译成 %s",keyTitle,languageKey)
				if not needTranList[languageKey] then
					needTranList[languageKey] = {}
				end
				local label = lanList.en or lanList.zhs
				assert(label,"没有可用的原文本内容")
				needTranList[languageKey][keyTitle] = {en = label, translate = ""}
			end
		end
	end
	for key,needTable in pairs(needTranList) do
		local fileName = string.format("Language_%s.json",key)
		local filePath = lfs.getFilePath(fileName)
		lfs.writeFile(filePath,needTable)
	end
end
--合并
function MainScene:merge()
	printf("MainScene:merge")
	local haveChanged = false
	local language = self:openLanguage_()
	for languageKey,v in pairs(self.support) do
		local fileName = string.format("Language_%s.json",languageKey)
		local filePath = lfs.getFilePath(fileName)
		local localLan = lfs.readFile(filePath)
		if localLan and type(localLan) == "table" then
			for keyTitle,lanList in pairs(localLan) do
				if lanList.translate ~= "" then
					if not language[keyTitle] then
						language[keyTitle] = {}
					end
					language[keyTitle][languageKey] = lanList.translate
					haveChanged = true
				end
			end
		end
	end

	if haveChanged then
		printf("需要重写文件langauge.json")
		local languageFile = "Language.json"
		local languageFilePath = lfs.getFilePath(languageFile)
		lfs.writeFile(languageFilePath,language)
	else
		printf("no changed")
	end
end

function MainScene:onExit()
end

return MainScene
