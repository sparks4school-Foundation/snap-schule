-- How to translate
-- ----------------
-- Translate each text string to the target language leaving intact the two
-- double quotes.
-- Example: ""
--
-- If you need to use a double quote, escape it with a backslash (\")
--
-- The "" symbol followed by a number represents a parameter that the system
-- will substitute by a value, for example a username.
-- Example: "" when Mary is logged in.
--
-- You need to leave "" marks intact, but you can change their order in your
-- translation if your language requires so.

local locale = {
	-- Meta data
	-- =========
	lang_name = "Deutsch",
	lang_code = "de",
	authors = "Jadga Hügle",
	last_updated = "07/04/2026", -- YYYY/MM/DD

	-- Top navigation bar
	-- ==================
	-- Buttons
	b_join = "Registrieren",
	b_login = "Anmelden",
	b_logout = "",
	b_puzzles = "Rätsel",
	b_contact = "Kontakt",
	hi_user = "Hallo @1!", -- @1 becomes the current user username


	-- Index page
	-- ==========
	index_intro = "Programmierung im Unterricht – ohne Vorkenntnisse, ohne Aufwand. Snap! Schule bietet @1, die Sie direkt einsetzen können. Entwickelt von Lehrkräften, Informatiker*innen und Fachdidaktiker*innen – DSGVO-konform und kostenlos. Wir starten mit @2, weitere Bundesländer folgen!", -- @1 and @2 become the two sentences below:
	index_intro_p1 = "lehrplangerechte Rätsel und Unterrichtsmaterialien",
	index_intro_p2 = "Baden-Württemberg",

	-- Puzzle carousels
	-- ================
	nth_grade_puzzles = "Rätsel für die @1 Klassenstufe", -- @1 becomes a numeral, from below:
	nth_grade = "@1 Klassenstufe", -- @1 becomes a numeral, form below:
	nth_1 = "1.",
	nth_2 = "2.",
	nth_3 = "3.",
	nth_4 = "4.",
	nth_5 = "5.",
	nth_6 = "6.",
	nth_7 = "7.",
	nth_8 = "8.",
	nth_9 = "9.",
	nth_10 = "10.",
	nth_unknown = "?",
	b_grade_puzzles = "Alle für Klassenstufe @1", -- @1 becomes a number

	-- Puzzles Page
	-- ============
	-- Dropdown filters
	dd_title_state = "Bundesland",
	dd_all_states = "",
	dd_state_1 = "",
	dd_title_grade = "Klassenstufe",
	dd_all_grades = "",
	dd_grade_5 = "Klassenstufe 5",
	dd_grade_6 = "Klassenstufe 6",

	-- Puzzle Page
	-- ===========
	b_start_puzzle = "Rätsel beginnen",
	b_share_qr = "Rätsel beginnen",
	title_concept_resources = "Konzept und  Materialien",
	title_links = "Links",

	-- User Page
	-- =========
	title_student_account = "",
	title_teacher_account = "",
	title_student_puzzles = "",

	-- Contact
	-- =======
	contact_heading = "Haben Sie Fragen oder Feedback?@1Wir freuen uns, von Ihnen zu hören.", -- @1 turns into a newline
	contact_text = "Schreiben Sie uns jederzeit gerne eine E-Mail – egal, ob Sie Hilfe benötigen, Vorschläge haben oder uns einfach Ihre Meinung mitteilen möchten. Ihr Feedback hilft uns, diese Website für Lehrkräfte und Schüler*innen besser zu machen.",
	b_contact_us = "Kontaktieren Sie uns",

	-- Signup
	-- ======
	signup_title = 'Registrierung für Lehrkräfte',
	placeholder_email = 'E-Mail',
	placeholder_email_repeat = 'E-Mail (Wiederholung)',
	placeholder_captcha = 'Bitte gib die angezeigten Ziffern ein',
	b_signup = 'Registrieren',


	-- Footer
	-- ======
	footer_credits_statement = "snap.schule ist ein Projekt von UC&nbsp;Berkeley, SAP, SPARKS",

	-- Errors and messages
	-- ===================
	err_unauthorized = 'Du bist nicht berechtigt, diese Aktion auszuführen',
	err_captcha = 'Captcha challenge failed',
	msg_user_created = 'User @1 has been created. Password is @2'
}

return locale
