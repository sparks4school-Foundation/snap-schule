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
	if collection and (collection.name:find('Grade')) then
		return tonumber(string.sub(collection.name, 6))
	else
		return 0
	end
end

function utils:collections_containing_project_with_id(id)
	return package.loaded.db.select(
		'collections.* FROM collections ' ..
			'JOIN collection_memberships ' ..
				'ON collections.id = collection_memberships.collection_id ' ..
			'WHERE collection_memberships.project_id = ?',
		id
	)
end

function utils:grade_from_project_id(id)
	-- TRY TO FIND A COLLECTION CONTAINING THIS PROJECT
	local collections = self:collections_containing_project_with_id(id)
	for _, collection in pairs(collections) do
		local grade = self:grade_from_collection(collection)
		if grade > 0 then
			return grade
		end
	end

	-- FIND OUT WHETHER THIS PROJECT IS A REMIX
	local remixed_from =
		package.loaded.Remixes:find({ remixed_project_id = id })
	if remixed_from then
		-- IF SO, FIND A GRADE COLLECTION IT MAY HAVE BELONGED TO
		local origin = package.loaded.Projects:find(
			{ id = remixed_from.original_project_id }
		)
		return self:grade_from_project(origin)
	end

	-- IF ALL ELSE FAILS, WE DON'T KNOW WHAT GRADE THIS PROJECT IS
	return 'unknown'
end

function utils:grade_from_project(project)
	return self:grade_from_project_id(project.id)
end

function utils:project_number(project)
		local result = package.loaded.db.select(
			'collection_memberships.*, row_number() ' ..
				'OVER (ORDER BY created_at) AS num ' ..
				'FROM collection_memberships WHERE collection_id IN ' ..
					'(SELECT collections.id from collections, collection_memberships ' ..
					'WHERE collection_memberships.collection_id = collections.id ' ..
					'AND collection_memberships.project_id = ?)',
			project.id
		)
		if result[1] then
			return result[1].num
		else
			return 0
		end
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
