# docker-lstu

## Projet Lstu

https://framagit.org/luc/lstu#tab-readme

## Compose

### `docker-compose.yml`

#### simple

    app:
      image: s7b4/lstu
      ports:
        - "8080:8080"

#### with memcached

	app:
	  build: .
	  links:
	    - cache
	  ports:
	    - "8080:8080"

	cache:
	  image: memcached:1.5
	  command: memcached -m 32