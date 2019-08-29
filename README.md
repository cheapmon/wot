wot
====

### Installation
1. Install [histwords dependencies](https://github.com/williamleif/histwords#dependencies) and [django](https://docs.djangoproject.com/en/2.2/topics/install/#installing-official-release)
1. Download [embeddings](https://nlp.stanford.edu/projects/histwords/) to `backend/embeddings`
1. Run django: `cd backend && python manage.py runserver`
1. Install the web app: `cd frontend && npm install`
1. Run the web app: `cd frontend && npm run serve`
1. Open browser to `localhost:8080`

### Todos
* Docker support