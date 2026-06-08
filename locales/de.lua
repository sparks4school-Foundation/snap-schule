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
	lang_name = 'Deutsch',
	lang_code = 'de',
	authors = 'Jadga Hügle, Jens Mönig',
	last_updated = '2026/05/29', -- YYYY/MM/DD

	-- Top navigation bar
	-- ==================
	-- Buttons
	b_join = 'Registrieren',
	b_login = 'Anmelden',
	b_logout = 'Abmelden',
	b_puzzles = 'Puzzle',
	b_contact = 'Kontakt',
	hi_user = 'Hallo @1!', -- @1 becomes the current user username


	-- Index page
	-- ==========
	index_intro = 'Programmierung im Unterricht – ohne Vorkenntnisse, ohne Aufwand. Snap! Schule bietet @1, die du direkt einsetzen kannst. Entwickelt von Lehrkräften, Informatiker:innen und Fachdidaktiker:innen – DSGVO-konform und kostenlos. Wir starten mit @2, weitere Bundesländer folgen!', -- @1 and @2 become the two sentences below:
	index_intro_p1 = 'lehrplangerechte Puzzle und Unterrichtsmaterialien',
	index_intro_p2 = 'Baden-Württemberg',
	text_coming_soon = "Wir arbeiten daran. Veröffentlichung am 01.09.2026",

	-- Puzzle carousels
	-- ================
	nth_grade_puzzles = 'Puzzle für die @1 Klassenstufe', -- @1 becomes a numeral, from below:
	nth_grade = '@1 Klassenstufe', -- @1 becomes a numeral, from below:
	nth_1 = '1.',
	nth_2 = '2.',
	nth_3 = '3.',
	nth_4 = '4.',
	nth_5 = '5.',
	nth_6 = '6.',
	nth_7 = '7.',
	nth_8 = '8.',
	nth_9 = '9.',
	nth_10 = '10.',
	nth_unknown = '?',
	b_grade_puzzles = 'Alle anzeigen', -- @1 becomes a number

	-- Puzzles Page
	-- ============
	title_puzzles = 'Puzzle',
	-- Dropdown filters
	dd_title_state = 'Bundesland',
	dd_all_states = 'Alle Bundesländer',
	dd_title_grade = 'Klassenstufe',
	dd_all_grades = 'Alle Klassenstufen',
	dd_grade_5 = 'Klassenstufe 5',
	dd_grade_6 = 'Klassenstufe 6',

	-- Puzzle Page
	-- ===========
	nth_puzzle = '@1 Puzzle', -- @1 becomes a numeral, from above (nth_1, nth2...)
	b_start_puzzle = 'Puzzle beginnen',
	b_share_qr = 'QR-Code teilen',
	title_share_puzzle = 'Puzzle teilen',
	b_add_to_grade = 'Zur Klassenstufe hinzufügen',
	title_concept_resources = 'Konzept und Materialien',
	title_links = 'Links',
	title_add_to_grade = 'Zur Klassenstufe hinzufügen',


	-- User Page
	-- =========
	title_student_account = 'Schüler:innen-Account',
	title_teacher_account = 'Lehrkräfte-Account',
	title_student_puzzles = 'Schüler:innen-Puzzle',
	title_teacher_puzzles = 'Lehrkräfte-Puzzle',

	title_students = 'Schüler:innen',

	title_create_accounts = 'Accounts anlegen',
	md_provide_csv =
[[Du erstellst für jede Schüler:in einen Benutzernamen und ein Passwort. Wichtig: Verwende keine echten Namen – denk dir stattdessen neutrale Benutzernamen aus (z. B. schueler3). So bleiben deine Schüler:innen auf der Plattform anonym. Damit du selbst weißt, welcher Account zu wem gehört, solltest du dir eine eigene Liste anlegen. 
Bitte gib die Benutzernamen und Passwörter als CSV an – das ist eine einfache Tabelle mit kommagetrennten Werten, die du z.B. in Excel oder LibreOffice erstellen und als „CSV" speichern oder einfach von Hand schreiben kannst. Die erste Zeile enthält die Überschriften `username` und `password`, darunter folgt pro Zeile ein Account.
**Beispiel:**]],
	title_upload_csv = 'CSV-Datei hochladen',
	text_paste_csv = 'Alternativ kannst du die Tabelle auch direkt hier hinein kopieren:',
	b_create_users = 'Account anlegen',
	title_bulk_creation = 'So legst du Accounts für deine Schüler:innen an',
	title_account = 'Account',
	title_update_details = 'Details aktualisieren',
	b_update_details = 'Details aktualisieren',
	text_automatic_account_deletion = 'Accounts werden automatisch ein Jahr nach ihrer letzten Aktivität gelöscht. Wir erheben und speichern keine personenbezogenen Daten.',
	title_delete_account = 'Account löschen',
	b_delete_account = 'Account löschen',
	title_change_password = 'Passwort ändern',
	placeholder_current_password = 'Aktuelles Passwort',
	placeholder_new_password = 'Neues Passwort',
	placeholder_new_password_repeat = 'Neues Passwort bestätigen',
	b_change_password = 'Passwort ändern',

	confirm_delete_usr = '',
	warning_no_return = 'WARNUNG! Diese Aktion kann nicht rückgängig gemacht werden!',

	-- Contact
	-- =======
	contact_heading = 'Hast du Fragen oder Feedback?@1Wir freuen uns, von dir zu hören.', -- @1 turns into a newline
	contact_text = 'Schreibe uns jederzeit gerne eine E-Mail – egal, ob du Hilfe benötigst, Vorschläge hast oder uns einfach deine Meinung mitteilen möchtest. Dein Feedback hilft uns, diese Website für Lehrkräfte und Schüler:innen besser zu machen.',
	b_contact_us = 'Schreib uns',

	-- Signup
	-- ======
	signup_title = 'Registrierung für Lehrkräfte',
	placeholder_email = 'E-Mail',
	placeholder_email_repeat = 'E-Mail (Wiederholung)',
	text_captcha = 'Bist du ein Roboter?@1Bitte gib die Zahlen ein!', -- @1 turns into a newline
	placeholder_captcha = 'Captcha eingeben',
	title_captcha_failed = 'Captcha fehlgeschlagen',
	b_signup = 'Registrieren',
	review_pending_header = 'Accounterstellung für Snap!Schule wird überprüft',
	review_pending_text = [[
**Vielen Dank für deine Anfrage eines kostenlosen Snap! Schule Accounts**

Wir prüfen deinen Antrag und werden uns in Kürze bei dir melden. 

Bitte überprüf regelmäßig deinen E-Mail-Posteingang, einschließlich des Spam-Ordners.

Solltest du innerhalb des nächsten Werktags keine Nachricht von uns erhalten, schreib uns bitte an __@1__.

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
	b_whysnap = 'Warum Snap!?',
	b_team = "Team",
	b_privacy = "Datenschutzerklärung",
	b_imprint = "Impressum",
	footer_credits_statement = 'snap.schule ist ein Projekt von UC&nbsp;Berkeley, SAP, SPARKS',

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
	email_accepted_text = 'Du kannst dich nun mit den folgenden Zugangsdaten in dein Konto unter @1 einloggen:',
	email_accepted_change_pwd = 'Bitte das Passwort beim ersten Einloggen ändern.',

	-- Modal window
	-- ============
	btn_ok = 'Ok',
	btn_cancel = 'Abbrechen',

	-- User admin
	-- ==========
	user_id = "",
	project_count = "",
	-- Buttons
	become = "", -- as an admin, temporarily impersonate this user
	verify = "",
	change_email = "",
	reset_password = "",
	get_reset_password_token = "",
	confirm_reset_password = "",
	change_username = "",
	new_username = "",
	send_msg = "",
	ban = "",
	unban = "",
	delete_usr = "",
	perma_delete_usr = "",
	revive_usr = "",
	confirm_revive = "",
	-- New email dialog
	new_email = "",
	-- Send message dialog
	compose_email = "",
	msg_subject = "",
	msg_body = "",
	profile_title = "", -- @1 becomes the user's username
	join_date = "", -- date of user creation follows
	delete_date = "", -- date of user deletion follows
	email = "",
	role = "",
	teacher = "",
	-- User roles
	student = "",
	standard = "",
	reviewer = "",
	moderator = "",
	admin = "",
	banned = "",
	-- Buttons
	change_my_password = "",
	change_my_email = "",
	delete_my_user = ""
}

return locale
