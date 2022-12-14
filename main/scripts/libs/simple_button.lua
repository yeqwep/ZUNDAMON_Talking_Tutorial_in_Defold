-- ------------------------------------------------------------------------------------------
-- simple_button by britzl
-- https://github.com/britzl/publicexamples/tree/master/examples/simple_button
-- ------------------------------------------------------------------------------------------
local M = {}
M.action_id_touch       = hash("touch")
M.action_id_multi       = hash("multi")
-- ボタン（点滅しない）
function M.create(node, callback)
	local button = {pressed = false, hover = false, use = true}	-- use=trueの時押せる
	-- define the input handler function
	function button.on_input(action_id, action)
		if gui.is_enabled(node) and button.use then
			-- mouse/finger over the button?
			local over = gui.pick_node(node, action.x, action.y)
			if over then
				button.hover = true
			elseif over == false and button.hover then
				button.hover = false
			end
			-- ボタン押したとき
			if button.hover and action.pressed and action_id == M.action_id_touch then
				button.pressed = true
				gui.set_scale(node,vmath.vector3(0.95,0.95,1))
			-- ボタンを押して離したとき
			elseif action.released and button.pressed and action_id == M.action_id_touch then
				button.pressed = false
				gui.set_scale(node,vmath.vector3(1,1,1))
				-- ボタン上にあるとき
				if button.hover then
					sound.play("main:/sound_fx#button")
					callback(button)
				end
			end
		end
	end
	function button.reset()
		button.pressed = false
		button.hover = false
		button.use = true
		gui.set_scale(node,vmath.vector3(1))
	end

	return button
end
-- ホバーした時コールバックする
function M.create_hover_callback(node, callback, hover_back)
	local button = {pressed = false, hover = false, use = true}	-- use=trueの時押せる
	-- ボタンの初期色
	local fb = gui.get_color(node)
	local fb_dark = vmath.vector4(fb.x - 0.4,fb.y - 0.4,fb.z - 0.4,1)
	gui.set_color(node,fb_dark)
	-- define the input handler function
	function button.on_input(action_id, action)
		if gui.is_enabled(node) and button.use then
			-- mouse/finger over the button?
			local over = gui.pick_node(node, action.x, action.y)
			if over and not button.hover then
				button.hover = true
				gui.cancel_animation(node, "color")
				gui.set_color(node,fb)
				hover_back()
			elseif over == false and button.hover then
				button.hover = false
				gui.animate(node, gui.PROP_COLOR, fb_dark, gui.EASING_INOUTCUBIC, 0.46, 0, nil, gui.PLAYBACK_ONCE_FORWARD)
			end
			-- ボタン押したとき
			if button.hover and action.pressed and action_id == M.action_id_touch then
				button.pressed = true
				gui.cancel_animation(node, gui.PROP_COLOR)
				gui.set_scale(node,vmath.vector3(0.95,0.95,1))
			-- ボタンを押して離したとき
			elseif action.released and button.pressed and action_id == M.action_id_touch then
				button.pressed = false
				gui.set_color(node,fb_dark)
				gui.set_scale(node,vmath.vector3(1,1,1))
				-- ボタン上にあるとき
				if button.hover then
					sound.play("main:/sound_fx#button")
					callback(button)
				end
			end
		end
	end
	return button
end
-- ボタン　（大きさふわふわ）
function M.create_scale(node, callback)
	local button = {pressed = false, hover = false}
	-- ボタンの初期色
	local fb = gui.get_color(node)
	fb.w = 0.8
	gui.set_color(node,fb)
	gui.animate(node, gui.PROP_SCALE, 0.95, gui.EASING_OUTQUAD, 0.8, 0, nil, gui.PLAYBACK_LOOP_PINGPONG)
	-- define the input handler function
	function button.on_input(action_id, action)
		if gui.is_enabled(node) then
			-- mouse/finger over the button?
			local over = gui.pick_node(node, action.x, action.y)

			if over then
				button.hover = true
				fb.w = 1
				gui.animate(node, 'color', fb, go.EASING_OUTQUAD, 0.2)
				gui.cancel_animation(node, "scale")
				gui.set_scale(node,vmath.vector3(1,1,1))
			elseif over == false and button.hover then
				button.hover = false
				fb.w = 0.8
				gui.animate(node, 'color', fb, go.EASING_OUTQUAD, 0.2,0 )
				gui.set_scale(node,vmath.vector3(1,1,1))
				gui.animate(node, gui.PROP_SCALE, 0.95, gui.EASING_OUTQUAD, 0.8, 0, nil, gui.PLAYBACK_LOOP_PINGPONG)
			end
			-- ボタン押したとき
			if button.hover and action.pressed and action_id == M.action_id_touch then
				button.pressed = true
				gui.cancel_animation(node, "scale")
				gui.set_scale(node,vmath.vector3(1,1,1))
				gui.animate(node, 'color', fb, go.EASING_OUTQUAD, 0.2)
			-- ボタンを押して離したとき
			elseif action.released and button.pressed and action_id == M.action_id_touch then
				button.pressed = false
				fb.w = 0.8
				gui.animate(node, 'color', fb, go.EASING_OUTQUAD, 0.2,0 )
				gui.set_scale(node,vmath.vector3(1,1,1))
				gui.animate(node, gui.PROP_SCALE, 0.95, gui.EASING_OUTQUAD, 0.8, 0, nil, gui.PLAYBACK_ONCE_PINGPONG)
				-- ボタン上にあるとき
				if button.hover then
					sound.play("main:/sound_fx#button")
					callback(button)
				end
			end
		end
	end

	return button
end
-- 表示が変わるスイッチflagを返す
function M.create_toggle(node, flag, callback)
	local button = {pressed = false, hover = false}
	local anim = {on = hash("b_on"), off = hash("b_off")}

	gui.play_flipbook(node, flag and anim.on or anim.off)

	function button.on_input(action_id, action, flag)
		local over = gui.pick_node(node, action.x, action.y)
		if over and action.pressed and action_id == M.action_id_touch then
			button.pressed = true
		elseif action.released and button.pressed and action_id == M.action_id_touch then
			button.pressed = false
			if over then
				flag = not flag
				gui.play_flipbook(node, flag and anim.on or anim.off)
				callback(button,flag)
			end
		end
	end

	return button
end
-- 切り替えタブスイッチ(画像無し)　一度押したら別の押されるまでフラグそのまま
function M.create_toggle_blank(node, flag, callback)
	local button = {pressed = false, hover = false}
	local fb = gui.get_color(node)
	fb.w = 0.92
	local fb_dark = vmath.vector4(fb.x - 0.3,fb.y - 0.3,fb.z - 0.3,0.7)
	local col = {on = fb, off = fb_dark}
	gui.set_color(node,flag and col.on or col.off)

	function button.on_input(action_id, action, flag)
		local over = gui.pick_node(node, action.x, action.y)
		if over and action.pressed and action_id == M.action_id_touch then
			button.pressed = true
			gui.cancel_animation(node, gui.PROP_COLOR)
			gui.set_color(node,flag and col.on or col.off)
		elseif action.released and button.pressed and action_id == M.action_id_touch then
			button.pressed = false
			if over then
				gui.set_color(node,fb)
				callback(button,flag)
			end
		end
	end
	return button
end
-- ------------------------------------------------------------------------------------------
-- nodeの数分のタグ
-- node_id : node名
-- node_num : node数
-- select_num : 現在選択中のノード番号
-- callback : callback関数
-- ------------------------------------------------------------------------------------------
function M.create_tags(node_id, node_num, select_num, callback)
	local button = {}									-- ボタンの状態
	local col = {}										-- ボタンのオンオフの色
	local fb = vmath.vector4(1,1,1, 0.7)
	local fb_dark = vmath.vector4(fb.x / 3,fb.y / 3,fb.z / 3,fb.w)
	local fb_hover = vmath.vector4(fb.x / 2,fb.y / 2,fb.z / 2,fb.w)
	col = {on = fb, off = fb_dark, hover = fb_hover}
	for i = 1, node_num do
		local node = gui.get_node(node_id .. i)
		button[i] = {node = node, hover = false, pressed = false, select = false}
		gui.set_color(button[i]["node"],col.off)
	end
	-- 入力時呼び出し関数
	function button.on_input(action_id, action)
		for j = 1, node_num do
			local over = gui.pick_node(button[j]["node"], action.x, action.y)
			-- 選択されていないリストのホバー時の反応
			if button[j]["select"] == false then
				if over and button[j]["hover"] == false then
					button[j]["hover"] = true
					gui.set_color(button[j]["node"],col.hover)
					print("over")
				elseif over == false and button[j]["hover"] then
					button[j]["hover"] = false
					gui.set_color(button[j]["node"],col.off)
				end
			end
			-- 押したときの反応
			if over and action.pressed and action_id == M.action_id_touch then
				button[j]["pressed"] = true
			elseif action.released and button[j]["pressed"] and action_id == M.action_id_touch then
				button[j]["pressed"] = false
				-- ノード上で選択されていない時コールバック呼び出し
				if over and not button[j]["select"] then
					--全タグの押したフラグ、色反映
					for k = 1, node_num do
						local push_flag = (k == j)
						button[k]["select"] = push_flag
						gui.set_color(button[k]["node"],push_flag and col.on or col.off)
					end
					-- コールバック実行
					callback(button,j)
					sound.play("main:/sound_fx#button")
					break
				end
			end
		end
	end
	-- 選択中のボタン変更
	function button.select_change(select_num)
		for i = 1, node_num do
			local select_flag = (i == select_num)
			button[i]["select"] = select_flag
			gui.set_color(button[i]["node"],select_flag and col.on or col.off)
		end
	end
	return button
end
-- ------------------------------------------------------------------------------------------
-- nodeの数分のタグ
-- node_id : node名
-- node_num : node数
-- callback : callback関数
-- ------------------------------------------------------------------------------------------
function M.create_list(node_id, node_num, callback)
	local button = {}									-- ボタンの状態
	local col = {}										-- ボタンのオンオフの色
	local fb = vmath.vector4(1,1,1, 0.46)
	local fb_dark = vmath.vector4(fb.x / 4,fb.y / 4,fb.z / 4,fb.w)
	local fb_hover = vmath.vector4(fb.x / 2,fb.y / 2,fb.z / 2,fb.w)
	col = {on = fb, off = fb_dark, hover = fb_hover}
	-- 全ノード設定
	for i = 1, node_num do
		local node = gui.get_node(node_id .. i.. "/back")
		button[i] = {node = node, hover = false, pressed = false, select = false}
		-- pprint(button)
		gui.set_color(button[i]["node"],col.off)
	end
	-- 入力時呼び出し関数
	function button.on_input(action_id, action)
		for j = 1, node_num do
			if gui.is_enabled(button[j]["node"]) then
				local over = gui.pick_node(button[j]["node"], action.x, action.y)
				-- 選択されていないリストのホバー時の反応
				if button[j]["select"] == false then
					if over and button[j]["hover"] == false then
						button[j]["hover"] = true
						gui.set_color(button[j]["node"],col.hover)
						print("over" ..j)
					elseif over == false and button[j]["hover"] then
						button[j]["hover"] = false
						gui.set_color(button[j]["node"],col.off)
					end
				end
				-- 押したときの反応
				if over and action.pressed and action_id == M.action_id_touch then
					button[j]["pressed"] = true
				elseif action.released and button[j]["pressed"] and action_id == M.action_id_touch then
					button[j]["pressed"] = false
					-- ノード上で選択されていない時コールバック呼び出し
					if over and not button[j]["select"] then
						--全タグの押したフラグ、色反映
						for k = 1, node_num do
							local push_flag = (k == j)
							button[k]["select"] = push_flag
							gui.set_color(button[k]["node"],push_flag and col.on or col.off)
						end
						-- コールバック実行
						print("push button num : " .. j)
						callback(button,j)
						sound.play("main:/sound_fx#button")
						break
					end
				end
			end
		end
	end
	-- 選択中のボタン更新
	function button.select_check(select_num)
		for i = 1, node_num do
			local select_flag = (i == select_num)
			button[i]["select"] = select_flag
			gui.set_color(button[i]["node"],select_flag and col.on or col.off)
		end
	end
	return button
end
return M