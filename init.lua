--[[
	Late extra impacts - Extra impacts for LATE
	(c) Pierre-Yves Rollo

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU Lesser General Public License as published
	by the Free Software Foundation, either version 2.1 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

late_extra_impacts = {}
late_extra_impacts.name = minetest.get_current_modname()
late_extra_impacts.path = minetest.get_modpath(late_extra_impacts.name)

--- illuminate
-- Depends:
--   wielded_light mod (https://github.com/minetest-mods/wielded_light.git)
-- Params:
--   1: Light level (0 - 14) default 0

local wielded_light_update_interval = 0.2 -- Value not exposed by wielded_light

if minetest.global_exists("wielded_light") then
	late.register_impact_type({'player', 'mob'}, 'illuminate', {
		vars = { timer = 0 },
		step = function(impact, dtime)
			impact.vars.timer = impact.vars.timer + dtime
			if impact.vars.timer > wielded_light_update_interval then
				impact.vars.timer = impact.vars.timer -
					wielded_light_update_interval

				local velocity, offset
				velocity = impact.target.get_player_velocity and
					impact.target:get_player_velocity() or
					impact.target.getvelocity and
					impact.target:getvelocity() or nil
				if velocity == nil then return end
				offset = { x=0, y=1, z=0 }

				local pos = vector.round(vector.add(
					vector.add(offset, impact.target:getpos()),
					vector.multiply(velocity, wielded_light_update_interval)))

				local lightlevel = 0
				for _, valint in pairs(late.get_valints(impact.params, 1)) do
					lightlevel = math.floor(math.max(lightlevel,
						(valint.intensity or 0) * (valint.value or 0)))
				end
				wielded_light.update_light(pos, lightlevel)
			end
		end,
	})
end
