-- Utility functions for the Snap!Schule modification of Snap!Cloud
-- ================================================================
--
-- A few functions that wouldn't fit in the generic Snap!Cloud software but are
-- needed for Snap!Schule.
--
-- Written by Bernat Romagosa
--
-- Copyright (C) 2026 by Bernat Romagosa
--
-- This file is part of Snap!Schule
---
-- Snap!Schule is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as
-- published by the Free Software Foundation, either version 3 of
-- the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local utils = {}

function utils:grade_from_collection(collection)
	if collection and (collection.name:find('Grade') > 0) then
		return tonumber(string.sub(collection.name, 6))
	else
		return 0
	end
end

function utils:grade_from_project(project)
	-- TRY TO FIND A COLLECTION CONTAINING THIS PROJECT
	local collections =
		CollectionController.containing_project({
			params = { project_id = project.id }
		})
	for _, collection in pairs(collections) do
		local grade = self:grade_from_collection(collection)
		if grade > 0 then
			return grade
		end
	end
	-- FIND OUT WHETHER THIS PROJECT IS A REMIX
	local remixed_from =
		package.loaded.Remixes:find({ remixed_project_id = project.id })
	if remixed_from then
		-- IF SO, FIND A GRADE COLLECTION IT MAY HAVE BELONGED TO
		local origin = package.loaded.Projects:find(
			{ id = remixed_from.original_project_id }
		)
		return self:grade_from_project(origin)
	end
	debug_print('PROJECT REMIXED FROM:', remixed_from or 'none')

	-- IF ALL ELSE FAILS, WE DON'T KNOW WHAT GRADE THIS PROJECT IS
	return 'unknown'
end

function utils:signup_email_body(email)
	local address = package.loaded.util.escape(email)
	local style = [[
<style>
* {
	font-family: Arial;
}
.button {
	padding: .1em .5em;
	border: 1px solid gray;
	border-radius: 5px;
	color: white;
	margin-right: .5em;
	text-decoration: none;
	font-weight: bold;
	&.accept { background: darkgreen; }
	&.reject { background: darkred; }
	&:hover {
		cursor: pointer;
		background: lightgray;
		color: black;
	}
}
</style>
]]

	local body = style ..
		'<h2>User signup application</h2>' ..
		'<p>A new user wants to be allowed into Snap!Schule:</p>' ..
		'\n\n<strong>email</strong>: <em>' .. address .. '</em>\n\n' ..
		'<p><a class="button accept" href="https://snap.schule/accept_request/' ..
		address .. '">Accept</a><a class="button reject" ' ..
		'href="https://snap.schule/reject_request/' .. address .. '">Reject</a></p>'
		

	return body
end

return utils
