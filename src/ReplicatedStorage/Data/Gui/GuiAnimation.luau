-- Services --
local SoundService = game:GetService("SoundService")

local GuiAnimation = {}

GuiAnimation.ANIMATED_TAG = "Animated"
GuiAnimation.ANIMATION_TYPES_ATTRIBUTE_NAME = "AnimationTypes"

GuiAnimation.INTERACT_BUTTON_NAME = "Interact"

GuiAnimation.CLICK_SOUND = SoundService.SoundEffects.Gui.TactileClick

return GuiAnimation