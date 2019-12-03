IMAGE := ministryofjustice/access-elasticsearch
VERSION := demo-1

build: .built-image

.built-image: Gemfile* makefile bin/*
	docker build -t $(IMAGE) .

tag: build
	docker tag $(IMAGE) $(IMAGE):$(VERSION)

push: build
	make tag
	docker push $(IMAGE):$(VERSION)

pull:
	docker pull $(IMAGE):$(VERSION)
