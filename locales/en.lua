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
	last_updated = "2026/03/26", -- YYYY/MM/DD

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

	-- Puzzle carousels
	-- ================
	nth_grade_puzzles = "@1 Grade Puzzles", -- @1 becomes a numeral, from below:
	nth_grade = "@1 Grade", -- @1 becomes a numeral, form below:
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
	b_grade_puzzles = "Grade @1 Puzzles", -- @1 becomes a number

	-- Puzzles Page
	-- ============
	-- Dropdown filters
	dd_title_state = "State",
	dd_all_states = "All States",
	dd_state = "State @1", -- @1 becomes the state number. Is this actually wanted in the final site?
	dd_title_grade = "Grade",
	dd_all_grades = "All Grades",
	dd_grade = "Grade @1", -- @1 becomes the grade number. Is this actually wanted in the final site?

	-- User Page
	-- =========
	title_student_puzzles = 'Student\'s Puzzles',

	-- Footer
	-- ======
	
	footer_credits_statement = 'snap.schule is brought to you by UC&nbsp;Berkeley, SAP, SPARKS',

}

return locale
