PHP_VERSION=8.3
PIMCORE_DOCKER=2024.4.1
ARCHS=linux/arm64,linux/amd64
GITHUBTOKEN=bgpid

#################################
# do not use multiarch builders #
#################################

###
# pimcore-php image calls
###
do-create-php-gz-file:
	./scripts/taskfile.sh create_gz_file \
		docker/pimcore-php \
		files-00 \
		files.tar.gz

do-build-php-arch-arm:
	./scripts/taskfile.sh build_docker_image \
		--load \
		pimcore-php-default \
		bgpid/pimcore-php:$(PHP_VERSION) \
		pimcore-php \
		bgpid/pimcore-php:latest \
		bgpid \
		linux/arm64

do-build-php-arch-amd:
	./scripts/taskfile.sh build_docker_image \
		--load \
		pimcore-php-default \
		bgpid/pimcore-php:$(PHP_VERSION) \
		pimcore-php \
		bgpid/pimcore-php:latest \
		bgpid \
		linux/amd64

do-rm-php-gz-file:
	./scripts/taskfile.sh remove_gz_file \
		docker/pimcore-php/files.tar.gz

###
# pimcore image calls
###
do-create-pimcore-gz-file:
	./scripts/taskfile.sh create_gz_file \
		docker/pimcore \
		files-00 \
		files.tar.gz

do-build-pimcore-arch-arm:
	./scripts/taskfile.sh build_docker_image \
		--load \
		pimcore-php-installed \
		bgpid/pimcore:$(PIMCORE_DOCKER) \
		pimcore \
		bgpid/pimcore:latest \
		bgpid \
		linux/arm64

do-build-pimcore-arch-amd:
	./scripts/taskfile.sh build_docker_image \
		--load \
		pimcore-php-installed \
		bgpid/pimcore:$(PIMCORE_DOCKER) \
		pimcore \
		bgpid/pimcore:latest \
		bgpid \
		linux/amd64

do-rm-pimcore-gz-file:
	./scripts/taskfile.sh remove_gz_file \
		docker/pimcore/files.tar.gz


###
# pimcore-debug image calls
###
do-build-pimcore-debug-arch-arm:
	./scripts/taskfile.sh build_docker_image \
		--load \
		pimcore-php-debug \
		bgpid/pimcore-debug:$(PIMCORE_DOCKER) \
		pimcore \
		bgpid/pimcore-debug:latest \
		bgpid \
		linux/arm64

do-build-pimcore-debug-arch-amd:
	./scripts/taskfile.sh build_docker_image \
		--load \
		pimcore-php-debug \
		bgpid/pimcore-debug:$(PIMCORE_DOCKER) \
		pimcore \
		bgpid/pimcore-debug:latest \
		bgpid \
		linux/amd64

###
# pimcore-supervisord image calls
###
do-build-pimcore-supervisord-arch-arm:
	./scripts/taskfile.sh build_docker_image \
		--load \
		pimcore-php-supervisord \
		bgpid/pimcore-supervisord:$(PIMCORE_DOCKER) \
		pimcore \
		bgpid/pimcore-supervisord:latest \
		bgpid \
		linux/arm64

do-build-pimcore-supervisord-arch-amd:
	./scripts/taskfile.sh build_docker_image \
		--load \
		pimcore-php-supervisord \
		bgpid/pimcore-supervisord:$(PIMCORE_DOCKER) \
		pimcore \
		bgpid/pimcore-supervisord:latest \
		bgpid \
		linux/amd64


build-php-arch: do-create-php-gz-file do-build-php-arch-arm do-rm-php-gz-file

build-php-amd: do-create-php-gz-file do-build-php-arch-amd do-rm-php-gz-file

build-php-archs: do-create-php-gz-file do-build-php-arch-arm do-build-php-arch-amd do-rm-php-gz-file

build-pimcore-arch: do-create-pimcore-gz-file do-build-pimcore-arch-arm  do-build-pimcore-debug-arch-arm do-build-pimcore-supervisord-arch-arm do-rm-pimcore-gz-file

build-pimcore-amd: do-create-pimcore-gz-file do-build-pimcore-arch-amd do-build-pimcore-supervisord-arch-amd do-rm-pimcore-gz-file

build-pimcore-archs: do-create-pimcore-gz-file do-build-pimcore-arch-arm do-build-pimcore-debug-arch-arm do-build-pimcore-supervisord-arch-arm do-build-pimcore-arch-amd do-build-pimcore-debug-arch-amd do-build-pimcore-supervisord-arch-amd do-rm-pimcore-gz-file

build-pimcore-no-debug-archs: do-create-pimcore-gz-file do-build-pimcore-arch-arm do-build-pimcore-supervisord-arch-arm do-build-pimcore-arch-amd do-build-pimcore-supervisord-arch-amd do-rm-pimcore-gz-file

push-php-arch:
	docker push docker.io/bgpid/pimcore-php:$(PHP_VERSION)-arm64

push-php-archs:
	docker push docker.io/bgpid/pimcore-php:$(PHP_VERSION)-arm64
	docker push docker.io/bgpid/pimcore-php:$(PHP_VERSION)-amd64
	docker manifest create bgpid/pimcore-php:$(PHP_VERSION) \
		--amend bgpid/pimcore-php:$(PHP_VERSION)-amd64 \
		--amend bgpid/pimcore-php:$(PHP_VERSION)-arm64
	docker manifest push bgpid/pimcore-php:$(PHP_VERSION)
	docker manifest create bgpid/pimcore-php:latest \
		--amend bgpid/pimcore-php:$(PHP_VERSION)-amd64 \
		--amend bgpid/pimcore-php:$(PHP_VERSION)-arm64
	docker manifest push bgpid/pimcore-php:latest

push-pimcore-arch:
	docker push docker.io/bgpid/pimcore:$(PIMCORE_DOCKER)-arm64
	docker push docker.io/bgpid/pimcore-debug:$(PIMCORE_DOCKER)-arm64
	docker push docker.io/bgpid/pimcore-supervisord:$(PIMCORE_DOCKER)-arm64

push-pimcore-archs:
	docker push docker.io/bgpid/pimcore:$(PIMCORE_DOCKER)-arm64
	docker push docker.io/bgpid/pimcore:$(PIMCORE_DOCKER)-amd64
	docker manifest create bgpid/pimcore:$(PIMCORE_DOCKER) \
		--amend bgpid/pimcore:$(PIMCORE_DOCKER)-amd64 \
		--amend bgpid/pimcore:$(PIMCORE_DOCKER)-arm64
	docker manifest push bgpid/pimcore:$(PIMCORE_DOCKER)
	docker push docker.io/bgpid/pimcore-debug:$(PIMCORE_DOCKER)-arm64
	docker push docker.io/bgpid/pimcore-debug:$(PIMCORE_DOCKER)-amd64
	docker manifest create bgpid/pimcore-debug:$(PIMCORE_DOCKER) \
		--amend bgpid/pimcore-debug:$(PIMCORE_DOCKER)-amd64 \
		--amend bgpid/pimcore-debug:$(PIMCORE_DOCKER)-arm64
	docker manifest push bgpid/pimcore-debug:$(PIMCORE_DOCKER)
	docker push docker.io/bgpid/pimcore-supervisord:$(PIMCORE_DOCKER)-arm64
	docker push docker.io/bgpid/pimcore-supervisord:$(PIMCORE_DOCKER)-amd64
	docker manifest create bgpid/pimcore-supervisord:$(PIMCORE_DOCKER) \
		--amend bgpid/pimcore-supervisord:$(PIMCORE_DOCKER)-amd64 \
		--amend bgpid/pimcore-supervisord:$(PIMCORE_DOCKER)-arm64
	docker manifest push bgpid/pimcore-supervisord:$(PIMCORE_DOCKER)
	docker manifest create bgpid/pimcore:latest \
		--amend bgpid/pimcore:$(PIMCORE_DOCKER)-amd64 \
    	--amend bgpid/pimcore:$(PIMCORE_DOCKER)-arm64
	docker manifest push bgpid/pimcore:latest
	docker manifest create bgpid/pimcore-debug:latest \
		--amend bgpid/pimcore-debug:$(PIMCORE_DOCKER)-amd64 \
    	--amend bgpid/pimcore-debug:$(PIMCORE_DOCKER)-arm64
	docker manifest push bgpid/pimcore-debug:latest
	docker manifest create bgpid/pimcore-supervisord:latest \
		--amend bgpid/pimcore-supervisord:$(PIMCORE_DOCKER)-amd64 \
    	--amend bgpid/pimcore-supervisord:$(PIMCORE_DOCKER)-arm64
	docker manifest push bgpid/pimcore-supervisord:latest



# build-php-arch-amd:
# 	./scripts/taskfile.sh create_gz_file \
# 		docker/pimcore-php \
# 		files-00 \
# 		files.tar.gz
# 	./scripts/taskfile.sh build_docker_image \
# 		--push \
# 		pimcore-php-default \
# 		bgpid/pimcore-php:$(PHP_VERSION) \
# 		pimcore-php \
# 		bgpid/pimcore-php:latest \
# 		bgpid \
# 		linux/amd64
# 	./scripts/taskfile.sh remove_gz_file \
# 		docker/pimcore-php/files.tar.gz

# manifest-push-php-archs:
# 	docker manifest create bgpid/pimcore-php:8.3 \
#     	--amend bgpid/pimcore-php:8.3-arm64
# 		#--amend bgpid/pimcore-php:8.3-amd64 \
# 	docker manifest push bgpid/pimcore-php:8.3

# build-php-push-archs:
# 	./scripts/taskfile.sh create_gz_file \
# 		docker/pimcore-php \
# 		files-00 \
# 		files.tar.gz
# 	./scripts/taskfile.sh build_docker_image \
# 		--push \
# 		pimcore-php-default \
# 		bgpid/pimcore-php:$(PHP_VERSION) \
# 		pimcore-php \
# 		bgpid/pimcore-php:latest \
# 		bgpid \
# 		"$(ARCHS)"




# 	./script/taskfile.sh remove_gz_file \
# 		docker/pimcore-php/files.tar.gz

# build-arch:
# 	./scripts/taskfile.sh create_gz_file \
# 		docker/pimcore \
# 		files-00 \
# 		files.tar.gz
# 	# build bgpid/pimcore
# 	./scripts/taskfile.sh build_docker_image \
# 		--load \
# 	 	pimcore-php-installed \
# 	 	bgpid/pimcore:$(PIMCORE_DOCKER) \
# 	 	pimcore \
# 	 	bgpid/pimcore:latest \
# 	 	bgpid
# 	# build bgpid/pimcore-supervisord
# 	./scripts/taskfile.sh build_docker_image \
# 		--load \
# 		pimcore-php-supervisord \
# 		bgpid/pimcore-supervisord:$(PIMCORE_DOCKER) \
# 		pimcore \
# 		bgpid/pimcore-supervisord:latest \
# 		bgpid
# 	./scripts/taskfile.sh remove_gz_file \
# 		docker/pimcore/files.tar.gz

# build-push-archs:
# 	./scripts/taskfile.sh create_gz_file \
# 		docker/pimcore \
# 		files-00 \
# 		files.tar.gz
# 	./scripts/taskfile.sh build_docker_image \
# 		--push \
# 	 	pimcore-php-installed \
# 	 	bgpid/pimcore:$(PIMCORE_DOCKER) \
# 	 	pimcore \
# 	 	bgpid/pimcore:latest \
# 	 	bgpid \
# 		"$(ARCHS)"
# 	./scripts/taskfile.sh build_docker_image \
# 		--push \
# 		pimcore-php-supervisord \
# 		bgpid/pimcore-supervisord:$(PIMCORE_DOCKER) \
# 		pimcore \
# 		bgpid/pimcore-supervisord:latest \
# 		bgpid
# 		"$(ARCHS)"
# 	./scripts/taskfile.sh remove_gz_file \
# 		docker/pimcore/files.tar.gz
