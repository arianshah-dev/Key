-- \\ Variables
local CoreGUI = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Request = (syn and syn.request) or (http and http.request) or http_request
local Viewport = Workspace.Camera.ViewportSize
local Player = Players.LocalPlayer

-- \\ KeySystem Table
local KeySystemLibrary = {}

-- \\ Functions
function MakeDragg(DragPoint, Main)
    pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false
		DragPoint.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position

				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		DragPoint.InputChanged:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				DragInput = Input
			end
		end)
		UserInputService.InputChanged:Connect(function(Input)
			if Input == DragInput and Dragging and CanDragg then
				local Delta = Input.Position - MousePos
				TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)}):Play()
			end
		end)
    end)
end

function Updated(Exploit, Path)

    local Response = game:HttpGet("https://api.whatexploitsare.online/status/"..Exploit)
    local Data = HttpService:JSONDecode(Response)

    for _, item in pairs(Data) do
        for name, info in pairs(item) do
            if info.updated == false then

                Path.Text = "Not Updated"
                Path.TextColor3 = Color3.fromRGB(237, 52, 55)

            else

                Path.Text = "Updated"
                Path.TextColor3 = Color3.fromRGB(57, 229, 85)

            end
        end
    end

end

function KeySystemLibrary:CreateSystem(SettingsSystem)

    -- \\ Init UI Object
    local EnabledDiscord = SettingsSystem["DiscordEnabled"] or false
    if EnabledDiscord == false then
        getgenv().KeySystem = game:GetObjects("rbxassetid://13262945596")[1]
        KeySystem.Enabled = false
    else
        getgenv().KeySystem = game:GetObjects("rbxassetid://13263620057")[1]
        KeySystem.Enabled = false
    end

    -- \\ KeySystem Variables
    local Main = KeySystem.Main
    Main.Position = UDim2.fromOffset((Viewport.X/2) - (Main.Size.X.Offset / 2), (Viewport.Y/2) - (Main.Size.Y.Offset / 2))
    local KeyTab = Main.Left.KEY
    local ApiTab = Main.Left.API
    local CloseKey = Main.CloseKey
    local KeyHolder = KeyTab.KeyHolder
    local ButtonHolder = KeyTab.ButtonHolder
    local Exploits = ApiTab.EXPLOITS.Container
    local APIS = ApiTab.APIS.Container
    local ProfilePicture = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    KeySystem.Parent = CoreGUI
    KeyTab.PlayerIcon.Image = ProfilePicture
    KeyTab.PlayerIcon.BackgroundColor3 = Color3.fromRGB(100,100,100)
    KeyTab.Title.Text = "Hello, "..Player.Name.."!"

    -- \\ Configure Exploits
    Updated("synapse", Exploits.SynapseX.Status)
    Updated("script-ware", Exploits["Script Ware"].Status)
    Updated("fluxus", Exploits.Fluxus.Status)
    Updated("KRNL", Exploits.Krnl.Status)
    Updated("wearedevs", APIS.WRD.Status)
    Updated("comet", APIS.Comet.Status)

    if APIS.Comet.Status.Text=="Not Updated" or APIS.WRD.Status.Text=="Not Updated" then
        Exploits.ViperX.Status.Text = "Not Updated"
        Exploits.ViperX.Status.TextColor3 = Color3.fromRGB(237, 52, 55)
    else
        Exploits.ViperX.Status.Text = "Updated"
        Exploits.ViperX.Status.TextColor3 = Color3.fromRGB(57, 229, 85)
    end

    -- \\ Enable GUI
    KeySystem.Enabled = true

    -- \\ Settings
    getgenv().CanDragg = SettingsSystem["CanDraggable"] or true
    KeyTab.Site.Text = SettingsSystem["KeySettings"]["SiteLink"]
    KeyTab.SubTitle.Text = SettingsSystem["KeySettings"]["Subtitle"]
    local DiscordLink = SettingsSystem["DiscordSettings"]["Invite"]
    local GrabFromSite = SettingsSystem["KeySettings"]["GrabKeyFromSite"] or false
    local Key = SettingsSystem["KeySettings"]["Key"]

    -- \\ Configure Discord
    if EnabledDiscord then
        local Discord = Main:FindFirstChild("Right").DISCORD
        Discord.Title.Text = SettingsSystem["DiscordSettings"]["ServerTitle"]
        Discord.SubTitle.Text = SettingsSystem["DiscordSettings"]["ServerDescription"]
        Discord.DiscordIcon.Image = "http://www.roblox.com/asset/?id="..SettingsSystem["DiscordSettings"]["ServerImageID"]
        
        Discord.JoinDiscord.Title.MouseButton1Click:Connect(function()

            if Request then
                Request({
                    Url = 'http://127.0.0.1:6463/rpc?v=1',
                    Method = 'POST',
                    Headers = {
                        ['Content-Type'] = 'application/json',
                        Origin = 'https://discord.com'
                    },
                    Body = HttpService:JSONEncode({
                        cmd = 'INVITE_BROWSER',
                        nonce = HttpService:GenerateGUID(false),
                        args = {code = DiscordLink}
                    })
                })
            end
        
        end)

    end

    -- \\ MakeDragg
    if CanDragg then
        MakeDragg(Main, Main)
    end
    
    -- \\ Configure Close Button
    CloseKey.MouseEnter:Connect(function()
        TweenService:Create(CloseKey, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(237, 52, 55)}):Play()
    end)

    CloseKey.MouseLeave:Connect(function()
        TweenService:Create(CloseKey, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)

    CloseKey.MouseButton1Click:Connect(function()
        KeySystem:Destroy()
    end)

    -- Configure Key
    KeyHolder.KeyHided.Focused:Connect(function()
        
        TweenService:Create(KeyHolder.Separator, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(57, 229, 85)}):Play()

    end)

    KeyHolder.KeyHided.FocusLost:Connect(function()
        
        TweenService:Create(KeyHolder.Separator, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()

    end)

    local Hided = false
    KeyHolder.HideKey.MouseButton1Click:Connect(function()
        Hided = not Hided
        if Hided == true then
            KeyHolder.HideKey.Image = "http://www.roblox.com/asset/?id=10137832201"
            KeyHolder.KeyBox.Text = string.rep('•', #KeyHolder.KeyHided.Text)
            KeyHolder.KeyBox.TextSize = 20
        else
            KeyHolder.HideKey.Image = "http://www.roblox.com/asset/?id=6031763426"
            KeyHolder.KeyBox.Text = KeyHolder.KeyHided.Text
            KeyHolder.KeyBox.TextSize = 16
        end
    end)

    ButtonHolder.CopyKey.Title.MouseButton1Click:Connect(function()
        setclipboard(SettingsSystem["KeySettings"]["KeyLink"])
        ButtonHolder.CopyKey.Title.Text = "Copied!"
        wait(1)
        ButtonHolder.CopyKey.Title.Text = "Copy Key Link"
    end)

    local Executed = false
    ButtonHolder.CheckKey.Title.MouseButton1Click:Connect(function()
        if KeyHolder.KeyHided.Text == SettingsSystem["KeySettings"]["Key"] then
            loadstring(game:HttpGet(SettingsSystem["KeySettings"]["ScriptRawLoad"]))()
            ButtonHolder.CheckKey.Title.Text = "Correct Key!! :)"
            KeySystem:Destroy()
            Executed = true
        elseif KeyHolder.KeyHided.Text == "" then
            ButtonHolder.CheckKey.Title.Text = "Empty lol"   
        else
            ButtonHolder.CheckKey.Title.Text = "Incorret Key :("
        end
        wait(1)
        if not Executed then ButtonHolder.CheckKey.Title.Text = "Check Key" end
    end)

    KeyHolder.KeyHided:GetPropertyChangedSignal('Text'):Connect(function()

        if Hided == true then
            KeyHolder.KeyBox.Text = string.rep('•', #KeyHolder.KeyHided.Text)
        else
            KeyHolder.KeyBox.Text = KeyHolder.KeyHided.Text
        end

    end)

    return CreateSystem

end

return KeySystemLibrary
