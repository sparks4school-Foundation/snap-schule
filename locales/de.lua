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
	lang_name = "Deutsch",
	lang_code = "de",
	authors = "Jadga Hügle",
	last_updated = "07/04/2026", -- YYYY/MM/DD

	-- Top navigation bar
	-- ==================
	-- Buttons
	b_join = "Registrieren",
	b_login = "Anmelden",
	b_logout = "Abmelden",
	b_puzzles = "Puzzle",
	b_contact = "Kontakt",
	hi_user = "Hallo @1!", -- @1 becomes the current user username


	-- Index page
	-- ==========
	index_intro = "Programmierung im Unterricht – ohne Vorkenntnisse, ohne Aufwand. Snap! Schule bietet @1, die Sie direkt einsetzen können. Entwickelt von Lehrkräften, Informatiker:innen und Fachdidaktiker:innen – DSGVO-konform und kostenlos. Wir starten mit @2, weitere Bundesländer folgen!", -- @1 and @2 become the two sentences below:
	index_intro_p1 = "lehrplangerechte Puzzle und Unterrichtsmaterialien",
	index_intro_p2 = "Baden-Württemberg",
	text_coming_soon = "Coming soon...",

	-- Puzzle carousels
	-- ================
	nth_grade_puzzles = "Puzzle für die @1 Klassenstufe", -- @1 becomes a numeral, from below:
	nth_grade = "@1 Klassenstufe", -- @1 becomes a numeral, from below:
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
	title_puzzles = "Puzzle",
	-- Dropdown filters
	dd_title_state = "Bundesland",
	dd_all_states = "Alle Bundesländer",
	dd_title_grade = "Klassenstufe",
	dd_all_grades = "Alle Klassenstufen",
	dd_grade_5 = "Klassenstufe 5",
	dd_grade_6 = "Klassenstufe 6",

	-- Puzzle Page
	-- ===========
	nth_puzzle = "@1 Puzzle", -- @1 becomes a numeral, from above (nth_1, nth2...)
	b_start_puzzle = "Puzzle beginnen",
	b_share_qr = "Share QR",
	b_add_to_grade = 'Zur Klassenstufe hinzufügen',
	title_concept_resources = "Konzept und Materialien",
	title_links = "Links",
	title_add_to_grade = 'Zur Klassenstufe hinzufügen',


	-- User Page
	-- =========
	title_student_account = "Schüler:innen-Account",
	title_teacher_account = "Lehrkräfte-Account",
	title_student_puzzles = "Schüler:innen-Puzzle",

	title_students = "Meine Schüler:innen",

	title_create_accounts = "Accounts erstellen",
	md_provide_csv =
[[Bitte geben Sie uns eine CSV-Datei mit Spalten für `Benutzername` und `Passwort` für alle ihre Schüler:innen.

Wenn Sie dazu eine nichtöffentliche Klasse erstellen, verknüpfen wir diese Accounts damit.

**Beispiel:**]],
	title_upload_csv = "die CSV-Datei hochladen",
	text_paste_csv = "Alternativ können Sie den Inhalt Ihrer CSV-Datei auch direkt hier hinein kopieren:",
	b_create_users = "Account anlegen",
	title_bulk_creation = "Mehrere Accounts erstellen",
	title_account = "Account",
	title_update_details = "Details aktualisieren",
	b_update_details = "Details aktualisieren",
	text_automatic_account_deletion = "Accounts werden automatisch ein Jahr nach ihrer letzten Aktivität gelöscht. Wir erheben und speichern keine personenbezogenen Daten.",
	title_delete_account = "Account löschen",
	b_delete_account = "Account löschen",
	title_change_password = 'Passwort ändern',
	placeholder_current_password = 'Aktuelles Passwort',
	placeholder_new_password = 'Neues Passwort',
	placeholder_new_password_repeat = 'Neues Passwort bestätigen',
	b_change_password = 'Passwort ändern',


	-- Contact
	-- =======
	contact_heading = "Haben Sie Fragen oder Feedback?@1Wir freuen uns, von Ihnen zu hören.", -- @1 turns into a newline
	contact_text = "Schreiben Sie uns jederzeit gerne eine E-Mail – egal, ob Sie Hilfe benötigen, Vorschläge haben oder uns einfach Ihre Meinung mitteilen möchten. Ihr Feedback hilft uns, diese Website für Lehrkräfte und Schüler:innen besser zu machen.",
	b_contact_us = "Kontaktieren Sie uns",

	-- Signup
	-- ======
	signup_title = 'Registrierung für Lehrkräfte',
	placeholder_email = 'E-Mail',
	placeholder_email_repeat = 'E-Mail (Wiederholung)',
	placeholder_captcha = 'Bitte geben Sie die angezeigten Ziffern ein',
	b_signup = 'Registrieren',
	review_pending_header = 'Benutzererstellung wird überprüft',
	review_pending_text = [[
**Vielen Dank für Ihre Anfrage**

Wir prüfen derzeit Ihren Antrag und werden uns in Kürze bei Ihnen melden – mit Details zum Zugriff auf Ihren Account.

Bitte überprüfen Sie regelmäßig Ihren E-Mail-Posteingang, einschließlich des Spam-Ordners.

Sollten Sie innerhalb des nächsten Werktags keine Nachricht von uns erhalten, schreiben Sie uns bitte an __@1__.

Vielen Dank!
]],

	-- Login
	-- =====
	login_title = 'Anmelden',
	placeholder_username = 'Benutzername',
	placeholder_password = 'Passwort',
	c_keep_logged_in = 'Eingeloggt bleiben',
	l_forgot_password = 'Ich habe mein Passwort vergessen',
	l_forgot_username = 'Ich habe meinen Benutzernamen vergessen',

	-- Password Reset
	-- ==============
	title_reset_password = 'Passwort zurücksetzen',
	button_reset_password = 'Mein Passwort zurücksetzen',

	-- Footer
	-- ======
	b_whysnap = "Warum Snap!?",
	footer_credits_statement = "snap.schule ist ein Projekt von UC&nbsp;Berkeley, SAP, SPARKS",

	-- Errors and messages
	-- ===================
	err_unauthorized = 'Du bist nicht berechtigt, diese Aktion auszuführen',
	err_captcha = 'Captcha wurde nicht korrekt eingegeben',
	title_user_created = '',
	msg_user_created = [[
	# Der Benutzer _@1_ wurde erstellt

	Es wurde eine E-Mail an den Benutzer gesendet, um ihn darüber zu informieren,
	dass er freigeschaltet wurde und sich nun bei Snap!Schule anmelden kann.
	]],
	title_user_rejected = 'Benutzerantrag abgelehnt',
	msg_user_rejected = [[
	# Antrag abgelehnt

	Der Registrierungsantrag des Benutzers mit der E-Mail-Adresse __@1__ wurde
	von Ihnen abgelehnt.

	Falls dies ein Versehen war, können Sie den Benutzer dennoch genehmigen,
	indem Sie auf den untenstehenden Link klicken. Andernfalls ist keine weitere
	Maßnahme erforderlich.
	]],

	-- Emails
	-- ======
	-- User account creation request. Sent to admin.
	email_signup_subject = '[Snap!Schule] Neue Signup Anfrage',
	email_signup_heading = 'User Signup Antrag',
	email_signup_text = 'Ein neuer User möchte Zugang zu Snap!Schule:',
	email_signup_accept = 'Bestätigen',
	email_signup_reject = 'Ablehnen',
	-- User account creation accepted. Sent to user.
	email_accepted_subject = '[Snap!Schule] Ihr Account wurde freigeschaltet',
	email_accepted_heading = 'Ihr Account für Snap!Schule wurde freigeschaltet',
	email_accepted_text = 'Sie können sich nun mit den folgenden Zugangsdaten in Ihr Konto unter @1 einloggen:',
	email_accepted_change_pwd = 'Bitte das Passwort beim ersten Einloggen ändern.'
}

return locale
