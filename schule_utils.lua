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
local util = package.loaded.util
local capture_errors = package.loaded.capture_errors
local validate = package.loaded.validate
local assert_error = package.loaded.app_helpers.assert_error
local db = package.loaded.db

function utils:grade_from_collection(collection)
	if collection and (collection.name:find('Grade')) then
		return tonumber(string.sub(collection.name, 6))
	else
		return 0
	end
end

function utils:collections_containing_project_with_id(id)
	return db.select(
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
		local result = db.select(
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

utils.create_learners = capture_errors(function (self)
	-- For consistency, all users will be created or NONE will be created.
	assert_user_can_create_accounts(self)
	local collection = nil
	local users = self.params.users
	if not users then
		yield_error('Malformed JSON Provided.')
	end

	if #users > 50 then
		yield_error('Please limit bulk creation to 50 users.')
	end

	local usernames = {}
	for _, user in pairs(users) do
		-- Ensure necessary columns are present. (partial User validation.)
		validate.assert_valid(user, {
			{ 'username', exists = true, min_length = 4, max_length = 200 },
			{ 'password', exists = true, min_length = 6}
		})
		table.insert(usernames, util.trim(tostring(user.username):lower()))
	end

	-- Assert no users exist.
	local existing_users =
	package.loaded.AllUsers:find_all(usernames, 'username', { fields = 'username' })
	if #existing_users > 0 then
		usernames = {}
		local msg =
		'No user accounts created! ' ..
		#existing_users .. ' users already exist.<br>' ..
		'Please provide new usernames for the following users:<br><br>'
		for _, user in pairs(existing_users) do
			msg = msg .. user.username .. '<br>'
		end
		return errorResponse(self, msg, 400)
	end

	-- wrap all user creations in a transaction. No partial completions.
	db.query('BEGIN;')
	collection = package.loaded.Collections:find(self.current_user.id, 'students')
	if not collection then
		db.query('ROLLBACK;')
		return errorResponse(self, 'Could not find students collection.')
	end
	local salt, password, result
	for _, user in pairs(users) do
		salt = secure_salt()
		password = util.trim(tostring(user.password))
		user.created = db.format_date()
		user.username = util.trim(tostring(user.username):lower())
		user.salt = salt
		user.password = hash_password(hash_password(password, ''), salt)
		user.email = (user.email or self.current_user.email)
		user.verified = false
		user.role = 'student'
		user.creator_id = self.current_user.id
		result = package.loaded.Users:create(user)
		if not result then
			db.query('ROLLBACK;')
			return errorResponse(self,
			'User ' .. user.username .. ' errored on creation.'
			)
		end
		if collection then
			collection:update({
				editor_ids =
				db.raw(db.interpolate_query(
				'array_append(editor_ids, ?)',
				result.id))
			})
		end
	end
	assert_error(db.query('COMMIT;'))
	return jsonResponse({
		message = #usernames .. ' users created.',
		title = 'Users created',
		redirect = self:build_url('/user')
	})
end)

return utils
