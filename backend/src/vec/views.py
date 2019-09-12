from django.shortcuts import render
from django.http import JsonResponse

import sys
import numpy as np
import os

import histwords.viz.scripts.helpers as helpers

dirs = next(os.walk('../../embeddings/'))[1]
key2dir = {key: "../../embeddings/"+key for key in dirs}
embedding_name = next(iter(key2dir))
embedding = helpers.load_embeddings(key2dir[embedding_name])


def index(request):
    global embedding_name
    global embedding
    global key2dir
    word = request.GET.get("word", "__None__")
    new_embedding = request.GET.get("embedding", embedding_name)
    if embedding_name != new_embedding:
        embedding_name = new_embedding
        embedding = helpers.load_embeddings(key2dir[embedding_name])
    if word == "__None__":
        return JsonResponse({'vectors': []})
    else:
        try:
            return JsonResponse({'vectors': load_vectors(word, embedding)})
        except:
            return JsonResponse({'vectors': []})


def load_vectors(word, embedding):
    all_lookups = {}
    all_sims = {}

    _, lookups, _, sims = helpers.get_time_sims(embedding, word)
    all_lookups.update(lookups)
    all_sims.update(sims)

    words = list(all_lookups.keys())
    values = [all_lookups[word] for word in words]
    fitted = helpers.fit_tsne(values).tolist()

    result = []
    for i in range(len(words)-1):
        vec = {'x': fitted[i][0], 'y': fitted[i][1]}
        word, year = words[i].split("|")
        result.append({'word': word, 'pos': vec, 'year': year})

    return result
