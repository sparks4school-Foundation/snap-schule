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
--
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
local locale = package.loaded.locale
local capture_errors = package.loaded.capture_errors
local validate = package.loaded.validate
local assert_error = package.loaded.app_helpers.assert_error
local db = package.loaded.db

function utils:parse_notes(notes)
	local summary =
		string.sub(
			notes, string.find(notes, '--SUMMARY--') + 12,
			string.find(notes, '--DESCRIPTION--') - 2
		)
	local description =
		string.sub(
			notes, string.find(notes, '--DESCRIPTION--') + 16,
			string.find(notes, '--LINKS--') - 2
		)
	local links_text = string.sub(notes, string.find(notes, '--LINKS--') + 10)
	local links = {}
	for line in string.gmatch(links_text, "[^\r\n]+") do
		local link = {}
		for part, i in string.gmatch(line, "[^,]+") do
			table.insert(link, part)
		end
		table.insert(links, link)
	end

	return summary, description, links
end

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

function utils:assert_can_view_puzzle(user, puzzle)
	if (not puzzle.ispublished and not puzzle.ispublic
		and user.username ~= puzzle.username
		and not ((user ~= nil) and user:isadmin())
	) then
		yield_error(err.nonexistent_project)
	end
end

-- EMAILS

function utils:signup_email_body(email)
	local address = package.loaded.util.escape(email)
	local body =
		'<h2>' .. locale.get('email_signup_heading') .. '</h2>' ..
		'<p>' .. locale.get('email_signup_text') .. '</p>' ..
		'\n\n<strong>email</strong>: <em>' .. email .. '</em>\n\n' ..
		'<p><a href="https://snap.schule/accept_request/' ..  address ..
		'">' .. locale.get('email_signup_accept') ..
		'</a> <a href="https://snap.schule/reject_request/' .. address ..
		'">' .. locale.get('email_signup_reject') .. '</a></p>'
	return body
end

function utils:accepted_email_body(email, password)
	local address = package.loaded.util.escape(email)
	local body =
		'<h2>' .. locale.get('email_accepted_heading') .. '</h2><p>' ..
		locale.get(
			'email_signup_text',
			'<a href="https://snap.schule/login">snap.schule/login</a>'
		) ..
		'</p><br><p><strong>username</strong>: <em>' .. email .. '</em></p><br>' ..
		'</p><br><p><strong>password</strong>: <em>' .. password .. '</em></p><br>' ..
		'<br><br><p><strong>' .. locale.get('email_accepted_change_pwd') ..
		'</strong></p>'
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
		user.verified = true
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
