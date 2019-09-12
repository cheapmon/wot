from representations.sequentialembedding import SequentialEmbedding

"""
Example showing how to load a series of historical embeddings and compute similarities over time.
Warning that loading all the embeddings into main memory can take a lot of RAM
"""

if __name__ == "__main__":
    fiction_embeddings = SequentialEmbedding.load("embeddings/eng-fiction-all_sgns", list(range(1840, 2000, 10)))
    time_sims = fiction_embeddings.get_time_sims("happy", "gay")
    for year, sim in time_sims.items():
        print("{year:d}, cosine similarity={sim:0.2f}".format(year=year,sim=sim))
