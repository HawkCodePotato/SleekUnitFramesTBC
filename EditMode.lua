local ADDON_NAME, SUF = ...

-- Blizzard brought Edit Mode to TBC Anniversary 2.5.6. There is no public
-- third-party API for registering arbitrary custom systems directly into the
-- Blizzard system list without risking taint, so SleekUF bridges into the
-- official Edit Mode lifecycle instead: opening Edit Mode unlocks our own
-- selection overlays and preview frames, and closing it commits/restores the
-- user's previous layout state.

function SUF:EnterBlizzardEditMode()
    if self.editModeBridgeActive or not self.db or not self.db.editModeIntegration then
        return
    end
    if not self:IsLayoutChangeAllowed() then
        return
    end

    self.editModeBridgeActive = true
    self.editModeRestoreState = {
        locked = self.db.locked and true or false,
        previewMode = self.db.previewMode and true or false,
    }

    self:SetLocked(false, true)
    self.db.previewMode = true
    self:RefreshUnitWatches()
    self:RefreshAllUnitFrames(true)
    self:RefreshPartyGroupMover()
    self:RefreshSettingsPanel()
end

function SUF:ExitBlizzardEditMode()
    if not self.editModeBridgeActive or not self.db then
        return
    end

    if self:IsLayoutChangeAllowed() and self.CaptureLiveLayout then
        self:CaptureLiveLayout()
    end

    local previous = self.editModeRestoreState or { locked = true, previewMode = false }
    self.editModeBridgeActive = false
    self.editModeRestoreState = nil

    if self:IsLayoutChangeAllowed() then
        self:SetLocked(previous.locked, true)
        -- If frames were already unlocked before Blizzard Edit Mode opened,
        -- restore that preview choice instead of forcing a different workflow.
        if not previous.locked then
            self.db.previewMode = previous.previewMode
            self:RefreshUnitWatches()
            self:RefreshAllUnitFrames(true)
            self:RefreshPartyGroupMover()
        end
        self:RefreshSettingsPanel()
    end
end

function SUF:InitializeEditModeIntegration()
    if self.editModeIntegrationInitialized then
        return
    end
    self.editModeIntegrationInitialized = true

    local registeredLifecycleCallbacks = false
    if EventRegistry and EventRegistry.RegisterCallback then
        EventRegistry:RegisterCallback("EditMode.Enter", function()
            SUF:EnterBlizzardEditMode()
        end)
        EventRegistry:RegisterCallback("EditMode.Exit", function()
            SUF:ExitBlizzardEditMode()
        end)
        registeredLifecycleCallbacks = true
    end

    -- Defensive fallback for TBC builds where the lifecycle callbacks exist in
    -- Blizzard code but are not exposed through EventRegistry as expected.
    if not registeredLifecycleCallbacks and EditModeManagerFrame and EditModeManagerFrame.HookScript then
        EditModeManagerFrame:HookScript("OnShow", function()
            SUF:EnterBlizzardEditMode()
        end)
        EditModeManagerFrame:HookScript("OnHide", function()
            SUF:ExitBlizzardEditMode()
        end)
    end

    -- If the addon was reloaded while Edit Mode itself is already open, join it
    -- immediately rather than waiting for the next close/open cycle.
    if EditModeManagerFrame and EditModeManagerFrame.IsShown and EditModeManagerFrame:IsShown() then
        self:EnterBlizzardEditMode()
    end
end
