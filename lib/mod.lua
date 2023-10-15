local fx = require("fx/lib/fx")
local mod = require 'core/mods'
local music = require("musicutil")
local hook = require 'core/hook'
local tab = require 'tabutil'
-- Begin post-init hack block
if hook.script_post_init == nil and mod.hook.patched == nil then
    mod.hook.patched = true
    local old_register = mod.hook.register
    local post_init_hooks = {}
    mod.hook.register = function(h, name, f)
        if h == "script_post_init" then
            post_init_hooks[name] = f
        else
            old_register(h, name, f)
        end
    end
    mod.hook.register('script_pre_init', '!replace init for fake post init', function()
        local old_init = init
        init = function()
            old_init()
            for i, k in ipairs(tab.sort(post_init_hooks)) do
                local cb = post_init_hooks[k]
                print('calling: ', k)
                local ok, error = pcall(cb)
                if not ok then
                    print('hook: ' .. k .. ' failed, error: ' .. error)
                end
            end
        end
    end)
end
-- end post-init hack block


local FxGrains = fx:new {
    subpath = "/fx_grains"
}

function FxGrains:add_params()
    params:add_separator("fx_grains", "fx grains")
    FxGrains:add_slot("fx_grains_slot", "slot")
    FxGrains:add_control("fx_grains_transpose", "transpose", "transpose", controlspec.new(-25, 25, 'lin', 0, 0))
    FxGrains:add_control("fx_grains_pos", "pos", "pos", controlspec.new(0, 1, 'lin', 0, 0.5))
    FxGrains:add_control("fx_grains_size", "size", "size", controlspec.new(0, 1, 'lin', 0, 0.25))
    FxGrains:add_control("fx_grains_density", "density", "density", controlspec.new(0, 1, 'lin', 0, 0.4))
    FxGrains:add_control("fx_grains_texture", "texture", "texture", controlspec.new(0, 1, 'lin', 0, 0.5))
    FxGrains:add_control("fx_grains_spread", "spread", "spread", controlspec.new(0, 1, 'lin', 0, 0.5))
    FxGrains:add_control("fx_grains_reverb", "reverb", "reverb", controlspec.new(0, 1, 'lin', 0, 0))
    FxGrains:add_control("fx_grains_feedback", "feedback", "feedback", controlspec.new(0, 1, 'lin', 0, 0))
    FxGrains:add_control("fx_grains_freeze", "freeze", "freeze", controlspec.new(0, 1, 'lin', 1, 0))
    params:add_option("fx_grains_mode", "mode", {
        "granular",
        "stretch",
        "loop delay",
        "spectral",
    }, 1)
    params:set_action("fx_grains_mode", function(m)
        osc.send({ "localhost", 57120 }, self.subpath .. "/set", { "mode", m - 1 })
    end)
    FxGrains:add_control("fx_grains_lofi", "lofi", "lofi", controlspec.new(0, 1, 'lin', 1, 0))
    params:add_group("fx_grains_mod", "modulation", 13)
    FxGrains:add_taper("fx_grains_lfo_period", "lfo period", "lfoPeriod", 0.01, 10, 1, 2, 's')
    FxGrains:add_control("fx_grains_lfo_width", "lfo width", "lfoWidth", controlspec.new(0, 1, 'lin', 0, 0.5))
    FxGrains:add_taper("fx_grains_rand_period", "rand period", "randPeriod", 0.01, 10, 1, 2, 's')
    for _, things in pairs {
        {"lfoTranspose", "lfo to transpose"},
        {"lfoPos", "lfo to pos"},
        {"lfoSize", "lfo to size"},
        {"lfoDensity", "lfo to density"},
        {"lfoTexture", "lfo to texture"},
        {"randTranspose", "rand to transpose"},
        {"randPos", "rand to pos"},
        {"randSize", "rand to size"},
        {"randDensity", "rand to density"},
        {"randTexture", "rand to texture"}
    } do
        local key, text = things[1], things[2]
        FxGrains:add_taper("fx_grains_"..key, text, key, 0, 1, 0, 2)
    end
end

mod.hook.register("script_post_init", "fx grains mod post init", function()
    FxGrains:add_params()
end)

mod.hook.register("script_post_cleanup", "grains mod post cleanup", function()
end)

mod.hook.register("system_post_startup", "fx grains post startup", function()
    local has_mi = os.execute('test -n "$(find /home/we/.local/share/SuperCollider/Extensions/ -name MiPlaits.sc)"')
    if not has_mi then
        print("fx grains: installing mi-UGens")
        os.execute("wget --quiet https://github.com/schollz/oomph/releases/download/prereqs/mi-UGens.762548fd3d1fcf30e61a3176c1b764ec1cc82020.tar.gz -P /tmp/")
        os.execute("tar -xvzf /tmp/mi-UGens.762548fd3d1fcf30e61a3176c1b764ec1cc82020.tar.gz -C /home/we/.local/share/SuperCollider/Extensions/")
        os.execute("rm /tmp/mi-UGens.762548fd3d1fcf30e61a3176c1b764ec1cc82020.tar.gz")
        print("PLEASE RESTART")
    else
        print("fx grains found mi ugens")
    end
end)

return FxGrains
