import pandas as pd
import string
from collections import Counter
import os

# Definir rutas relativas para reproducibilidad
base_dir = os.path.dirname(os.path.abspath(__file__))  # Obtener la ruta del script
file_path = os.path.join(base_dir, "Base Dic2024.xlsx")
output_path = os.path.join(base_dir, "top_20_palabras.xlsx")

# Cargar el archivo Excel
xls = pd.ExcelFile(file_path)

# Lista predefinida de stopwords en español
spanish_stopwords = set([
    "de", "la", "que", "el", "en", "y", "a", "los", "del", "se", "las", "por", "un", "para", "con", "no", "una", "su", "al", "lo", "como", "más", "pero", "sus", "le", "ya", 
    "o", "este", "sí", "porque", "esta", "entre", "cuando", "muy", "sin", "sobre", "también", "me", "hasta", "hay", "donde", "quien", "desde", "todo", "nos", "durante", "todos", "uno", 
    "les", "ni", "contra", "otros", "ese", "eso", "ante", "ellos", "e", "esto", "mí", "antes", "algunos", "qué", "unos", "yo", "otro", "otras", "otra", "él", "tanto", "esa", "estos", "mucho", 
    "quienes", "nada", "muchos", "cual", "poco", "ella", "estar", "estas", "algunas", "algo", "nosotros", "mi", "mis", "tú", "te", "ti", "tu", "tus", "ellas", "nosotras", "vosotros", "vosotras", "os", 
    "mío", "mía", "míos", "mías", "tuyo", "tuya", "tuyos", "tuyas", "suyo", "suya", "suyos", "suyas", "nuestro", "nuestra", "nuestros", "nuestras", "vuestro", "vuestra", "vuestros", "vuestras", "ese", "esos", "esa", "esas", 
    "esto", "estos", "estas", "aquel", "aquella", "aquellos", "aquellas", "suyas", "tuyas", "que"
])

# Función para limpiar y tokenizar comentarios
def clean_and_tokenize(text):
    text = text.lower().translate(str.maketrans('', '', string.punctuation))
    tokens = text.split()  # Tokenizar por espacios
    tokens = [word for word in tokens if word not in spanish_stopwords and word.isalpha()]  # Filtrar stopwords y no palabras
    return tokens

# Diccionario para almacenar el conteo de palabras de todas las hojas
total_word_counts = Counter()

# Diccionario para almacenar el conteo por hoja
word_counts_by_sheet = {}

# Procesar cada hoja
for sheet in xls.sheet_names:
    df = pd.read_excel(xls, sheet_name=sheet)
    if 'Comentarios' in df.columns:
        comments = ' '.join(df['Comentarios'].astype(str).str.replace('~*~', ' '))  # Unir comentarios
        tokens = clean_and_tokenize(comments)
        word_counts = Counter(tokens)
        
        # Almacenar conteo de palabras por hoja
        word_counts_by_sheet[sheet] = word_counts
        
        # Acumular conteo total
        total_word_counts.update(word_counts)

# Obtener el top 20 general
top_20_total = total_word_counts.most_common(20)

# Obtener el top 20 por hoja
top_20_by_sheet = {sheet: counts.most_common(20) for sheet, counts in word_counts_by_sheet.items()}

# Convertir resultados a DataFrame para visualización
df_total = pd.DataFrame(top_20_total, columns=["Palabra", "Frecuencia"])
df_by_sheet = {sheet: pd.DataFrame(counts, columns=["Palabra", "Frecuencia"]) for sheet, counts in top_20_by_sheet.items()}

# Exportar a Excel
with pd.ExcelWriter(output_path) as writer:
    df_total.to_excel(writer, sheet_name="General", index=False)
    for sheet, df in df_by_sheet.items():
        df.to_excel(writer, sheet_name=sheet, index=False)