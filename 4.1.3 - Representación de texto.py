import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import TfidfVectorizer

# Corpus de ejemplo
corpus = [
    "el perro muerde",
    "el gato muerde",
    "el perro ladra",
    "el gato maúlla"
]

# Preprocesamiento básico: minúsculas y normalización de acentos
corpus = [oracion.lower().replace("á", "a").replace("ú", "u") for oracion in corpus]

# Vectorización BoW
vectorizador = CountVectorizer()
matriz_bow = vectorizador.fit_transform(corpus).toarray()

# Calcular similitud coseno
sim_coseno = cosine_similarity(matriz_bow)

# Visualizar
etiquetas = [f"D{i+1}" for i in range(len(corpus))]
plt.figure(figsize=(8, 6))
sns.heatmap(sim_coseno, xticklabels=etiquetas, yticklabels=etiquetas, annot=True,
            cmap=["#FCE2DE", "#FACDCA", "#F5CAC3", "#F28482"], cbar_kws={'label': 'Similitud coseno'})
plt.yticks(rotation=0)
plt.tight_layout()
plt.show()

# Mostrar vocabulario y vectores
print("Vocabulario:")
print(vectorizador.get_feature_names_out())
print("\nRepresentaciones BoW:")
for i, v in enumerate(matriz_bow):
    print(f"D{i+1}: {v}")

# Vectorización TF-IDF
vectorizador = TfidfVectorizer()
matriz_tfidf = vectorizador.fit_transform(corpus).toarray()

# Calcular similitud coseno
sim_coseno = cosine_similarity(matriz_tfidf)

# Visualizar
etiquetas = [f"D{i+1}" for i in range(len(corpus))]
plt.figure(figsize=(8, 6))
sns.heatmap(sim_coseno, xticklabels=etiquetas, yticklabels=etiquetas, annot=True,
            cmap=["#FCE2DE", "#FACDCA", "#F5CAC3", "#F28482"], cbar_kws={'label': 'Similitud coseno'})
plt.yticks(rotation=0)
plt.tight_layout()
plt.show()

# Mostrar vocabulario y vectores
print("Vocabulario:")
print(vectorizador.get_feature_names_out())
print("\nRepresentaciones TF-IDF:")
for i, v in enumerate(matriz_tfidf):
    print(f"D{i+1}: {v}")
