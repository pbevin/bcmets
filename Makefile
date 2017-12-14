run:
	docker-compose up --build

build:
	docker-compose build

push: build
	docker push pbevin/bcmets

live: push
	ssh docker "cd docker/bcmets && docker-compose pull && docker-compose up -d"
