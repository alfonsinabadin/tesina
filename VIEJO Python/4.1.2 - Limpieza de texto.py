import pandas as pd
import math
import random
import re
from collections import Counter
import nltk
import nltk

# Limpieza de UNICODE ---------------------------------------------------------
text = "Amo la pizza 🍕! Vamos en 🚕 a buscar pizza?"

# Codificar el texto en formato UTF-8
encoded_text = text.encode("utf-8")

print(encoded_text)

# Distancia de leveinshtein ---------------------------------------------------

# Frecuencia de letras en español
frecuencia_letras = {
    'a': 631, 'r': 611, 'e': 584, 'o': 425, 'i': 379, 'n': 324, 'c': 309, 't': 282, 's': 239, 'l': 193,
    'd': 191, 'u': 180, 'm': 174, 'p': 173, 'g': 78, 'b': 68, 'v': 52, 'f': 46, 'h': 31, 'j': 27,
    'z': 25, 'q': 18, 'y': 15, 'ñ': 11, 'x': 11, 'k': 1, 'w': 1, 
    'á': 631/2, 'é': 586/2, 'í': 379/2, 'ú': 180/2, 'ó': 425/2
}

def obtener_costo(letra_origen, letra_destino=None, tipo_operacion="sustitucion"):
    frecuencia_origen = frecuencia_letras.get(letra_origen, 1)
    frecuencia_destino = frecuencia_letras.get(letra_destino, 1) if letra_destino else 1
    
    if tipo_operacion == "eliminacion":
        return math.log(1 + frecuencia_origen) / (1 + math.log(1 + frecuencia_origen))
    elif tipo_operacion == "insercion":
        return 1 / math.log(1 + frecuencia_origen)
    elif tipo_operacion == "sustitucion":
        if frecuencia_origen > frecuencia_destino:
            return math.log(1 + frecuencia_origen) - math.log(1 + frecuencia_destino) + 1
        else:
            return (math.log(1 + frecuencia_origen) - math.log(1 + frecuencia_destino)) / math.log(1 + frecuencia_destino) + 1
    elif tipo_operacion == "transposicion":
        return 0
    return 1

def distancia_levenshtein_ponderada(palabra1, palabra2):
    operaciones = 0
    costo_total = 0.0
    
    len_p1, len_p2 = len(palabra1), len(palabra2)
    
    if len_p1 > len_p2:
        for i in range(len_p1 - len_p2):
            letra_eliminada = palabra1[len_p2 + i]
            costo = obtener_costo(letra_eliminada, tipo_operacion="eliminacion")
            costo_total += costo
            operaciones += 1
    elif len_p1 < len_p2:
        for i in range(len_p2 - len_p1):
            letra_insertada = palabra2[len_p1 + i]
            costo = obtener_costo(letra_insertada, tipo_operacion="insercion")
            costo_total += costo
            operaciones += 1
    
    for i in range(min(len_p1, len_p2)):
        if palabra1[i] != palabra2[i]:
            if i < min(len_p1, len_p2) - 1 and palabra1[i] == palabra2[i+1] and palabra1[i+1] == palabra2[i]:
                costo_total += obtener_costo(palabra1[i], palabra1[i+1], tipo_operacion="transposicion")
                operaciones += 1
            else:
                costo = obtener_costo(palabra1[i], palabra2[i], tipo_operacion="sustitucion")
                costo_total += costo
                operaciones += 1
    
    return operaciones, costo_total

def obtener_sugerencias(palabra_erronea, diccionario, max_operaciones=3, umbral_distancia=3, top_n=5):
    opciones = [(palabra, distancia_levenshtein_ponderada(palabra_erronea, palabra)) for palabra in diccionario]
    opciones_filtradas = [(palabra, distancia) for palabra, distancia in opciones if distancia[1] <= umbral_distancia]
    opciones_filtradas.sort(key=lambda x: (x[1][0], x[1][1]))
    return opciones_filtradas[:top_n]

## Ejemplo 'burri' (Tabla 3)

# Diccionario de palabras simuladas
diccionario = {"burro", "buro", "burrito", "burros", "burra"}

# Calcular distancias de Levenshtein ponderadas para las correcciones posibles
distancias = {palabra: distancia_levenshtein_ponderada("burri", palabra) for palabra in diccionario}

# Mostrar las distancias calculadas
print("\nDistancias de Levenshtein ponderadas:")
for palabra, distancia in distancias.items():
    print(f"{palabra}: {distancia[0] + distancia[1]:.5f}")

## Ejemplo palabras Streaming (Tabla 4)

# Cargar diccionario
diccionario_espanol = set()
with open("diccionario_espanol.txt", "r", encoding="utf-8") as file:
    diccionario_espanol = {line.strip().lower() for line in file}
                           
palabras_erroneas = ["viedo", "programma", "buenasimo", "pq", "q"]

resultados_correcciones = []

# Evaluar cada palabra errónea y encontrar su mejor corrección
for palabra in palabras_erroneas:
    opciones_distancias = obtener_sugerencias(palabra, diccionario_espanol, max_operaciones=3)
    opciones = [opcion[0] for opcion in opciones_distancias]
    distancias = [opcion[1][1] for opcion in opciones_distancias]
    mejor_opcion = opciones[0] if opciones else "Sin sugerencias"
    mejor_distancia = distancias[0] if distancias else None
    resultados_correcciones.append([palabra, opciones, distancias, mejor_opcion])

# Crear DataFrame con las correcciones
correcciones_df = pd.DataFrame(resultados_correcciones, columns=["Palabra errónea", "Opciones", "Distancias", "Corrección elegida"])

# Mostrar la tabla con las cinco mejores opciones por palabra errónea
print(correcciones_df.to_string(index=False))

## Ejemplo comentarios simulados (Tabla 5)

# Agregar manualmente expresiones comunes en el español argentino
diccionario_espanol.update({
    "video", "pq", "q", "buenísimo", "lpm", "jajaja", "capo", "jaj", "onda", "chabon", "data", "loco",
    "grande", "asi", "tenes", "gracias", "che", "dale", "bue", "eh", "boludo", "posta", "ví", 'día', 'debería',
    "una","esto","tenes"
})

# Simular más comentarios de YouTube en contexto argentino (30 ejemplos)
comentarios_simulados = [
    "me encantooo este viedo",
    "el programa estubo buenisimo",
    "alta data loco, segui asi",
    "pq nadie habla de esto?",
    "jajaj q grande este chabon 😎",
    "no me lo esperaba jaj",
    "buenasimo el contenido",
    "grasia por compartir este video",
    "lo mejor q vi en anios",
    "que buena onda tenes capo",
    "esto es una locura",
    "tremendo contenido de verdad",
    "me mori de la risa 😂",
    "posta que no puedo creerlo",
    "capo total el tipo",
    "grande loco, gran trabajo",
    "de 10, muy bueno",
    "muy copado todo",
    "excelente resumen",
    "gracias por la info",
    "lo disfrute banda",
    "es una joya esto",
    "cada dia mejor",
    "no puedo mas jajaja",
    "mejor canal lejos",
    "la posta de la semana",
    "una masa total",
    "como me rei",
    "aguante este canal",
    "deberia tener mas vistas"
]

# Función para limpiar texto: quitar emojis, números y símbolos
def limpiar_texto(texto):
    texto = re.sub(r"\d+", "", texto)
    texto = re.sub(r"[^\w\s]", "", texto)
    texto = re.sub(r"\s+", " ", texto)
    return texto.strip().lower()

comentarios_limpios = [limpiar_texto(c) for c in comentarios_simulados]

# Tokenizar y contar palabras
palabras_comentarios = [palabra for comentario in comentarios_limpios for palabra in comentario.split()]
frecuencia_palabras = Counter(palabras_comentarios)

# Filtrar solo palabras correctas para agregar al diccionario
palabras_correctas = {p for p in palabras_comentarios if p in diccionario_espanol}
diccionario_extendido = diccionario_espanol.union(palabras_correctas)

# Frecuencia relativa
frecuencia_relativa = {palabra: freq / sum(frecuencia_palabras.values()) for palabra, freq in frecuencia_palabras.items()}

# Palabras erróneas (únicas y no en el diccionario)
errores_unicos = sorted(set([palabra for palabra in palabras_comentarios if palabra not in diccionario_espanol]))

def distancia_levenshtein_ponderada_con_frecuencia(palabra1, palabra2, frecuencia_relativa):
    operaciones = 0
    costo_total = 0.0
    len_p1, len_p2 = len(palabra1), len(palabra2)

    if len_p1 > len_p2:
        for i in range(len_p1 - len_p2):
            letra_eliminada = palabra1[len_p2 + i]
            costo = obtener_costo(letra_eliminada, tipo_operacion="eliminacion")
            costo_total += costo
            operaciones += 1
    elif len_p1 < len_p2:
        for i in range(len_p2 - len_p1):
            letra_insertada = palabra2[len_p1 + i]
            costo = obtener_costo(letra_insertada, tipo_operacion="insercion")
            costo_total += costo
            operaciones += 1

    for i in range(min(len_p1, len_p2)):
        if palabra1[i] != palabra2[i]:
            if i < min(len_p1, len_p2) - 1 and palabra1[i] == palabra2[i+1] and palabra1[i+1] == palabra2[i]:
                costo_total += obtener_costo(palabra1[i], palabra1[i+1], tipo_operacion="transposicion")
                operaciones += 1
            else:
                costo = obtener_costo(palabra1[i], palabra2[i], tipo_operacion="sustitucion")
                costo_total += costo
                operaciones += 1

    penalizacion = -0.5 if palabra2 in frecuencia_palabras else 0
    return operaciones, costo_total + penalizacion

# Evaluar errores únicos y mostrar comentarios corregidos
resultados = []
comentarios_corregidos = []

for comentario in comentarios_limpios:
    palabras = comentario.split()
    corregidas = []
    for palabra in palabras:
        if palabra in diccionario_espanol:
            corregidas.append(palabra)
        else:
            sugerencias = []
            for candidata in diccionario_espanol:
                freq_rel = frecuencia_relativa.get(candidata, 0)
                operaciones, distancia = distancia_levenshtein_ponderada_con_frecuencia(palabra, candidata, freq_rel)
                if operaciones <= 3 and distancia <= 3:
                    sugerencias.append((candidata, round(distancia, 4)))
            sugerencias.sort(key=lambda x: x[1])
            mejor = sugerencias[0][0] if sugerencias else palabra
            corregidas.append(mejor)
    comentarios_corregidos.append(" ".join(corregidas))

# Mostrar comparativo
for original, corregido in zip(comentarios_simulados, comentarios_corregidos):
    print(f"Original: {original}")
    print(f"Corregido: {corregido}\n")
    
# Eliminación de stoprwords ---------------------------------------------------

nltk.download('stopwords')

# Lista de stopwords en español
stopwords_es = set(stopwords.words('spanish'))

# Tokenizar los comentarios corregidos
tokens_antes = [palabra for comentario in comentarios_corregidos for palabra in comentario.split()]

# Eliminar stopwords
comentarios_sin_stopwords = []
for comentario in comentarios_corregidos:
    palabras = comentario.split()
    palabras_filtradas = [p for p in palabras if p not in stopwords_es]
    comentarios_sin_stopwords.append(" ".join(palabras_filtradas))

# Tokenizar después de eliminar stopwords
tokens_despues = [palabra for comentario in comentarios_sin_stopwords for palabra in comentario.split()]

# Top 5 palabras más frecuentes antes y después
top5_antes = Counter(tokens_antes).most_common(5)
top5_despues = Counter(tokens_despues).most_common(5)

# Mostrar resultados
print("Top 5 palabras más frecuentes antes de eliminar stopwords:")
for palabra, freq in top5_antes:
    print(f"{palabra}: {freq}")

print("\nTop 5 palabras más frecuentes después de eliminar stopwords:")
for palabra, freq in top5_despues:
    print(f"{palabra}: {freq}")