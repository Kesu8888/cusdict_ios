import sqlite3

conn = sqlite3.connect('words.db')
cursor = conn.cursor()

# Query to select records with wordtype = 'compar.'
cursor.execute("SELECT word FROM words_compar")
records = cursor.fetchall()

current_word = ''
r = 0

for record in records:
    print(record)

print(r)
# Commit and Close the connection
conn.close()