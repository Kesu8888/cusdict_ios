import pandas as pd
import nltk
from nltk.stem import WordNetLemmatizer
from nltk.corpus import wordnet

# Download required NLTK data
nltk.download('wordnet')
nltk.download('omw-1.4')

# Initialize lemmatizer
lemmatizer = WordNetLemmatizer()

# Load the CSV file
def process_file(input_path, output_path):
    try:
        # Read the CSV file
        df = pd.read_csv(input_path)

        # Function to update wordtype and objects
        def process_row(row):
            word = row['word'].strip()

            # Assume transitive verb as default
            row['wordtype'] = 'vt.'

            # Generate past tense and past participle
            past = lemmatizer.lemmatize(word, pos='v') + 'ed'  # Basic rule for past tense
            past_participle = past  # Same as past tense for most regular verbs
            row['objects'] = f'["{past}", "{past_participle}"]'
            return row

        # Apply processing
        df = df.apply(process_row, axis=1)

        # Save the updated file
        df.to_csv(output_path, index=False)
        print(f"Processing complete! File saved to: {output_path}")

    except Exception as e:
        print(f"An error occurred: {e}")

# Paths for input and output files
input_file = "cpt_spl/all_verbs.csv"  # Replace with your input file name
output_file = "processed_all_verbs.csv"  # Replace with your desired output file name

# Process the file
process_file(input_file, output_file)
