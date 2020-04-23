local LinkedModifiers = {}

-- terror_lord_flame_of_menace modifiers
modifier_terror_lord_flame_of_menace = modifier_terror_lord_flame_of_menace or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end
})

function modifier_terror_lord_flame_of_menace:OnDestroy()
    if (not IsServer()) then
        return
    end
    UTIL_Remove(self:GetParent())
end

function modifier_terror_lord_flame_of_menace:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.damage = self.ability:GetSpecialValueFor("damage") / 100
    self.width = self.ability:GetSpecialValueFor("width")
    self.casterTeam = self.caster:GetTeam()
    self.sourcePos = self:GetParent():GetAbsOrigin()
    self.targetPos = self.sourcePos + self.caster:GetForwardVector() * keys.length
    local tick = self.ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(tick)
end

function modifier_terror_lord_flame_of_menace:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local enemies = FindUnitsInLine(self.casterTeam,
            self.sourcePos,
            self.targetPos,
            self.caster,
            self.width,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE)
    local damage = self.damage * Units:GetAttackDamage(self.caster)
    for _, enemy in pairs(enemies) do
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = enemy
        damageTable.ability = self.ability
        damageTable.damage = damage
        damageTable.infernodmg = true
        GameMode:DamageUnit(damageTable)
    end
end

LinkedModifiers["modifier_terror_lord_flame_of_menace"] = LUA_MODIFIER_MOTION_NONE

-- terror_lord_flame_of_menace
terror_lord_flame_of_menace = class({
    GetAbilityTextureName = function(self)
        return "terror_lord_flame_of_menace"
    end
})

function terror_lord_flame_of_menace:OnSpellStart(unit, special_cast)
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local casterPos = caster:GetAbsOrigin()
    local length = self:GetSpecialValueFor("length")
    local targetPos = casterPos + caster:GetForwardVector() * length
    local duration = self:GetSpecialValueFor("duration")
    caster:EmitSound("Hero_AbyssalUnderlord.Firestorm.Target")
    local pidx = ParticleManager:CreateParticle("particles/units/terror_lord/flame_of_menace/flame_of_menace.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(pidx, 1, targetPos)
    ParticleManager:SetParticleControl(pidx, 2, Vector(duration, 0, 0))
    Timers:CreateTimer(duration, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    CreateModifierThinker(
            caster,
            self,
            "modifier_terror_lord_flame_of_menace",
            {
                duration = duration,
                length = length
            },
            casterPos,
            caster:GetTeamNumber(),
            false
    )
    if (TalentTree:GetHeroTalentLevel(caster, 34) > 0) then
        local meteorDistance = 100
        local distance = meteorDistance
        while (distance < length) do
            local pidx3 = ParticleManager:CreateParticle("particles/units/terror_lord/malicious_flames/malicious_flames_impact.vpcf", PATTACH_ABSORIGIN, caster)
            local position = casterPos + (caster:GetForwardVector() * distance)
            ParticleManager:SetParticleControl(pidx3, 0, position)
            Timers:CreateTimer(1.0, function()
                ParticleManager:DestroyParticle(pidx3, false)
                ParticleManager:ReleaseParticleIndex(pidx3)
            end)
            local enemies = FindUnitsInRadius(caster:GetTeam(),
                    position,
                    nil,
                    200,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
            for _, enemy in pairs(enemies) do
                local damageTable = {}
                damageTable.caster = caster
                damageTable.target = enemy
                damageTable.ability = self
                damageTable.damage = Units:GetAttackDamage(caster)
                damageTable.infernodmg = true
                GameMode:DamageUnit(damageTable)
            end
            distance = distance + meteorDistance
        end
    end
end

-- terror_lord_immolation modifiers
modifier_terror_lord_immolation = modifier_terror_lord_immolation or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    GetEffectName = function(self)
        return "particles/units/terror_lord/immolation/immolation.vpcf"
    end
})

function modifier_terror_lord_immolation:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.damage = self.ability:GetSpecialValueFor("damage") / 100
    self.radius = self.ability:GetSpecialValueFor("radius")
    self.casterTeam = self.caster:GetTeam()
    local tick = self.ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(tick)
end

function modifier_terror_lord_immolation:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    EmitSoundOn("Hero_EmberSpirit.FlameGuard.Loop", self.caster)
    local enemies = FindUnitsInRadius(self.casterTeam,
            self.caster:GetAbsOrigin(),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local damage = self.damage * Units:GetAttackDamage(self.caster)
    for _, enemy in pairs(enemies) do
        local damageTable = {}
        damageTable.caster = self.caster
        damageTable.target = enemy
        damageTable.ability = self.ability
        damageTable.damage = damage
        damageTable.infernodmg = true
        GameMode:DamageUnit(damageTable)
        local pidx = ParticleManager:CreateParticle("particles/units/terror_lord/immolation/immolation_impact_v2.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
        Timers:CreateTimer(2.0, function()
            ParticleManager:DestroyParticle(pidx, false)
            ParticleManager:ReleaseParticleIndex(pidx)
        end)
    end
end

LinkedModifiers["modifier_terror_lord_immolation"] = LUA_MODIFIER_MOTION_NONE

-- terror_lord_immolation
terror_lord_immolation = class({
    GetAbilityTextureName = function(self)
        return "terror_lord_immolation"
    end
})

function terror_lord_immolation:OnToggle(unit, special_cast)
    if IsServer() then
        local caster = self:GetCaster()
        caster.terror_lord_immolation = caster.terror_lord_immolation or {}
        if (self:GetToggleState()) then
            caster.terror_lord_immolation.modifier = caster:AddNewModifier(caster, self, "modifier_terror_lord_immolation", { Duration = -1 })
            self:EndCooldown()
            self:StartCooldown(self:GetCooldown(1))
            if (TalentTree:GetHeroTalentLevel(caster, 35) > 0) then
                local enemies = FindUnitsInRadius(caster:GetTeam(),
                        caster:GetAbsOrigin(),
                        nil,
                        300,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_ALL,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_ANY_ORDER,
                        false)
                local damage = Units:GetAttackDamage(caster) * 0.5
                for i, enemy in pairs(enemies) do
                    local damageTable = {}
                    damageTable.caster = caster
                    damageTable.target = enemy
                    damageTable.ability = self
                    damageTable.damage = damage
                    damageTable.infernodmg = true
                    GameMode:DamageUnit(damageTable)
                end
                local modifierTable = {}
                modifierTable.ability = self
                modifierTable.target = caster
                modifierTable.caster = caster
                modifierTable.modifier_name = "modifier_npc_dota_hero_abyssal_underlord_talent_35_scorched_immolation"
                modifierTable.duration = 5
                GameMode:ApplyBuff(modifierTable)
            end
        else
            if (caster.terror_lord_immolation.modifier ~= nil) then
                caster.terror_lord_immolation.modifier:Destroy()
                caster:StopSound("Hero_EmberSpirit.FlameGuard.Loop")
            end
        end
    end
end

-- terror_lord_inferno_impulse modifiers
modifier_terror_lord_inferno_impulse = modifier_terror_lord_inferno_impulse or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_TOOLTIP }
    end,
    GetTexture = function(self)
        return terror_lord_inferno_impulse:GetAbilityTextureName()
    end
})

function modifier_terror_lord_inferno_impulse:OnTooltip()
    return self:GetStackCount()
end

function modifier_terror_lord_inferno_impulse:OnTakeDamage(damageTable)
    if (damageTable.damage > 0) then
        local modifier = damageTable.victim:FindModifierByName("modifier_terror_lord_inferno_impulse")
        if (modifier) then
            local block = modifier:GetStackCount()
            if (damageTable.damage >= block) then
                damageTable.damage = damageTable.damage - block
                block = -1
            else
                block = block - damageTable.damage
                damageTable.damage = 0
            end
            if (block < 1) then
                modifier:Destroy()
            else
                modifier:SetStackCount(block)
            end
            return damageTable
        end
    end
end

LinkedModifiers["modifier_terror_lord_inferno_impulse"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_inferno_impulse_debuff = modifier_terror_lord_inferno_impulse_debuff or class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return terror_lord_inferno_impulse:GetAbilityTextureName()
    end
})

function modifier_terror_lord_inferno_impulse_debuff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.armor = self:GetAbility():GetSpecialValueFor("armor") * -0.01
end

function modifier_terror_lord_inferno_impulse_debuff:GetArmorPercentBonus()
    return self.armor
end

LinkedModifiers["modifier_terror_lord_inferno_impulse_debuff"] = LUA_MODIFIER_MOTION_NONE

-- terror_lord_inferno_impulse
terror_lord_inferno_impulse = class({
    GetAbilityTextureName = function(self)
        return "terror_lord_inferno_impulse"
    end
})

function terror_lord_inferno_impulse:OnSpellStart(unit, special_cast)
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local shield = caster:GetMaxHealth() * self:GetSpecialValueFor("absorb") / 100
    local radius = self:GetSpecialValueFor("radius")
    local enemies = FindUnitsInRadius(caster:GetTeam(),
            caster:GetAbsOrigin(),
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local bonus = (self:GetSpecialValueFor("absorb_bonus") / 100) + 1
    local armorDebuff = self:GetSpecialValueFor("armor")
    local duration = self:GetSpecialValueFor("armor_duration")
    caster:EmitSound("Hero_AbyssalUnderlord.Firestorm")
    for _, enemy in pairs(enemies) do
        shield = shield * bonus
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = enemy
        modifierTable.caster = caster
        modifierTable.modifier_name = "modifier_terror_lord_inferno_impulse_debuff"
        modifierTable.modifier_params = { armor = armorDebuff }
        modifierTable.duration = duration
        GameMode:ApplyDebuff(modifierTable)
    end
    shield = math.floor(shield)
    local modifierTable = {}
    modifierTable.ability = self
    modifierTable.target = caster
    modifierTable.caster = caster
    modifierTable.modifier_name = "modifier_terror_lord_inferno_impulse"
    modifierTable.duration = -1
    modifierTable.stacks = shield
    modifierTable.max_stacks = shield
    local modifier = GameMode:ApplyStackingBuff(modifierTable)
    modifier:SetStackCount(shield)
    local pidx = ParticleManager:CreateParticle("particles/units/terror_lord/infernal_impulse/infernal_impulse.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(pidx, 1, Vector(radius, 0, 0))
    Timers:CreateTimer(duration, function()
        ParticleManager:DestroyParticle(pidx, true)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
end
-- terror_lord_pit_of_seals modifiers
modifier_terror_lord_pit_of_seals_thinker_aura = modifier_terror_lord_pit_of_seals_thinker_aura or class({
    IsHidden = function(self)
        return true
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.radius or 0
    end,
    GetAuraSearchFlags = function(self)
        return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_ENEMY
    end,
    IsAura = function(self)
        return true
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_terror_lord_pit_of_seals_thinker_aura_debuff"
    end
})

function modifier_terror_lord_pit_of_seals_thinker_aura:OnDestroy()
    if (not IsServer()) then
        return
    end
    UTIL_Remove(self.parent)
end

function modifier_terror_lord_pit_of_seals_thinker_aura:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    local ability = self:GetAbility()
    self.parent = self:GetParent()
    self.caster = ability:GetCaster()
    self.position = self.parent:GetAbsOrigin()
    self.casterTeam = self.caster:GetTeam()
    self.parent.hero_ability = ability
    self.radius = keys.radius
    self.rootDelay = ability:GetSpecialValueFor("root_cd")
    self.rootDuration = ability:GetSpecialValueFor("root_duration")
    self.tick = ability:GetSpecialValueFor("tick")
    self:StartIntervalThink(self.tick)
    self:OnIntervalThink()
end

function modifier_terror_lord_pit_of_seals_thinker_aura:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local enemies = FindUnitsInRadius(self.casterTeam,
            self.parent:GetAbsOrigin(),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, enemy in pairs(enemies) do
        if (not enemy:HasModifier("modifier_terror_lord_pit_of_seals_root_cd")) then
            local modifierTable = {}
            modifierTable.ability = self.caster.hero_ability
            modifierTable.target = enemy
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_terror_lord_pit_of_seals_root"
            modifierTable.duration = self.rootDuration
            GameMode:ApplyDebuff(modifierTable)
            local modifierTable = {}
            modifierTable.ability = self.caster.hero_ability
            modifierTable.target = enemy
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_terror_lord_pit_of_seals_root_cd"
            modifierTable.duration = self.rootDelay
            GameMode:ApplyDebuff(modifierTable)
        end
    end
end

LinkedModifiers["modifier_terror_lord_pit_of_seals_thinker_aura"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_pit_of_seals_thinker_aura_debuff = modifier_terror_lord_pit_of_seals_thinker_aura_debuff or class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return terror_lord_pit_of_seals:GetAbilityTextureName()
    end
})

function modifier_terror_lord_pit_of_seals_thinker_aura_debuff:OnCreated()
    if (not IsServer()) then
        return
    end
    local auraOwner = self:GetAuraOwner()
    self.ability = auraOwner.hero_ability
    self.armor_reduction = self.ability:GetSpecialValueFor("armor") * -0.01
    self.elementarmor_reduction = self.ability:GetSpecialValueFor("elementalarmor") * -0.01
end

function modifier_terror_lord_pit_of_seals_thinker_aura_debuff:GetArmorPercentBonus()
    return self.armor_reduction or 0
end

function modifier_terror_lord_pit_of_seals_thinker_aura_debuff:GetFireProtectionBonus()
    return self.elementarmor_reduction or 0
end

function modifier_terror_lord_pit_of_seals_thinker_aura_debuff:GetFrostProtectionBonus()
    return self.elementarmor_reduction or 0
end

function modifier_terror_lord_pit_of_seals_thinker_aura_debuff:GetEarthProtectionBonus()
    return self.elementarmor_reduction or 0
end

function modifier_terror_lord_pit_of_seals_thinker_aura_debuff:GetVoidProtectionBonus()
    return self.elementarmor_reduction or 0
end

function modifier_terror_lord_pit_of_seals_thinker_aura_debuff:GetHolyProtectionBonus()
    return self.elementarmor_reduction or 0
end

function modifier_terror_lord_pit_of_seals_thinker_aura_debuff:GetNatureProtectionBonus()
    return self.elementarmor_reduction or 0
end

function modifier_terror_lord_pit_of_seals_thinker_aura_debuff:GetInfernoProtectionBonus()
    return self.elementarmor_reduction or 0
end

LinkedModifiers["modifier_terror_lord_pit_of_seals_thinker_aura_debuff"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_pit_of_seals_root = modifier_terror_lord_pit_of_seals_root or class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return terror_lord_pit_of_seals:GetAbilityTextureName()
    end,
    CheckState = function(self)
        return { MODIFIER_STATE_ROOTED }
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/heroes_underlord/abyssal_underlord_pitofmalice_stun.vpcf"
    end
})

LinkedModifiers["modifier_terror_lord_pit_of_seals_root"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_pit_of_seals_root_cd = modifier_terror_lord_pit_of_seals_root_cd or class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end
})

LinkedModifiers["modifier_terror_lord_pit_of_seals_root_cd"] = LUA_MODIFIER_MOTION_NONE

-- terror_lord_pit_of_seals
terror_lord_pit_of_seals = class({
    GetAbilityTextureName = function(self)
        return "terror_lord_pit_of_seals"
    end,
    GetAOERadius = function(self)
        return self:GetSpecialValueFor("radius")
    end
})

function terror_lord_pit_of_seals:OnSpellStart(unit, special_cast)
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    local targetPos = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor("radius")
    local thinker = CreateModifierThinker(
            caster,
            self,
            "modifier_terror_lord_pit_of_seals_thinker_aura",
            {
                duration = duration,
                radius = radius
            },
            targetPos,
            caster:GetTeamNumber(),
            false
    )
    caster:EmitSound("Hero_AbyssalUnderlord.PitOfMalice")
    local pidx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/underlord_pitofmalice.vpcf", PATTACH_ABSORIGIN, thinker)
    ParticleManager:SetParticleControl(pidx, 1, Vector(radius, 0, 0))
    ParticleManager:SetParticleControl(pidx, 2, Vector(duration, 0, 0))
    Timers:CreateTimer(duration, function()
        ParticleManager:DestroyParticle(pidx, false)
        ParticleManager:ReleaseParticleIndex(pidx)
    end)
    if (TalentTree:GetHeroTalentLevel(caster, 38) > 0) then
        local enemies = FindUnitsInRadius(caster:GetTeam(),
                targetPos,
                nil,
                200,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)
        local damage = Units:GetAttackDamage(caster) * 0.8
        for _, enemy in pairs(enemies) do
            local pidx3 = ParticleManager:CreateParticle("particles/units/terror_lord/malicious_flames/malicious_flames_impact.vpcf", PATTACH_ABSORIGIN, enemy)
            ParticleManager:SetParticleControl(pidx3, 0, enemy:GetAbsOrigin())
            Timers:CreateTimer(1.0, function()
                ParticleManager:DestroyParticle(pidx3, false)
                ParticleManager:ReleaseParticleIndex(pidx3)
            end)
            local damageTable = {}
            damageTable.caster = caster
            damageTable.target = enemy
            damageTable.ability = self
            damageTable.damage = damage
            damageTable.infernodmg = true
            GameMode:DamageUnit(damageTable)
        end
    end
end
-- terror_lord_aura_of_seals modifiers
modifier_terror_lord_aura_of_seals = modifier_terror_lord_aura_of_seals or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_terror_lord_aura_of_seals:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self.ability = self:GetAbility()
    self.enemy_aura = self.caster:AddNewModifier(self.caster, self.ability, "modifier_terror_lord_aura_of_seals_enemy_aura", { abilityentindex = self.ability:entindex(), duration = -1 })
    self:StartIntervalThink(1.0)
end

function modifier_terror_lord_aura_of_seals:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    if (TalentTree:GetHeroTalentLevel(self.caster, 39) > 0) then
        if (not self.ally_aura) then
            self.ally_aura = self.caster:AddNewModifier(self.caster, self.ability, "modifier_terror_lord_aura_of_seals_ally_aura", { abilityentindex = self.ability:entindex(), duration = -1 })
        end
    else
        if (self.ally_aura) then
            self.ally_aura:Destroy()
            self.ally_aura = nil
        end
    end
end

function modifier_terror_lord_aura_of_seals:OnDestroy()
    if (not IsServer()) then
        return
    end
    self.enemy_aura:Destroy()
    if (self.ally_aura) then
        self.ally_aura:Destroy()
    end
end

LinkedModifiers["modifier_terror_lord_aura_of_seals"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_aura_of_seals_ally_aura = modifier_terror_lord_aura_of_seals_ally_aura or class({
    IsHidden = function(self)
        return true
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.radius or 0
    end,
    GetAuraSearchFlags = function(self)
        return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_FRIENDLY
    end,
    IsAura = function(self)
        return true
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_terror_lord_aura_of_seals_ally_aura_buff"
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_terror_lord_aura_of_seals_ally_aura:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    if (not keys.abilityentindex) then
        self:Destroy()
        return
    end
    self.ability = EntIndexToHScript(keys.abilityentindex)
    self.radius = self.ability:GetSpecialValueFor("radius")
end

LinkedModifiers["modifier_terror_lord_aura_of_seals_ally_aura"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_aura_of_seals_ally_aura_buff = modifier_terror_lord_aura_of_seals_ally_aura_buff or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_abyssal_underlord/talent_39.png"
    end
})

function modifier_terror_lord_aura_of_seals_ally_aura_buff:OnCreated()
    if (not IsServer()) then
        return
    end
    self.aadamage = 0.15
    self.armor = 0.10
    self.spelldmg = 0.15
end

function modifier_terror_lord_aura_of_seals_ally_aura_buff:GetAttackDamagePercentBonus()
    return self.aadamage or 0
end

function modifier_terror_lord_aura_of_seals_ally_aura_buff:GetArmorPercentBonus()
    return self.armor or 0
end

function modifier_terror_lord_aura_of_seals_ally_aura_buff:GetSpellDamageBonus()
    return self.spelldmg or 0
end

LinkedModifiers["modifier_terror_lord_aura_of_seals_ally_aura_buff"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_aura_of_seals_enemy_aura = modifier_terror_lord_aura_of_seals_enemy_aura or class({
    IsHidden = function(self)
        return true
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.radius or 0
    end,
    GetAuraSearchFlags = function(self)
        return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_ENEMY
    end,
    IsAura = function(self)
        return true
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_terror_lord_aura_of_seals_enemy_aura_debuff"
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_terror_lord_aura_of_seals_enemy_aura:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    if (not keys.abilityentindex) then
        self:Destroy()
        return
    end
    self.ability = EntIndexToHScript(keys.abilityentindex)
    self.radius = self.ability:GetSpecialValueFor("radius")
end

LinkedModifiers["modifier_terror_lord_aura_of_seals_enemy_aura"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_aura_of_seals_enemy_aura_debuff = modifier_terror_lord_aura_of_seals_enemy_aura_debuff or class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end
})

function modifier_terror_lord_aura_of_seals_enemy_aura_debuff:OnCreated()
    if (not IsServer()) then
        return
    end
    local auraOwner = self:GetAuraOwner()
    self.ability = auraOwner:FindAbilityByName("terror_lord_aura_of_seals")
    self.aadamage = self.ability:GetSpecialValueFor("aadamage") * -0.01
    self.spelldamage = self.ability:GetSpecialValueFor("spelldamage") * -0.01
end

function modifier_terror_lord_aura_of_seals_enemy_aura_debuff:GetAttackDamagePercentBonus()
    return self.aadamage or 0
end

function modifier_terror_lord_aura_of_seals_enemy_aura_debuff:GetSpellDamageBonus()
    return self.spelldamage or 0
end

LinkedModifiers["modifier_terror_lord_aura_of_seals_enemy_aura_debuff"] = LUA_MODIFIER_MOTION_NONE

-- terror_lord_aura_of_seals
terror_lord_aura_of_seals = class({
    GetAbilityTextureName = function(self)
        return "terror_lord_aura_of_seals"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_terror_lord_aura_of_seals"
    end
})

function terror_lord_aura_of_seals:OnUpgrade()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local allyAura = caster:FindModifierByName("modifier_terror_lord_aura_of_seals_ally_aura")
    local enemyAura = caster:FindModifierByName("modifier_terror_lord_aura_of_seals_enemy_aura")
    local radius = self:GetSpecialValueFor("radius")
    if (allyAura) then
        allyAura.radius = radius
    end
    if (enemyAura) then
        enemyAura.radius = radius
    end
end

-- terror_lord_ruthless_predator modifiers
modifier_terror_lord_ruthless_predator_aura = modifier_terror_lord_ruthless_predator_aura or class({
    IsHidden = function(self)
        return true
    end,
    IsAuraActiveOnDeath = function(self)
        return false
    end,
    GetAuraRadius = function(self)
        return self.radius or 0
    end,
    GetAuraSearchFlags = function(self)
        return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    end,
    GetAuraSearchTeam = function(self)
        return DOTA_UNIT_TARGET_TEAM_ENEMY
    end,
    IsAura = function(self)
        return true
    end,
    GetAuraSearchType = function(self)
        return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    end,
    GetModifierAura = function(self)
        return "modifier_terror_lord_ruthless_predator_aura_debuff"
    end
})

function modifier_terror_lord_ruthless_predator_aura:onDestroy()
    if (not IsServer()) then
        return
    end
    if (self.reg_modifier) then
        self.reg_modifier:Destroy()
    end
end

function modifier_terror_lord_ruthless_predator_aura:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self.ability = self:GetAbility()
    local tick = self.ability:GetLevelSpecialValueFor("tick", 0)
    self:StartIntervalThink(tick)
end

function modifier_terror_lord_ruthless_predator_aura:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    if (not self.reg_modifier) then
        return
    end
    local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
            self.caster:GetAbsOrigin(),
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local stackCount = #enemies
    if (TalentTree:GetHeroTalentLevel(self.caster, 37) > 0) then
        stackCount = math.max(stackCount, 1)
    end
    self.reg_modifier:SetStackCount(stackCount)
end

LinkedModifiers["modifier_terror_lord_ruthless_predator_aura"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_ruthless_predator_aura_debuff = modifier_terror_lord_ruthless_predator_aura_debuff or class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return terror_lord_ruthless_predator:GetAbilityTextureName()
    end
})

function modifier_terror_lord_ruthless_predator_aura_debuff:OnCreated()
    if (not IsServer()) then
        return
    end
    local auraOwner = self:GetAuraOwner()
    self.ability = auraOwner:FindAbilityByName("terror_lord_ruthless_predator")
    self.ms_slow = self.ability:GetSpecialValueFor("ms_slow")
    self.regeneration_debuff = self.ability:GetSpecialValueFor("regeneration_debuff") * -0.01
end

function modifier_terror_lord_ruthless_predator_aura_debuff:GetMoveSpeedBonus()
    return -self.ms_slow
end

function modifier_terror_lord_ruthless_predator_aura_debuff:GetHealthRegenerationPercentBonus()
    return self.regeneration_debuff or 0
end

function modifier_terror_lord_ruthless_predator_aura_debuff:GetManaRegenerationPercentBonus()
    return self.regeneration_debuff or 0
end

LinkedModifiers["modifier_terror_lord_ruthless_predator_aura_debuff"] = LUA_MODIFIER_MOTION_NONE

modifier_terror_lord_ruthless_predator = modifier_terror_lord_ruthless_predator or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return terror_lord_ruthless_predator:GetAbilityTextureName()
    end
})

function modifier_terror_lord_ruthless_predator:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
end

function modifier_terror_lord_ruthless_predator:GetHealthRegenerationBonus()
    if (not IsServer()) then
        return
    end
    return math.min(self:GetStackCount() * self.regeration_bonus, self.regeneration_cap) * self.caster:GetMaxHealth()
end

LinkedModifiers["modifier_terror_lord_ruthless_predator"] = LUA_MODIFIER_MOTION_NONE

-- terror_lord_ruthless_predator
terror_lord_ruthless_predator = class({
    GetAbilityTextureName = function(self)
        return "terror_lord_ruthless_predator"
    end,
    GetIntrinsicModifierName = function(self)
        return "modifier_terror_lord_ruthless_predator_aura"
    end,
})

function terror_lord_ruthless_predator:OnUpgrade()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local modifier = caster:FindModifierByName(self:GetIntrinsicModifierName())
    modifier.radius = self:GetSpecialValueFor("radius")
    if (not modifier.reg_modifier) then
        modifier.reg_modifier = caster:AddNewModifier(caster, self, "modifier_terror_lord_ruthless_predator", { Duration = -1 })
    end
    modifier.reg_modifier.regeration_bonus = self:GetSpecialValueFor("regeneration_buff") / 100
    modifier.reg_modifier.regeneration_cap = self:GetSpecialValueFor("regeneration_cap_buff") / 100
end

-- modifier_npc_dota_hero_abyssal_underlord_talent_35_scorched_immolation (Scorched Immolation)]
modifier_npc_dota_hero_abyssal_underlord_talent_35_scorched_immolation = modifier_npc_dota_hero_abyssal_underlord_talent_35_scorched_immolation or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    GetTexture = function(self)
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_abyssal_underlord/talent_35.png"
    end
})

function modifier_npc_dota_hero_abyssal_underlord_talent_35_scorched_immolation:GetMoveSpeedPercentBonus()
    return 0.1
end

LinkedModifiers["modifier_npc_dota_hero_abyssal_underlord_talent_35_scorched_immolation"] = LUA_MODIFIER_MOTION_NONE

-- modifier_npc_dota_hero_abyssal_underlord_talent_36 (Hallow Berserker)]
modifier_npc_dota_hero_abyssal_underlord_talent_36 = modifier_npc_dota_hero_abyssal_underlord_talent_36 or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
    end
})

function modifier_npc_dota_hero_abyssal_underlord_talent_36:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
end

function modifier_npc_dota_hero_abyssal_underlord_talent_36:OnAbilityFullyCast(keys)
    if (not IsServer()) then
        return
    end
    if keys.unit == self.caster and keys.ability:GetName() == "terror_lord_inferno_impulse" then
        self.caster:AddNewModifier(self.caster, nil, "modifier_npc_dota_hero_abyssal_underlord_talent_36_hallow_berserker", { duration = 10 })
    end
end

LinkedModifiers["modifier_npc_dota_hero_abyssal_underlord_talent_36"] = LUA_MODIFIER_MOTION_NONE

modifier_npc_dota_hero_abyssal_underlord_talent_36_hallow_berserker = modifier_npc_dota_hero_abyssal_underlord_talent_36_hallow_berserker or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_npc_dota_hero_abyssal_underlord_talent_36_hallow_berserker:GetAttackSpeedBonus()
    return 50
end

function modifier_npc_dota_hero_abyssal_underlord_talent_36_hallow_berserker:GetPrimaryAttributePercentBonus()
    return 0.2
end

LinkedModifiers["modifier_npc_dota_hero_abyssal_underlord_talent_36_hallow_berserker"] = LUA_MODIFIER_MOTION_NONE

-- modifier_npc_dota_hero_abyssal_underlord_talent_40 (Impulse Sanity)
modifier_npc_dota_hero_abyssal_underlord_talent_40 = modifier_npc_dota_hero_abyssal_underlord_talent_40 or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_npc_dota_hero_abyssal_underlord_talent_40:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self.casterTeam = self.caster:GetTeam()
    self.modifier = self.caster:AddNewModifier(self.caster, nil, "modifier_npc_dota_hero_abyssal_underlord_talent_40_impulse_sanity", { Duration = -1 })
    self:StartIntervalThink(1.0)
end

function modifier_npc_dota_hero_abyssal_underlord_talent_40:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local enemies = FindUnitsInRadius(self.casterTeam,
            self.caster:GetAbsOrigin(),
            nil,
            800,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    self.modifier:SetStackCount(#enemies)
end

function modifier_npc_dota_hero_abyssal_underlord_talent_40:OnDestroy()
    if (not IsServer()) then
        return
    end
    self.modifier:Destroy()
end

LinkedModifiers["modifier_npc_dota_hero_abyssal_underlord_talent_40"] = LUA_MODIFIER_MOTION_NONE

modifier_npc_dota_hero_abyssal_underlord_talent_40_impulse_sanity = modifier_npc_dota_hero_abyssal_underlord_talent_40_impulse_sanity or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_abyssal_underlord/talent_40.png"
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_TOOLTIP }
    end
})

function modifier_npc_dota_hero_abyssal_underlord_talent_40_impulse_sanity:GetInfernoDamageBonus()
    return self:GetStackCount() * 0.02
end

function modifier_npc_dota_hero_abyssal_underlord_talent_40_impulse_sanity:GetFireDamageBonus()
    return self:GetStackCount() * 0.02
end

function modifier_npc_dota_hero_abyssal_underlord_talent_40_impulse_sanity:OnTooltip()
    return self:GetStackCount() * 2
end

LinkedModifiers["modifier_npc_dota_hero_abyssal_underlord_talent_40_impulse_sanity"] = LUA_MODIFIER_MOTION_NONE

-- modifier_npc_dota_hero_abyssal_underlord_talent_41 (Will of Fire)
modifier_npc_dota_hero_abyssal_underlord_talent_41 = modifier_npc_dota_hero_abyssal_underlord_talent_41 or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_npc_dota_hero_abyssal_underlord_talent_41:GetFireDamageBonus()
    return 0.2
end

function modifier_npc_dota_hero_abyssal_underlord_talent_41:OnTakeDamage(damageTable)
    if (damageTable.attacker:HasModifier("modifier_npc_dota_hero_abyssal_underlord_talent_41")) then
        damageTable.firedmg = true
        return damageTable
    end
end

LinkedModifiers["modifier_npc_dota_hero_abyssal_underlord_talent_41"] = LUA_MODIFIER_MOTION_NONE

-- modifier_npc_dota_hero_abyssal_underlord_talent_42 (Inferno Reserves)
modifier_npc_dota_hero_abyssal_underlord_talent_42 = modifier_npc_dota_hero_abyssal_underlord_talent_42 or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

---@param damageTable DAMAGE_TABLE
function modifier_npc_dota_hero_abyssal_underlord_talent_42:OnPostTakeDamage(damageTable)
    if (not damageTable.ability and damageTable.physdmg and not damageTable.attacker:HasModifier("modifier_npc_dota_hero_abyssal_underlord_talent_42_cd") and damageTable.attacker:HasModifier("modifier_npc_dota_hero_abyssal_underlord_talent_42")) then
        damageTable.attacker:AddNewModifier(damageTable.attacker, nil, "modifier_npc_dota_hero_abyssal_underlord_talent_42_cd", { Duration = 20 })
        local modifierTable = {}
        modifierTable.ability = nil
        modifierTable.target = damageTable.victim
        modifierTable.caster = damageTable.attacker
        modifierTable.modifier_name = "modifier_stunned"
        modifierTable.duration = 1
        GameMode:ApplyDebuff(modifierTable)
        local modifierTable = {}
        modifierTable.ability = nil
        modifierTable.target = damageTable.victim
        modifierTable.caster = damageTable.attacker
        modifierTable.modifier_name = "modifier_npc_dota_hero_abyssal_underlord_talent_42_inferno_reserves"
        modifierTable.duration = 5
        GameMode:ApplyDebuff(modifierTable)
    end
end

LinkedModifiers["modifier_npc_dota_hero_abyssal_underlord_talent_42"] = LUA_MODIFIER_MOTION_NONE

modifier_npc_dota_hero_abyssal_underlord_talent_42_inferno_reserves = modifier_npc_dota_hero_abyssal_underlord_talent_42_inferno_reserves or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_npc_dota_hero_abyssal_underlord_talent_42_inferno_reserves:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    self.caster = self:GetCaster()
    self.target = self:GetParent()
    self.damage = 1 / keys.Duration
    self:StartIntervalThink(1.0)
end

function modifier_npc_dota_hero_abyssal_underlord_talent_42_inferno_reserves:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local damageTable = {}
    damageTable.caster = self.caster
    damageTable.target = self.target
    damageTable.ability = nil
    damageTable.damage = self.damage * Units:GetAttackDamage(self.caster)
    damageTable.infernodmg = true
    GameMode:DamageUnit(damageTable)
end

LinkedModifiers["modifier_npc_dota_hero_abyssal_underlord_talent_42_inferno_reserves"] = LUA_MODIFIER_MOTION_NONE

modifier_npc_dota_hero_abyssal_underlord_talent_42_cd = modifier_npc_dota_hero_abyssal_underlord_talent_42_cd or class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_abyssal_underlord/talent_42.png"
    end
})

LinkedModifiers["modifier_npc_dota_hero_abyssal_underlord_talent_42_cd"] = LUA_MODIFIER_MOTION_NONE

-- modifier_npc_dota_hero_abyssal_underlord_talent_43_cd (Vengeance)
modifier_npc_dota_hero_abyssal_underlord_talent_43 = modifier_npc_dota_hero_abyssal_underlord_talent_43 or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_npc_dota_hero_abyssal_underlord_talent_43:OnPostTakeDamage(damageTable)
    if (damageTable.victim:HasModifier("modifier_npc_dota_hero_abyssal_underlord_talent_43")) then
        local casterHealth = damageTable.victim:GetHealth() / damageTable.victim:GetMaxHealth()
        if (casterHealth < 0.5) then
            local pidx = ParticleManager:CreateParticle("particles/units/terror_lord/talents/vengeance/vengeance.vpcf", PATTACH_ABSORIGIN, damageTable.victim)
            Timers:CreateTimer(2, function()
                ParticleManager:DestroyParticle(pidx, false)
                ParticleManager:ReleaseParticleIndex(pidx)
            end)
            damageTable.victim:AddNewModifier(damageTable.victim, nil, "modifier_npc_dota_hero_abyssal_underlord_talent_43_cd", { Duration = 60 })
            local enemies = FindUnitsInRadius(damageTable.victim:GetTeam(),
                    damageTable.victim:GetAbsOrigin(),
                    nil,
                    600,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
            for _, enemy in pairs(enemies) do
                local modifierTable = {}
                modifierTable.ability = nil
                modifierTable.target = enemy
                modifierTable.caster = damageTable.victim
                modifierTable.modifier_name = "modifier_npc_dota_hero_abyssal_underlord_talent_43_debuff"
                modifierTable.duration = 2
                GameMode:ApplyDebuff(modifierTable)
            end
        end
    end
end

LinkedModifiers["modifier_npc_dota_hero_abyssal_underlord_talent_43"] = LUA_MODIFIER_MOTION_NONE

modifier_npc_dota_hero_abyssal_underlord_talent_43_cd = modifier_npc_dota_hero_abyssal_underlord_talent_43_cd or class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_abyssal_underlord/talent_43.png"
    end
})

LinkedModifiers["modifier_npc_dota_hero_abyssal_underlord_talent_43_cd"] = LUA_MODIFIER_MOTION_NONE

modifier_npc_dota_hero_abyssal_underlord_talent_43_debuff = modifier_npc_dota_hero_abyssal_underlord_talent_43_debuff or class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return true
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_abyssal_underlord/talent_43.png"
    end,
    CheckState = function(self)
        return { MODIFIER_STATE_DISARMED }
    end,
    GetEffectName = function(self)
        return "particles/items2_fx/heavens_halberd_debuff.vpcf"
    end
})

LinkedModifiers["modifier_npc_dota_hero_abyssal_underlord_talent_43_debuff"] = LUA_MODIFIER_MOTION_NONE

-- modifier_npc_dota_hero_abyssal_underlord_talent_44 (Sticky Pit)
modifier_npc_dota_hero_abyssal_underlord_talent_44 = modifier_npc_dota_hero_abyssal_underlord_talent_44 or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
    end
})

function modifier_npc_dota_hero_abyssal_underlord_talent_44:OnCreated()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
end

function modifier_npc_dota_hero_abyssal_underlord_talent_44:OnAbilityFullyCast(keys)
    if (not IsServer()) then
        return
    end
    if keys.unit == self.caster and keys.ability:GetName() == "terror_lord_pit_of_seals" then
        CreateModifierThinker(
                self.caster,
                keys.ability,
                "modifier_npc_dota_hero_abyssal_underlord_talent_44_thinker",
                {
                    duration = keys.ability:GetSpecialValueFor("duration"),
                },
                keys.ability:GetCursorPosition(),
                self.caster:GetTeamNumber(),
                false
        )
    end
end

LinkedModifiers["modifier_npc_dota_hero_abyssal_underlord_talent_44"] = LUA_MODIFIER_MOTION_NONE

modifier_npc_dota_hero_abyssal_underlord_talent_44_thinker = modifier_npc_dota_hero_abyssal_underlord_talent_44_thinker or class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end
})

function modifier_npc_dota_hero_abyssal_underlord_talent_44_thinker:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.casterTeam = self.caster:GetTeam()
    self.radius = self.ability:GetSpecialValueFor("radius")
    self.parent = self:GetParent()
    self.position = self.parent:GetAbsOrigin()
    self:StartIntervalThink(1.0)
end

function modifier_npc_dota_hero_abyssal_underlord_talent_44_thinker:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local enemies = FindUnitsInRadius(self.casterTeam,
            self.position,
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, enemy in pairs(enemies) do
        local modifierTable = {}
        modifierTable.ability = nil
        modifierTable.target = enemy
        modifierTable.caster = self.caster
        modifierTable.modifier_name = "modifier_npc_dota_hero_abyssal_underlord_talent_44_sticky"
        modifierTable.stacks = 1
        modifierTable.max_stacks = 99999
        modifierTable.duration = 10
        GameMode:ApplyStackingDebuff(modifierTable)
    end
end

function modifier_npc_dota_hero_abyssal_underlord_talent_44_thinker:OnDestroy()
    if (not IsServer()) then
        return
    end
    UTIL_Remove(self.parent)
end

LinkedModifiers["modifier_npc_dota_hero_abyssal_underlord_talent_44_thinker"] = LUA_MODIFIER_MOTION_NONE

modifier_npc_dota_hero_abyssal_underlord_talent_44_sticky = modifier_npc_dota_hero_abyssal_underlord_talent_44_sticky or class({
    IsDebuff = function(self)
        return true
    end,
    IsHidden = function(self)
        return false
    end,
    IsPurgable = function(self)
        return true
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetTexture = function(self)
        return "file://{images}/custom_game/hud/talenttree/npc_dota_hero_abyssal_underlord/talent_44.png"
    end,
})

function modifier_npc_dota_hero_abyssal_underlord_talent_44_sticky:OnTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_npc_dota_hero_abyssal_underlord_talent_44_sticky")
    if (damageTable.damage > 0 and damageTable.attacker:HasModifier("modifier_npc_dota_hero_abyssal_underlord_talent_44") and modifier) then
        damageTable.damage = damageTable.damage * (1 + (modifier:GetStackCount() * 0.01))
        return damageTable
    end
end

function modifier_npc_dota_hero_abyssal_underlord_talent_44_sticky:GetMoveSpeedPercentBonus()
    return self:GetStackCount() * 0.01
end

LinkedModifiers["modifier_npc_dota_hero_abyssal_underlord_talent_44_sticky"] = LUA_MODIFIER_MOTION_NONE

-- Internal stuff
for LinkedModifier, MotionController in pairs(LinkedModifiers) do
    LinkLuaModifier(LinkedModifier, "talents/talents_terror_lord", MotionController)
end

if (IsServer()) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_terror_lord_inferno_impulse, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_abyssal_underlord_talent_41, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_abyssal_underlord_talent_42, 'OnPostTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_abyssal_underlord_talent_43, 'OnPostTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_npc_dota_hero_abyssal_underlord_talent_44_sticky, 'OnTakeDamage'))
end