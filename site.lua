-- Community site routes
-- =====================
--
-- Routes for all community website pages.
--
-- Written by Bernat Romagosa and Michael Ball
--
-- Copyright (C) 2021 by Bernat Romagosa and Michael Ball
--
-- This file is part of Snap Cloud.
--
-- Snap Cloud is free software: you can redistribute it and/or modify
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

local app = package.loaded.app
local capture_errors = package.loaded.capture_errors
local cached = package.loaded.cached
local respond_to = package.loaded.respond_to
local yield_error = package.loaded.yield_error

local Users = package.loaded.Users
local Projects = package.loaded.Projects
local Remixes = package.loaded.Remixes
local Collections = package.loaded.Collections
local FlaggedProjects = package.loaded.FlaggedProjects
local csrf = require('lapis.csrf')
local assert_exists = require('validation').assert_exists
local db = package.loaded.db

local util = require('lib.util')
local locale = package.loaded.locale

local schule_utils = require('frontend.schule_utils')

require 'controllers.user'
require 'controllers.project'
require 'controllers.collection'

require 'frontend.dialogs'

app:enable('etlua')

app.layout = require 'frontend.views.layout.application'

local static_pages = { 'why_snap', 'team' }

local user_forms = {}
-- Simple static pages that contain user interactions.
-- These pages should all have a CSRF token and not allow iframes.
-- The map is route/name to view location.
user_forms['login'] = 'sessions/login'
user_forms['forgot_password'] = 'sessions/forgot_password'
user_forms['forgot_username'] = 'sessions/forgot_username'
user_forms['change_password'] = 'sessions/change_password'
user_forms['change_email'] = 'users/change_email'
user_forms['delete_user'] = 'users/delete_user'

app:before_filter(function (self)
	ngx.var.cloud_loc =
		(ngx.var.host == 'localhost' and
			(ngx.var.scheme ..'://' .. ngx.var.host .. ':' .. ngx.var.server_port)
		or
			(ngx.var.scheme ..'://' .. ngx.var.host))

	self.jadga = Users:find({ username = 'jadga' })
	if not self.session.locale then
		self.session.locale = 'de'
		self:write({redirect_to = '/'})
	end

	self.schule_utils = schule_utils
	self.util = util

	self.cache_buster = util.cache_buster()
	-- A front-end method to prefer opening some links (the IDE, mostly) in the same window
	self.prefer_new_tab = false
	if self.current_user and self.session.presist_session ~= 'true' then
		self.prefer_new_tab = true
	end

	-- Store current page in the session so we can redirect to it after login.
	self.session.previous_page = self.session.previous_page or self.req.path

	-- TODO: Set the CSP header to allow only our own domains, or CORS domains.
	-- self.res.headers['Content-Security-Policy'] = "frame-src 'none'"
end)


-- INDEX --

app:get('index', '/', capture_errors(cached(function (self)
	return { render = 'index' }
end)))

for _, page in pairs(static_pages) do
	app:get('/' .. page, capture_errors(cached(function (self)
		return { render = 'static/' .. page }
	end)))
end

for route, view_path in pairs(user_forms) do
	app:get('/' .. route, capture_errors(cached(function (self)
		self.csrf_token = csrf.generate_token(self)
		self.res.headers['Content-Security-Policy'] = "frame-src 'none'"
		return { render = view_path, css_class = 'form' }
	end)))
end


-- PUZZLES --

app:get('/puzzles(/:id)', capture_errors(cached(function (self)
	if self.params.id then
		self.collection = package.loaded.Collections:find({ id = self.params.id })
		if not self.collection then yield_error(err.nonexistent_collection) end
		assert_can_view_collection(self, self.collection)
		self.puzzles = CollectionController.projects({
			params = {},
			items_per_page = 24, -- max 24 projects to query from DB.
			collection = self.collection,
			cached = false
		})
	else
		self.collection = { name = locale.get('dd_all_grades') }
		self.params.username = 'jadga'
		self.puzzles = ProjectController.user_projects(self)
	end
	return { render = 'puzzles' }
end)))

app:get('/puzzle/:id', capture_errors(cached(function (self)
	self.puzzle = package.loaded.Projects:find({ id = self.params.id })
	if not self.puzzle then yield_error(err.nonexistent_project) end
	assert_can_view_project(self, self.puzzle)
	return { render = 'puzzle' }
end)))

app:get('/qr/:url', capture_errors(cached(function (self)
	self.url = self.params.url
	return { render = 'partials.qr' }
end)))

app:get('/editor(/:id)', capture_errors(cached(function (self)
	if self.params.id then
		local collections =
			schule_utils:collections_containing_project_with_id(self.params.id)
		if collections[1] then
			self.collection =
				package.loaded.Collections:find({ id = collections[1].id })
			self.puzzles = CollectionController.projects({
				params = {},
				items_per_page = 24, -- max 24 projects to query from DB.
				collection = self.collection,
				cached = false
			})
		end
	end
	self.top_only = true -- do not show bottom layout (contact, footer, etc)
	return { render = 'editor' }
end)))


-- CLASSES --

app:get('/class/:id', capture_errors(cached(function (self)
	self.class = Collections:find({ id = self.params.id })
	assert_can_view_collection(self, self.class)
	return { render = 'class' }
end)))


-- USERS --

app:get('/user', capture_errors(cached(function (self)
	--for k, v in pairs(self.session) do debug_print(k) end
	if not self.current_user then return { redirect_to = '/' } end
	self.account_type = self.current_user.is_teacher and 'teacher' or 'student'
	if not self.current_user.is_teacher then
		self.my_puzzles = ProjectController.my_projects(self)
	end
	return { render = 'user' }
end)))


-- USER SIGN UP --

app:get('/sign_up', capture_errors(cached(function (self)
	self.csrf_token = csrf.generate_token(self)
	self.res.headers['Content-Security-Policy'] = "frame-src 'none'"
	local string = ''
	for i = 1, 5 do
		local num = math.random(9)
		string = string .. num
	end
	self.session.captcha = string
	return { render = 'users.sign_up', css_class = 'auth' }
end)))

app:get('/sign_up_result', capture_errors(function (self)
	local passed = (self.params.captcha == self.session.captcha)
	self.session.captcha = nil
	if passed then
		-- send email with details and accept/reject buttons
		send_mail(
			self.jadga.email,
			locale.get('email_signup_subject'),
			schule_utils:signup_email_body(self.params.email)
		)
		self.title = locale.get('review_pending_header')
		self.contents = locale.get(
			'review_pending_text',
			'[ium@sparks4school.org](mailto:ium@sparks4school.org)'
		)

		return { render = 'message' }
	else
		self.title = 'Captcha failed'
		self.contents = locale.get('err_captcha')
		return { render = 'message' }
	end
end))

app:get('/accept_request/:email', capture_errors(function (self)
	if self.current_user and self.current_user:isadmin() then
		local salt = secure_salt()
		local password, prehash = random_password()
		local user = Users:create({
			created = db.format_date(),
			username = self.params.email,
			salt = salt,
			password = hash_password(prehash, salt),
			email = self.params.email,
			is_teacher = true,
			verified = true,
			role = 'standard'
		})
		local students = Collections:create({
			created_at = db.format_date(),
			updated_at = db.format_date(),
			creator_id = user.id,
			name = 'students'
		})
		-- Notify user
		send_mail(
			self.params.email,
			locale.get('email_accepted_subject'),
			schule_utils:signup_email_body(self.params.email, password)
		)
		self.title = locale.get('title_user_created')
		self.contents = locale.get('msg_user_created', self.params.email)
		return { render = 'message' }
	else
		self.title = 'Error'
		self.contents = locale.get('err_unauthorized')
		return { render = 'message' }
	end
end))

app:get('/reject_request/:email', capture_errors(function (self)
	if self.current_user and self.current_user:isadmin() then
		--TODO Maybe notify user? Maybe just do nothing?
		self.title = locale.get('title_user_rejected')
		self.contents =
			locale.get('msg_user_rejected', self.params.email) ..
				'\n\n[Accept](/accept_request/' .. util.escape(self.params.email) .. ')'
		return { render = 'message' }
	else
		self.title = 'Error'
		self.contents = locale.get('err_unauthorized')
		return { render = 'message' }
	end
end))

app:match('/create_students', respond_to({
	POST = package.loaded.json_params(schule_utils.create_learners)
}))

app:get('/message_test', capture_errors(function (self)
	self.title = 'This is a message'
	self.contents = 'How about that, huh?'
	return { render = 'message' }
end))
