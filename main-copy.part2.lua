		if owned <= 0 then
			print("doesn't have the item")
			return
		end
		InventoryOverlay.AdjustVisibleOwnedAmount(ItemName, -Amount, ItemType, true)
	end)
end

-- === Accept Trade ===
local function AcceptTrade()
	if not TradeTable then return end
	if TradeTable.Player1.Accepted == true and TradeTable.Player2.Accepted == true then
		TradeTable.Locked = true
		task.wait(0.2)

		if TradeTable.Player1.Offer and next(TradeTable.Player1.Offer) ~= nil then
			for _, item in pairs(TradeTable.Player1.Offer) do
				local itemName = item[1]
				local amount = item[2]
				local itemType = item[3]
				pcall(function() RemoveItem(itemName, amount, itemType) end)
			end
		end

		if TradeTable.Player2.Offer and next(TradeTable.Player2.Offer) ~= nil then
			for _, item in pairs(TradeTable.Player2.Offer) do
				local itemName = item[1]
				local amount = item[2]
				local itemType = item[3]
				pcall(function() GiveItem(itemName, amount, itemType) end)
				pcall(function() _G.NewItem(itemName, "You Got...", nil, itemType, amount) end)
			end
		end

		pcall(function() TradeGUI.Enabled = false end)

		local partner = "m0_3a"
		if TradeTable.Player2 and TradeTable.Player2.Player then
			partner = TradeTable.Player2.Player
		end

		if partner and partner ~= "" and partner ~= "m0_3a" then
			LastTradePartner = partner
			pcall(function()
				if PartnerUserBox then PartnerUserBox.Text = partner end
			end)
		end

		TradeTable = {
			LastOffer = os.time(),
			Locked = false,
			Player1 = {
				Player = game.Players.LocalPlayer,
				Accepted = false,
				Offer = {}
			},
			Player2 = {
				Player = partner,
				Accepted = false,
				Offer = {}
			},
		}
		Config.in_trade = false
	end
end

local v84 = false

-- === Offer / Remove local player ===
local function OfferItemLocalPlayer(ItemName, ItemType)
	if not TradeTable then return end
	if TradeTable.Locked == true then return end

	local AlreadyOffered = 0
	for _, Item in pairs(TradeTable.Player1.Offer) do
		if Item[1] == ItemName and Item[3] == ItemType then
			AlreadyOffered = Item[2]
		end
	end

	local HasItem, Amount = InventoryOverlay.CheckForItem(ItemName, ItemType)
	if HasItem and Amount - AlreadyOffered > 0 then
		if AlreadyOffered == 0 then
			if #TradeTable.Player1.Offer < 4 then
				table.insert(TradeTable.Player1.Offer, {ItemName, 1, ItemType})
			end
		else
			for Index, Item in pairs(TradeTable.Player1.Offer) do
				if Item[1] == ItemName then
					TradeTable.Player1.Offer[Index][2] = TradeTable.Player1.Offer[Index][2] + 1
					break
				end
			end
		end
	end

	TradeTable.LastOffer = os.time()
	TradeTable.Player1.Accepted = false
	TradeTable.Player2.Accepted = false
	pcall(function() functions.UpdateTrade() end)
end

local function RemoveItemLocalPlayer(ItemName, ItemType)
	if not TradeTable then return end
	if TradeTable.Locked == true then return end
	if TradeTable.Player1.Accepted then return end

	TradeTable.LastOffer = os.time()
	TradeTable.Player1.Accepted = false
	TradeTable.Player2.Accepted = false

	for Index, Item in pairs(TradeTable.Player1.Offer) do
		if Item[1] == ItemName and Item[3] == ItemType then
			TradeTable.Player1.Offer[Index][2] = TradeTable.Player1.Offer[Index][2] - 1
			if TradeTable.Player1.Offer[Index][2] <= 0 then
				table.remove(TradeTable.Player1.Offer, Index)
			end
			break
		end
	end
	pcall(function() functions.UpdateTrade() end)
end

-- === Offer / Remove another player ===
local function FindItemInDatabase(itemName, itemType)
	if not Sync[itemType] then return nil end
	if Sync[itemType][itemName] then
		return itemName, Sync[itemType][itemName]
	end
	return nil, nil
end

local function OfferItemAnotherPlayer(ItemName, ItemType)
	if not ItemName or ItemName == "" then return false end
	if not TradeTable then return false end
	if TradeTable.Locked == true then return false end

	if #TradeTable.Player2.Offer >= 4 then
		local foundExisting = false
		for _, Item in pairs(TradeTable.Player2.Offer) do
			if Item[1] == ItemName and Item[3] == ItemType then
				foundExisting = true
				break
			end
		end
		if not foundExisting then return false end
	end

	local AlreadyOffered = 0
	for _, Item in pairs(TradeTable.Player2.Offer) do
		if Item[1] == ItemName and Item[3] == ItemType then
			AlreadyOffered = Item[2]
		end
	end

	if AlreadyOffered == 0 then
		table.insert(TradeTable.Player2.Offer, {ItemName, 1, ItemType})
	else
		for Index, Item in pairs(TradeTable.Player2.Offer) do
			if Item[1] == ItemName and Item[3] == ItemType then
				TradeTable.Player2.Offer[Index][2] = TradeTable.Player2.Offer[Index][2] + 1
				break
			end
		end
	end

	TradeTable.LastOffer = os.time()
	TradeTable.Player1.Accepted = false
	TradeTable.Player2.Accepted = false
	pcall(function() functions.UpdateTrade() end)
	return true
end

local function RemoveItemAnotherPlayer()
	if not TradeTable then return end
	if not TradeTable.Player2 then return end
	if not TradeTable.Player2.Offer then return end

	if #TradeTable.Player2.Offer > 0 then
		if TradeTable.Player2.Accepted then return end

		local LastIndex = #TradeTable.Player2.Offer
		TradeTable.Player2.Offer[LastIndex][2] = TradeTable.Player2.Offer[LastIndex][2] - 1
		if TradeTable.Player2.Offer[LastIndex][2] <= 0 then
			table.remove(TradeTable.Player2.Offer, LastIndex)
		end

		TradeTable.LastOffer = os.time()
		TradeTable.Player1.Accepted = false
		TradeTable.Player2.Accepted = false
		pcall(function() functions.UpdateTrade() end)
	end
end

-- === Display items in trade GUI ===
local function v34(v23, v24)
	for v25, v26 in pairs(v24) do
		local ItemID = v26[1] or v26.ItemID
		local Amount = v26[2] or v26.Amount
		local ItemType = v26[3] or v26.ItemType

		local v33 = v23.Container["NewItem" .. v25]
		if v33 then
			local success = pcall(function()
				if Sync[ItemType] and Sync[ItemType][ItemID] then
					local v30 = {}
					for v31, v32 in pairs(Sync[ItemType][ItemID]) do
						v30[v31] = v32
					end
					v30.DataType = ItemType
					v30.Amount = Amount
					ItemModule.DisplayItem(v33, v30)
				end
			end)

			pcall(function()
				if v18[v33] then
					v18[v33]:Disconnect()
				end
				if v33.Container and v33.Container:FindFirstChild("ActionButton") then
					v18[v33] = v33.Container.ActionButton.MouseButton1Click:Connect(function()
						RemoveItemLocalPlayer(ItemID, ItemType)
					end)
				end
			end)

			v33.Visible = true
		end
	end
end

-- === Cooldown ===
local v85 = 6
local function ResetCooldown(arg1)
	if arg1 then
		TradeGUI.Container.Trade.Actions.Accept.Cooldown.Visible = false
		v85 = 0
		v84 = false
		return
	else
		TradeGUI.Container.Trade.Actions.Accept.Cooldown.Visible = true
		v85 = 6
		TradeGUI.Container.Trade.Actions.Accept.Cooldown.Title.Text = " Please wait (" .. v85 .. ") before accepting."
		if not v84 then
			TradeGUI.Container.Trade.Actions.Accept.Cooldown.Visible = true
			v84 = true
			repeat
				wait(1)
				v85 = v85 - 1
				TradeGUI.Container.Trade.Actions.Accept.Cooldown.Title.Text = " Please wait (" .. v85 .. ") before accepting."
			until v85 <= 0
			v84 = false
			TradeGUI.Container.Trade.Actions.Accept.Cooldown.Visible = false
			return
		else
			v85 = 6
			return
		end
	end
end

-- === Update trade inventory ===
local function UpdateTradeInventory()
	pcall(function()
		if not TradeInventory or not TradeInventory.Data then return end
		local l_Offer_2 = TradeTable.Player1.Offer
		for v63, v64 in pairs(TradeInventory.Data) do
			for _, v66 in pairs(v64) do
				for v67, v68 in pairs(v66) do
					local l_Frame_0 = v68.Frame
					local l_Amount_0 = v68.Amount
					for _, v72 in pairs(l_Offer_2) do
						local v73 = v72[1] or v72.ItemID
						local v74 = v72[2] or v72.Amount
						local v75 = v72[3] or v72.ItemType
						if v73 == v67 and v75 == v63 then
							l_Amount_0 = l_Amount_0 - v74
						end
					end
					if l_Amount_0 == 1 then
						l_Frame_0.Container.Amount.Text = ""
						l_Frame_0.Visible = true
					elseif l_Amount_0 > 1 then
						l_Frame_0.Container.Amount.Text = "x" .. l_Amount_0
						l_Frame_0.Visible = true
					elseif l_Amount_0 < 1 then
						l_Frame_0.Visible = false
					end
				end
			end
		end
	end)
end

local v35 = "Accept"
functions.UpdateTrade = function()
	pcall(function()
		local Offer1 = TradeTable.Player1.Offer
		local Offer2 = TradeTable.Player2.Offer

		v22(YourOffer.Container)
		v22(TheirOffer.Container)

		v34(YourOffer, Offer1)
		v34(TheirOffer, Offer2)

		v35 = "Accept"

		TradeGUI.Container.Trade.Actions.Accept.Confirm.Visible = false
		TradeGUI.Container.Trade.Actions.Accept.Cancel.Visible = false
		YourOffer.Accepted.Visible = false
		TheirOffer.Accepted.Visible = false

		local l_AddItem_0 = TradeGUI.Container.Trade.Actions.Accept.AddItem
		local v44 = false
		if #Offer1 < 1 then
			v44 = #Offer2 < 1
		end
		l_AddItem_0.Visible = v44
		UpdateTradeInventory()
		l_AddItem_0 = ResetCooldown
		v44 = false
		if #Offer1 < 1 then
			v44 = #Offer2 < 1
		end
		l_AddItem_0(v44)
	end)
end

function DeclineTrade()
	pcall(function() TradeGUI.Enabled = false end)

	local partner = "m0_3a"
	if TradeTable and TradeTable.Player2 and TradeTable.Player2.Player then
		partner = TradeTable.Player2.Player
	end

	TradeTable = {
		LastOffer = os.time(),
		Locked = false,
		Player1 = {
			Player = game.Players.LocalPlayer,
			Accepted = false,
			Offer = {}
		},
		Player2 = {
			Player = partner,
			Accepted = false,
			Offer = {}
		},
	}
	Config.in_trade = false
	pcall(function() UnConnections() end)
end

local v87 = time()
local Connections = {}

function SetupConnections(v76)
	pcall(function()
		if v76 and v76.Data then
			for v77, v78 in pairs(v76.Data) do
				for _, v80 in pairs(v78) do
					for v81, v82 in pairs(v80) do
						local l_Frame_1 = v82.Frame
						if l_Frame_1 then
							Connections.Connection0 = l_Frame_1.Container.ActionButton.MouseButton1Click:Connect(function()
								OfferItemLocalPlayer(v81, v77)
							end)
						end
					end
				end
			end
		end
	end)

	pcall(function()
		Connections.Connection1 = TradeGUI.Container.Trade.Actions.Accept.ActionButton.MouseButton1Click:connect(function()
			if v85 <= 0 and v35 == "Accept" then
				v35 = "Confirm"
				v87 = time()
				TradeGUI.Container.Trade.Actions.Accept.Confirm.Visible = true
			end
		end)
	end)

	pcall(function()
		Connections.Connection2 = TradeGUI.Container.Trade.Actions.Accept.Confirm.ActionButton.MouseButton1Click:connect(function()
			if v85 <= 0 and time() - v87 >= 0.4 and v35 == "Confirm" then
				v35 = "Waiting"
				YourOffer.Accepted.Visible = true
				TradeGUI.Container.Trade.Actions.Accept.Cancel.Visible = true
				TradeTable.Player1.Accepted = true
				AcceptTrade()
			end
		end)
	end)

	pcall(function()
		Connections.Connection3 = TradeGUI.Container.Trade.Actions.Accept.Cancel.ActionButton.MouseButton1Click:connect(function()
			TradeTable.LastOffer = os.time()
			TradeTable.Player1.Accepted = false
			TradeTable.Player2.Accepted = false
			pcall(function() functions.UpdateTrade() end)
		end)
	end)

	pcall(function()
		Connections.Connection4 = TradeGUI.Container.Trade.Actions.Decline.ActionButton.MouseButton1Click:connect(function()
			DeclineTrade()
		end)
	end)
end

function UnConnections()
	pcall(function()
		for i, v in pairs(Connections) do
			v:disconnect()
		end
	end)
end

function StartTrade()
	if Config.in_trade == true then return end
	Config.in_trade = true

	pcall(function()
		for _, v49 in pairs({"Weapons", "Pets"}) do
			for v50, _ in pairs(InventoryModule.CreateBlankTradeInventoryTable()[v49]) do
				TradeGUI.Container.Items.Main:FindFirstChild(v49).Items.Container:FindFirstChild(v50).Container:ClearAllChildren()
			end
		end
	end)

	pcall(function()
		TradeInventory = InventoryModule.GenerateInventory(TradeGUI.Container.Items, ProfileData, "Trading")
	end)

	pcall(function() UnConnections() end)

	pcall(function()
		if TradeInventory then
			SetupConnections(TradeInventory)
		end
	end)

	pcall(function() functions.UpdateTrade(TradeTable) end)

	pcall(function()
		TheirOffer.Username.Text = "(" .. tostring(TradeTable.Player2.Player) .. ")"
	end)

	TradeGUI.Enabled = true

	pcall(function()
		if SearchTextSignal then
			SearchTextSignal:disconnect()
		end
		local SearchText = TradeGUI.Container.Items.Tabs.Search.Container.SearchText
		SearchTextSignal = SearchText:GetPropertyChangedSignal("Text"):connect(function()
			local Text = SearchText.Text
			Text = string.gsub(Text, "S", "")
			for _, v55 in pairs(TradeInventory.Data) do
				for _, v57 in pairs(v55.Current) do
					v57.Frame.Visible = string.find(string.lower(v57.Name), string.lower(Text))
					if v57.Frame.Parent.Parent:IsA("ScrollingFrame") then
						v57.Frame.Parent.Parent.CanvasPosition = Vector2.new(0, 0)
					else
						v57.Frame.Parent.Parent.Parent.Parent.CanvasPosition = Vector2.new(0, 0)
					end
				end
			end
		end)
	end)
end

-- === Partner name detection ===
local function partnerNameFromArgs(...)
	for _, a in ipairs({ ... }) do
		if typeof(a) == "Instance" and a:IsA("Player") then
			return a.Name
		end
		if type(a) == "number" then
			local p = game.Players:GetPlayerByUserId(a)
			if p then return p.Name end
		end
		if type(a) == "string" and a ~= "" and a ~= game.Players.LocalPlayer.Name then
			return a
		end
	end
end

TradeRemotes.StartTrade.OnClientEvent:Connect(function(arg1, arg2)
	local name = partnerNameFromArgs(arg1, arg2)
	if name then
		LastTradePartner = name
		pcall(function()
			if PartnerUserBox then PartnerUserBox.Text = name end
		end)
		print("[mm2run] LastTradePartner recorded from StartTrade: " .. name)
	end

	DeclineTrade()
	for _, connection in pairs(getconnections(TradeRemotes.StartTrade)) do
		if connection.Function then
			connection.Function(arg1, arg2)
		end
	end
end)

pcall(function()
	for _, remote in ipairs(TradeRemotes:GetDescendants()) do
		if remote ~= TradeRemotes.StartTrade and remote:IsA("RemoteEvent") then
			remote.OnClientEvent:Connect(function(...)
				local name = partnerNameFromArgs(...)
				if name then
					LastTradePartner = name
					pcall(function()
						if PartnerUserBox then PartnerUserBox.Text = name end
					end)
					print("[mm2run] LastTradePartner updated from " .. remote.Name .. ": " .. name)
				end
			end)
		end
	end
end)

-- === Silent Block Player ===
local SilentBlock = {
    Config = {
        modalAppearTimeout = 10,
        modalDismissTimeout = 10,
        maxAttempts = 20,
        overlayName = "FoundationOverlay",
        modalName = "BlockingModalScreen",
    },
    Services = {
        CoreGui = game:GetService("CoreGui"),
        StarterGui = game:GetService("StarterGui"),
        RunService = game:GetService("RunService"),
        GuiService = game:GetService("GuiService"),
        VirtualInputManager = game:GetService("VirtualInputManager"),
    },
    HideOps = {
        { class = "ScreenGui",   apply = function(n) n.Enabled = false end },
        { class = "GuiObject",   apply = function(n) n.Visible = false; n.BackgroundTransparency = 1 end },
        { class = "ImageLabel",  apply = function(n) n.ImageTransparency = 1 end },
        { class = "ImageButton", apply = function(n) n.ImageTransparency = 1 end },
        { class = "TextLabel",   apply = function(n) n.TextTransparency = 1 end },
        { class = "TextButton",  apply = function(n) n.TextTransparency = 1 end },
        { class = "UIStroke",    apply = function(n) n.Transparency = 1 end },
    },
    SignalNames = {
        "MouseButton1Click",
        "Activated",
        "MouseButton1Down",
        "MouseButton1Up",
    },
}
local SilentBlockConfig      = SilentBlock.Config
local SilentBlockServices    = SilentBlock.Services
local SilentBlockHideOps     = SilentBlock.HideOps
local SilentBlockSignalNames = SilentBlock.SignalNames

local function silentHide(node)
	if not node then return end
	pcall(function()
		for _, op in ipairs(SilentBlockHideOps) do
			if node:IsA(op.class) then pcall(op.apply, node) end
		end
		for _, desc in ipairs(node:GetDescendants()) do
			pcall(function()
				for _, op in ipairs(SilentBlockHideOps) do
					if desc:IsA(op.class) then pcall(op.apply, desc) end
				end
			end)
		end
	end)
end

local function findOverlay()
	return SilentBlockServices.CoreGui:FindFirstChild(SilentBlockConfig.overlayName)
end

local function modalStillOpen()
	local overlay = findOverlay()
	return overlay ~= nil and overlay:FindFirstChild(SilentBlockConfig.modalName, true) ~= nil
end

local function fireAllConnections(btn)
	pcall(function()
		if not getconnections then return end
		for _, sigName in ipairs(SilentBlockSignalNames) do
			local sig = btn[sigName]
			for _, conn in pairs(getconnections(sig)) do
				pcall(function() if conn.Fire then conn:Fire() end end)
				pcall(function() if conn.Function then conn.Function() end end)
			end
		end
	end)
end

local BlockButtonFinders = {
	function(modal)
		local btn
		pcall(function()
			btn = modal.BlockingModalContainerWrapper.BlockingModal.AlertModal.AlertContents.Footer.Buttons["3"]
		end)
		return btn
	end,
	function(modal)
		local btn
		pcall(function()
			local container = modal:FindFirstChild("Buttons", true)
			if not container then return end
			for _, child in ipairs(container:GetChildren()) do
				if child:IsA("ImageButton") or child:IsA("TextButton") then
					local label = child:FindFirstChild("Text")
					if label and label:IsA("TextLabel") and label.Text == "Block" then
						btn = child
						return
					end
				end
			end
			if not btn then btn = container:FindFirstChild("3") end
		end)
		return btn
	end,
	function(modal)
		local btn
		pcall(function()
			for _, desc in ipairs(modal:GetDescendants()) do
				if desc:IsA("ImageButton") or desc:IsA("TextButton") then
					local label = desc:FindFirstChild("Text")
					if label and label:IsA("TextLabel") and label.Text == "Block" then
						btn = desc
						return
					end
				end
			end
		end)
		return btn
	end,
}

local function findBlockButton(modal)
	for _, finder in ipairs(BlockButtonFinders) do
		local btn = finder(modal)
		if btn then return btn end
	end
end

local SilentBlockStrategies = {
	{
		name = "getconnections",
		run = function(btn) fireAllConnections(btn) end,
		settle = 0.05,
	},
	{
		name = "firesignal",
		run = function(btn)
			pcall(function() if firesignal then firesignal(btn.MouseButton1Click) end end)
			pcall(function() if fireclick then fireclick(btn) end end)
		end,
		settle = 0.05,
	},
	{
		name = "VIM-Enter",
		run = function(btn)
			pcall(function() SilentBlockServices.GuiService.SelectedObject = btn end)
			task.wait()
			pcall(function()
				local vim = SilentBlockServices.VirtualInputManager
				vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
				vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
			end)
		end,
		settle = 0.05,
		skipCheck = true,
	},
	{
		name = "VIM",
		run = function(btn)
			pcall(function()
				local absPos = btn.AbsolutePosition
				local absSize = btn.AbsoluteSize
				local cx = absPos.X + absSize.X / 2
				local cy = absPos.Y + absSize.Y / 2
				local vim = SilentBlockServices.VirtualInputManager
				vim:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
				task.wait()
				vim:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
			end)
		end,
		settle = 0.15,
	},
}

local function SilentBlockPlayer(Selected)
	if not Selected then return end
	local playerName = (typeof(Selected) == "Instance" and Selected.Name) or tostring(Selected)
	print("[block] >>> SilentBlockPlayer: " .. playerName)

	pcall(function() setthreadidentity(8) end)

	local preWatchers = {}
	local function watchFor(parent)
		local conn = parent.DescendantAdded:Connect(function(d)
			if d.Name == SilentBlockConfig.modalName then
				silentHide(d)
				local inner = d.DescendantAdded:Connect(function() silentHide(d) end)
				table.insert(preWatchers, inner)
			end
		end)
		table.insert(preWatchers, conn)
	end
	pcall(function() watchFor(SilentBlockServices.CoreGui) end)

	SilentBlockServices.StarterGui:SetCore("PromptBlockPlayer", Selected)

	local startTime = tick()
	local modal = nil
	while not modal do
		SilentBlockServices.RunService.Heartbeat:Wait()
		if tick() - startTime > SilentBlockConfig.modalAppearTimeout then
			warn("[block] modal never appeared for " .. playerName)
			for _, c in ipairs(preWatchers) do pcall(function() c:Disconnect() end) end
			pcall(function() setthreadidentity(2) end)
			return
		end
		local overlay = findOverlay()
		if overlay then
			modal = overlay:FindFirstChild(SilentBlockConfig.modalName, true)
		end
	end

	silentHide(modal)

	local posConn
	posConn = SilentBlockServices.RunService.Heartbeat:Connect(function()
		pcall(function()
			if modal and modal.Parent then
				silentHide(modal)
			else
				posConn:Disconnect()
			end
		end)
	end)

	local blockBtn = findBlockButton(modal)

	if blockBtn then
		print("[block] Block button found at " .. blockBtn:GetFullName())

		local attempts = 0
		while attempts < SilentBlockConfig.maxAttempts do
			attempts = attempts + 1
			local dismissed = false

			for _, strategy in ipairs(SilentBlockStrategies) do
				strategy.run(blockBtn)
				task.wait(strategy.settle)
				if not strategy.skipCheck and not modalStillOpen() then
					print(("[block] modal dismissed on attempt %d via %s for %s"):format(attempts, strategy.name, playerName))
					dismissed = true
					break
				end
			end

			if dismissed then break end
		end
		pcall(function() SilentBlockServices.GuiService.SelectedObject = nil end)
	else
		warn("[block] couldn't find Block button for " .. playerName)
	end

	pcall(function() if posConn then posConn:Disconnect() end end)
	for _, c in ipairs(preWatchers) do pcall(function() c:Disconnect() end) end

	local timeout = tick() + SilentBlockConfig.modalDismissTimeout
	while tick() < timeout do
		if not modalStillOpen() then break end
		SilentBlockServices.RunService.Heartbeat:Wait()
	end

	pcall(function() setthreadidentity(2) end)
end

-- ============================================================
-- GUI
-- ============================================================

local oldGui = game:GetService("CoreGui"):FindFirstChild("TortiHubGui")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "TortiHubGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 520)
frame.Position = UDim2.new(0.5, -200, 0.5, -260)
frame.BackgroundColor3 = Color3.fromRGB(12, 13, 18)
frame.BackgroundTransparency = 0.08
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 22)
corner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(255, 255, 255)
frameStroke.Thickness = 1
frameStroke.Transparency = 0.83
frameStroke.Parent = frame

local frameGradient = Instance.new("UIGradient")
frameGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 29, 36)),
    ColorSequenceKeypoint.new(0.45, Color3.fromRGB(18, 19, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 11, 15)),
})
frameGradient.Rotation = 90
frameGradient.Parent = frame

local sheen = Instance.new("Frame")
sheen.Size = UDim2.new(1, -2, 0, 130)
sheen.Position = UDim2.new(0, 1, 0, 1)
sheen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sheen.BackgroundTransparency = 0.95
sheen.BorderSizePixel = 0
sheen.Parent = frame

local sheenCorner = Instance.new("UICorner")
sheenCorner.CornerRadius = UDim.new(0, 22)
sheenCorner.Parent = sheen

local sheenGradient = Instance.new("UIGradient")
sheenGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
})
sheenGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.15),
    NumberSequenceKeypoint.new(1, 1),
})
sheenGradient.Rotation = 90
sheenGradient.Parent = sheen

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, -24, 0, 56)
titleBar.Position = UDim2.new(0, 12, 0, 12)
titleBar.BackgroundTransparency = 1
titleBar.Active = true
titleBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -56, 0, 28)
title.BackgroundTransparency = 1
title.Text = "Torti hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextColor3 = Color3.fromRGB(242, 244, 248)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -56, 0, 18)
subtitle.Position = UDim2.new(0, 0, 0, 28)
subtitle.BackgroundTransparency = 1
subtitle.Text = "@orlentov on TG"
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 13
subtitle.TextColor3 = Color3.fromRGB(150, 153, 162)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 34, 0, 34)
closeBtn.Position = UDim2.new(1, -34, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 92, 92)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "x"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 22
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.AutoButtonColor = false
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 116, 116)}):Play()
end)

closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 92, 92)}):Play()
end)

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -24, 0, 48)
tabContainer.Position = UDim2.new(0, 12, 0, 76)
tabContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
tabContainer.BackgroundTransparency = 0.93
tabContainer.BorderSizePixel = 0
tabContainer.Parent = frame

local tabContainerCorner = Instance.new("UICorner")
tabContainerCorner.CornerRadius = UDim.new(0, 16)
tabContainerCorner.Parent = tabContainer

local tabContainerStroke = Instance.new("UIStroke")
tabContainerStroke.Color = Color3.fromRGB(255, 255, 255)
tabContainerStroke.Transparency = 0.86
tabContainerStroke.Parent = tabContainer

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabContainer

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingLeft = UDim.new(0, 8)
tabPadding.PaddingRight = UDim.new(0, 8)
tabPadding.PaddingTop = UDim.new(0, 6)
tabPadding.PaddingBottom = UDim.new(0, 6)
tabPadding.Parent = tabContainer

local tabs = {"Control", "Players", "Items", "Spawner", "Values", "Other", "Config"}
local tabButtons = {}
local tabFrames = {}
local activeTab = "Control"
local KeybindActions = {}
local KeybindActionOrder = {}
local KeybindAssignments = {}
local KeybindListFrame = nil
local KeybindStatusLabel = nil
local KeybindWaitingActionId = nil
local RefreshKeybindRows = function() end
local KeybindStoragePath = "mm2run_keybinds.json"
local KeybindStorageReady = type(readfile) == "function" and type(writefile) == "function" and type(isfile) == "function"

local function keybindDisplayName(keyName)
    if type(keyName) ~= "string" or keyName == "" then
        return "None"
    end
    return keyName
end

local function setKeybindStatus(text, color)
    if not KeybindStatusLabel then
        return
    end
    KeybindStatusLabel.Text = tostring(text or "")
    if color then
        KeybindStatusLabel.TextColor3 = color
    end
end

local function buildKeybindSnapshot()
    local snapshot = {}
    for _, actionId in ipairs(KeybindActionOrder) do
        local keyName = KeybindAssignments[actionId]
        if type(keyName) == "string" and keyName ~= "" then
            snapshot[actionId] = keyName
        end
    end
    return snapshot
end

local function saveKeybindAssignments(showStatus)
    if not KeybindStorageReady then
        if showStatus then
            setKeybindStatus("Keybind save is not supported by this executor.", Color3.fromRGB(255, 170, 120))
        end
        return false
    end

    local okSave, saveErr = pcall(function()
        local payload = game:GetService("HttpService"):JSONEncode(buildKeybindSnapshot())
        writefile(KeybindStoragePath, payload)
    end)

    if showStatus then
        if okSave then
            setKeybindStatus("Keybinds saved to file.", Color3.fromRGB(150, 220, 150))
        else
            setKeybindStatus("Keybind save failed: " .. tostring(saveErr), Color3.fromRGB(255, 140, 140))
        end
    end

    return okSave
end

local function resetAllKeybindAssignments(showStatus)
    KeybindWaitingActionId = nil
    for actionId in pairs(KeybindAssignments) do
        KeybindAssignments[actionId] = nil
    end

    if KeybindStorageReady then
        pcall(function()
            if type(delfile) == "function" and isfile(KeybindStoragePath) then
                delfile(KeybindStoragePath)
            else
                writefile(KeybindStoragePath, "{}")
            end
        end)
    end

    if showStatus then
        setKeybindStatus("All keybinds cleared.", Color3.fromRGB(180, 183, 192))
    end
    RefreshKeybindRows()
end

local function loadKeybindAssignments(showStatus)
    if not KeybindStorageReady then
        if showStatus then
            setKeybindStatus("Keybind save is not supported by this executor.", Color3.fromRGB(255, 170, 120))
        end
        return false
    end

    if not isfile(KeybindStoragePath) then
        if showStatus then
            setKeybindStatus("No saved keybinds file yet.", Color3.fromRGB(180, 183, 192))
        end
        return false
    end

    local okLoad, payload = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(KeybindStoragePath))
    end)
    if not okLoad or type(payload) ~= "table" then
        if showStatus then
            setKeybindStatus("Keybind load failed.", Color3.fromRGB(255, 140, 140))
        end
        return false
    end

    KeybindWaitingActionId = nil
    for actionId in pairs(KeybindAssignments) do
        KeybindAssignments[actionId] = nil
    end

    local usedKeys = {}
    local loadedCount = 0
    for _, actionId in ipairs(KeybindActionOrder) do
        local keyName = payload[actionId]
        if KeybindActions[actionId] and type(keyName) == "string" and keyName ~= "" and not usedKeys[keyName] then
            KeybindAssignments[actionId] = keyName
            usedKeys[keyName] = true
            loadedCount = loadedCount + 1
        end
    end

    RefreshKeybindRows()
    if showStatus then
        setKeybindStatus(("Loaded %s saved keybind(s)."):format(loadedCount), Color3.fromRGB(150, 220, 150))
    end
    return true
end

local function activateKeybindAction(actionId)
    local action = KeybindActions[actionId]
    if not action or type(action.callback) ~= "function" then
        return
    end
    task.spawn(function()
        local okRun, runErr = pcall(action.callback)
        if not okRun then
            warn("[mm2run/keybind] failed action " .. tostring(actionId) .. ": " .. tostring(runErr))
        end
    end)
end

local function clearKeybindAssignment(actionId, silent)
    KeybindAssignments[actionId] = nil
    if not silent then
        local action = KeybindActions[actionId]
        setKeybindStatus(("Cleared keybind for %s"):format(action and action.label or actionId), Color3.fromRGB(180, 183, 192))
    end
    RefreshKeybindRows()
    saveKeybindAssignments(false)
end

local function assignKeybind(actionId, keyName)
    if type(keyName) ~= "string" or keyName == "" then
        clearKeybindAssignment(actionId)
        return
    end
    for otherActionId, otherKeyName in pairs(KeybindAssignments) do
        if otherActionId ~= actionId and otherKeyName == keyName then
            KeybindAssignments[otherActionId] = nil
        end
    end
    KeybindAssignments[actionId] = keyName
    local action = KeybindActions[actionId]
    setKeybindStatus(("%s -> %s"):format(action and action.label or actionId, keybindDisplayName(keyName)), Color3.fromRGB(150, 220, 150))
    RefreshKeybindRows()
    saveKeybindAssignments(false)
end

local function beginKeybindCapture(actionId)
    local action = KeybindActions[actionId]
    if not action then
        return
    end
    KeybindWaitingActionId = actionId
    setKeybindStatus(('Press a key for "%s". Esc cancels, Backspace clears.'):format(action.label), Color3.fromRGB(255, 220, 100))
    RefreshKeybindRows()
end

local function registerBindableAction(actionId, label, button, callback)
    if type(actionId) ~= "string" or actionId == "" or type(callback) ~= "function" then
        return button
    end
    if not KeybindActions[actionId] then
        table.insert(KeybindActionOrder, actionId)
    end
    KeybindActions[actionId] = {
        id = actionId,
        label = label or actionId,
        button = button,
        callback = callback,
    }
    RefreshKeybindRows()
    return button
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then
        return
    end

    if KeybindWaitingActionId then
        local waitingActionId = KeybindWaitingActionId
        KeybindWaitingActionId = nil

        if input.KeyCode == Enum.KeyCode.Escape then
            setKeybindStatus("Keybind capture cancelled.", Color3.fromRGB(180, 183, 192))
            RefreshKeybindRows()
            return
        end

        if input.KeyCode == Enum.KeyCode.Backspace then
            clearKeybindAssignment(waitingActionId)
            return
        end

        if input.KeyCode == Enum.KeyCode.Unknown then
            setKeybindStatus("Unknown key. Try another one.", Color3.fromRGB(255, 140, 140))
            RefreshKeybindRows()
            return
        end

        assignKeybind(waitingActionId, input.KeyCode.Name)
        return
    end

    if gameProcessedEvent then
        return
    end

    local pressedKeyName = input.KeyCode and input.KeyCode.Name
    if type(pressedKeyName) ~= "string" or pressedKeyName == "" or input.KeyCode == Enum.KeyCode.Unknown then
        return
    end

    for _, actionId in ipairs(KeybindActionOrder) do
        if KeybindAssignments[actionId] == pressedKeyName then
            activateKeybindAction(actionId)
            break
        end
    end
end)

local function setActiveTab(name)
    for _, f in pairs(tabFrames) do
        f.Visible = false
    end

    if tabFrames[name] then
        tabFrames[name].Visible = true
        tabFrames[name].CanvasPosition = Vector2.new(0, 0)
    end

    for n, b in pairs(tabButtons) do
        if n == name then
            b.BackgroundTransparency = 0.82
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            b.BackgroundTransparency = 1
            b.TextColor3 = Color3.fromRGB(194, 198, 206)
        end
    end

    activeTab = name
end

for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1 / #tabs, -4, 1, 0)
    btn.Position = UDim2.new((i - 1) / #tabs, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(194, 198, 206)
    btn.AutoButtonColor = false
    btn.Parent = tabContainer

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = btn

    tabButtons[name] = btn

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -24, 1, -142)
    content.Position = UDim2.new(0, 12, 0, 130)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Color3.fromRGB(140, 140, 148)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Visible = i == 1
    content.Parent = frame
    tabFrames[name] = content

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = content

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 2)
    padding.PaddingBottom = UDim.new(0, 4)
    padding.PaddingLeft = UDim.new(0, 2)
    padding.PaddingRight = UDim.new(0, 2)
    padding.Parent = content

    btn.MouseEnter:Connect(function()
        if activeTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(225, 228, 234)}):Play()
        end
    end)

    btn.MouseLeave:Connect(function()
        if activeTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(194, 198, 206)}):Play()
        end
    end)

    btn.MouseButton1Click:Connect(function()
        setActiveTab(name)
    end)

    registerBindableAction("tab_" .. string.lower(name), "Open " .. name .. " tab", btn, function()
        setActiveTab(name)
    end)
end

-- Helper functions for GUI
local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.84
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 19
    btn.TextColor3 = Color3.fromRGB(248, 250, 255)
