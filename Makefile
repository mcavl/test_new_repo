.DEFAULT_GOAL: build

build:
	DOCKER_BUILDKIT=1 docker build --tag clinic_app .

run-test:
	docker compose run clinic_app bundle exec rspec --format documentation
