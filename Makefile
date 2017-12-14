run:
	docker-compose up --build

build:
	docker-compose build

push: build
	docker push pbevin/bcmets
