import sqlite3

# Connect to the database
conn = sqlite3.connect('words.db')
cursor = conn.cursor()

# Read the words from the file
with open('all_verbs_in_words.txt', 'r') as file:
    words = file.read().splitlines()

verbs_form = []
# Query the database for each word
for word in words:
    cursor.execute("SELECT wordtype FROM entries WHERE word = ?", (word,))
    wordtypes = cursor.fetchall()
    t = ''
    for tp in wordtypes:
        if tp == 'v.':
            t = 'v.'
            break
        elif tp == 'vi.':
            t = 'vi.'
            continue
        elif tp == 'vt.':
            t = 'vt.'
            continue
    if t != '':
        verbs_form.append(f"{word}+{t}\n")

# Write the verbs_form to a file
with open('verbs_form.txt', 'a') as file:
    for verb in verbs_form:
        file.write(verb)


# Close the connection
conn.close()