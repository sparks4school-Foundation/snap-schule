-- Community site routes
-- =====================
--
-- Routes for all community website pages. We're in the process of starting to
-- transition the whole site to Lua.
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

local Users = package.loaded.Users
local Projects = package.loaded.Projects
local Remixes = package.loaded.Remixes
local Collections = package.loaded.Collections
local FlaggedProjects = package.loaded.FlaggedProjects
local csrf = require("lapis.csrf")
local assert_exists = require('validation').assert_exists
local db = package.loaded.db

local util = require("lib.util")
local materials = require('frontend.views.static.resources').materials
local material_types = require('frontend.views.static.resources').types

require 'controllers.user'
require 'controllers.project'
require 'controllers.collection'

require 'frontend.dialogs'

app:enable('etlua')

app.layout = require 'frontend.views.layout.application'

local static_pages = {
    'about', 'contact', 'credits', 'privacy'
    -- Disabled because this is out of date.
    -- 'requirements',
}

local user_forms = {}
-- Simple static pages that contain user interactions.
-- These pages should all have a CSRF token and not allow iframes.
-- The map is route/name to view location.
user_forms['login'] = 'sessions/login'
user_forms['forgot_password'] = 'sessions/forgot_password'
user_forms['forgot_username'] = 'sessions/forgot_username'
user_forms['change_password'] = 'sessions/change_password'
user_forms['change_email'] = 'users/change_email'
user_forms['sign_up'] = 'users/sign_up'
user_forms['delete_user'] = 'users/delete_user'

app:before_filter(function (self)
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

app:get('index', '/', capture_errors(cached(function (self)
    self.page = 'index'
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
        return { render = view_path }
    end)))
end

app:get('/puzzles', capture_errors(cached(function (self)
    self.page = 'puzzles'
    return { render = 'puzzles' }
end)))

app:get('/puzzle', capture_errors(cached(function (self)
    self.page = 'puzzle'
    return { render = 'puzzle' }
end)))

app:get('/class', capture_errors(cached(function (self)
    self.page = 'class'
    return { render = 'class' }
end)))

app:get('/user', capture_errors(cached(function (self)
    self.page = 'user'
    return { render = 'user' }
end)))

app:get('/teacher', capture_errors(cached(function (self)
    self.page = 'teacher'
    return { render = 'user' }
end)))
