local talk = {}
local lips = require("assets.lips.lips")
talk.text = require("assets.txt.text")
-- --------------------------------------------------------------------------------------
-- リセット
function talk.reset()
	talk.time = 0				-- リップシンク時間
	talk.line = 0				-- 参照中の行
	talk.paragraph = 0			-- 現在の話
	talk.lip_end = false		-- リップシンク終わったか
	sound.stop()
	msg.post("/gui#fukidashi", "show")
	msg.post("/gui#slide","next",{page = 1})
end
-- 文節更新
function talk.next_paragraph()
	talk.paragraph = talk.paragraph + 1
	print(talk.paragraph)
	-- すべての文節を読み終わったとき更新しない
	if talk.paragraph > #lips then
		return
	end
	-- フキダシ、スライド、音声更新
	msg.post("/gui#fukidashi", "next", {paragraph = talk.paragraph})
	msg.post("/gui#slide", "next", {paragraph = talk.paragraph})
	local para = "zunda_" .. string.format( "%03d", talk.paragraph )
	local s_url = "main:/sound#" .. para
	sound.stop("main:/sound#")
	sound.play(s_url)
	-- リップシンク開始
	talk.time = 0
	talk.line = 1
	talk.lip_end = false
end
-- リップシンク更新
function talk.lip_update(self,dt)
	-- リップシンクがない時更新キャンセル
	if not lips[talk.paragraph] or talk.line < 1 then
		return
	end
	if talk.line > #lips[talk.paragraph] then
		-- リップシンク終わったとき更新キャンセル
		talk.lip_end = true
		talk.line = 0
		msg.post("/gui#fukidashi", "show_mark")
		return
	end
	-- リップシンク時間更新
	talk.time = talk.time + dt
	-- 時間経過したらリップシンク更新
	local t = lips[talk.paragraph][talk.line][2] - lips[talk.paragraph][talk.line][1]
	if talk.time > t then
		local k = lips[talk.paragraph][talk.line][3]
		msg.post("/zundamon", "update_lip", {kuti = k})
		talk.line = talk.line + 1
		talk.time = 0
	end
end
return talk
