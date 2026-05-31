-- How to translate
-- ----------------
-- Translate each text string to the target language leaving intact the two
-- double quotes.
-- Example: "Log In" should become "Entrar"
--
-- If you need to use a double quote, escape it with a backslash (\")
--
-- The "@" symbol followed by a number represents a parameter that the system
-- will substitute by a value, for example a username.
-- Example: "Welcome, @1!" will become "Welcome, Mary!" when Mary is logged in.
--
-- You need to leave "@" marks intact, but you can change their order in your
-- translation if your language requires so.

local locale = {
	-- Meta data
	-- =========
	lang_name = "English",
	lang_code = "en",
	authors = "Bernat Romagosa",
	last_updated = "2026/05/29", -- YYYY/MM/DD

	-- Top navigation bar
	-- ==================
	-- Buttons
	b_join = "Join",
	b_login = "Log In",
	b_logout = "Log Out",
	b_puzzles = "Puzzles",
	b_contact = "Contact",
	hi_user = "Hi, @1!", -- @1 becomes the current user username


	-- Index page
	-- ==========
	index_intro = "With short, engaging educational games, children can learn @1 on their own and quickly move on to creating their own motion programs and simple games. Along the way, @2 such as variables, loops, and conditional logic—building essential digital skills while having fun.", -- @1 and @2 become the two sentences below:
	index_intro_p1 = "the basics of programming",
	index_intro_p2 = "they naturally discover key concepts",
	text_coming_soon = "Coming soon...",

	-- Puzzle carousels
	-- ================
	nth_grade_puzzles = "@1 Grade Puzzles", -- @1 becomes a numeral, from below:
	nth_grade = "@1 Grade", -- @1 becomes a numeral, from below:
	nth_1 = "1st",
	nth_2 = "2nd",
	nth_3 = "3rd",
	nth_4 = "4th",
	nth_5 = "5th",
	nth_6 = "6th",
	nth_7 = "7th",
	nth_8 = "8th",
	nth_9 = "9th",
	nth_10 = "10th",
	nth_unknown = "unknown",
	b_grade_puzzles = "Grade @1 Puzzles", -- @1 becomes a number

	-- Puzzles Page
	-- ============
	title_puzzles = "Puzzles",
	-- Dropdown filters
	dd_title_state = "State",
	dd_all_states = "All States",
	dd_title_grade = "Grade",
	dd_all_grades = "All Grades",
	dd_grade_5 = "Grade 5",
	dd_grade_6 = "Grade 6",

	-- Puzzle Page
	-- ===========
	nth_puzzle = "@1 Puzzle", -- @1 becomes a numeral, from above (nth_1, nth2...)
	b_start_puzzle = 'Start puzzle',
	b_add_to_class = 'Add to grade',
	b_share_qr = 'Share QR',
	title_concept_resources = 'Concept and Resources',
	title_links = 'Links:',
	title_add_to_grade = 'Add to grade',


	-- User Page
	-- =========
	title_student_account = 'Student Account',
	title_teacher_account = 'Teacher Account',
	title_student_puzzles = 'Student\'s Puzzles',

	title_students = 'Students',

	title_create_accounts = 'Create Accounts',
	md_provide_csv =
[[Please, provide a CSV file with `username` and `password` columns for all your learners.

If you also create a private class, all these accounts will be associated to it.

**Example:**]],
	title_upload_csv = 'Upload the CSV File',
	text_paste_csv = 'Alternatively, paste the contents of a CSV file:',
	b_create_users = 'Create Users',
	title_bulk_creation = 'Bulk account creation',
	title_account = 'Account',
	title_update_details = 'Update details',
	b_update_details = 'Update details',
	text_automatic_account_deletion = 'Accounts are automatically deactivated after one year of inactivity. We do not collect or store any personal information.',
	title_delete_account = 'Delete Account',
	b_delete_account = 'Delete Account',
	title_change_password = 'Change my password',
	placeholder_current_password = 'current password',
	placeholder_new_password = 'new password',
	placeholder_new_password_repeat = 'new password (repeat)',
	b_change_password = 'Change my password',


	-- Contact
	-- =======
	contact_heading = 'Have questions or feedback?@1 We\'d love to hear from you.', -- @1 turns into a newline
	contact_text = 'Feel free to send us an email anytime—whether you need help, have suggestions, or just want to share your thoughts. Your input helps us make this website better for students like you.',
	b_contact_us = 'Contact Us',

	-- Signup
	-- ======
	signup_title = 'Sign up',
	placeholder_email = 'E-mail',
	placeholder_email_repeat = 'E-mail (Repeat)',
	text_captcha = 'Are you a robot?@1Please enter these numbers!', -- @1 turns into a newline
	placeholder_captcha = 'Enter the number above',
	title_captcha_failed = 'Captcha failed',
	b_signup = 'Sign up',
	review_pending_header = 'User creation pending review',
	review_pending_text = [[
	# Thank you for your request.

	We are now reviewing your application and we will get back to you very soon
	with details on how to access your account.

	Please regularly check your email inbox, including the spam folder.

	If you don't receive any news from us within the next working day, please
	write to us at @1.

	Thank you!
	]],

	-- Login
	-- =====
	login_title = 'Log in',
	placeholder_username = 'Username',
	placeholder_password = 'Password',
	c_keep_logged_in = 'Keep me logged in',
	l_forgot_password = 'I forgot my password',
	l_forgot_username = 'I forgot my username',

	-- Password Reset
	-- ==============
	title_reset_password = 'Reset Your Password',
	button_reset_password = 'Reset my password',

	-- Footer
	-- ======
	b_whysnap = "Why Snap!",
	b_team = "Team",
	b_privacy = "Privacy Policy",
	b_imprint = "Imprint",
	footer_credits_statement = 'snap.schule is brought to you by UC&nbsp;Berkeley, SAP, SPARKS',

	-- Errors and messages
	-- ===================
	err_unauthorized = 'You do not have permission to perform this action',
	err_captcha = 'Captcha challenge failed',
	title_user_created = 'User created',
	msg_user_created = [[
	# User _@1_ has been created

	An email has been sent to the user notifying them that they have been
	approved and can now log into Snap!Schule.
	]],
	title_user_rejected = 'User application rejected',
	msg_user_rejected = [[
	# Application rejected

	The registration application for the user with email __@1__ has been rejected
	by you.

	If this was a mistake you can still approve them by clicking on the link
	below. Otherwise, you're all set.
	]],

	-- Emails
	-- ======
	-- User account creation request. Sent to admin.
	email_signup_subject = '[Snap!Schule] New Signup Request',
	email_signup_heading = 'User signup application',
	email_signup_text = 'A new user wants to be allowed into Snap!Schule:',
	email_signup_accept = 'Accept',
	email_signup_reject = 'Reject',
	-- User account creation accepted. Sent to user.
	email_accepted_subject = '[Snap!Schule] Your account has been approved',
	email_accepted_heading = 'Your account has been approved into Snap!Schule',
	email_accepted_text = 'You can now log into your account at @1 with the following credentials:',
	email_accepted_change_pwd = 'Please change your password immediately after logging in.',

	-- Modal window
	-- ============
	btn_ok = 'Ok',
	btn_cancel = 'Cancel',

	-- User admin
	-- ==========
	user_id = "ID",
	project_count = "Project count",
	-- Buttons
	become = "Become", -- as an admin, temporarily impersonate this user
	verify = "Verify",
	change_email = "Change Email",
	reset_password = "Reset Password",
	get_reset_password_token = "Get Reset Password Token",
	confirm_reset_password = "Are you sure you want to reset user @1's password?",
	change_username = "Change Username",
	new_username = "New username for @1?",
	send_msg = "Send a Message",
	ban = "Ban",
	unban = "Unban",
	delete_usr = "Delete",
	perma_delete_usr = "Delete Permanently",
	revive_usr = "Revive",
	confirm_revive = "Are you sure you want to undelete user @1?",
	-- New email dialog
	new_email = "New email",
	-- Send message dialog
	compose_email = "Compose a message",
	msg_subject = "Subject",
	msg_body = "Email Body",
	profile_title = "@1's profile", -- @1 becomes the user's username
	join_date = "Joined", -- date of user creation follows
	delete_date = "Deleted", -- date of user deletion follows
	email = "Email",
	role = "Role",
	teacher = "Teacher",
	-- User roles
	student = "student",
	standard = "standard",
	reviewer = "reviewer",
	moderator = "moderator",
	admin = "admin",
	banned = "banned",
	-- Buttons
	change_my_password = "Change My Password",
	change_my_email = "Change My Email",
	delete_my_user = "Delete my Account"
}

	return locale
