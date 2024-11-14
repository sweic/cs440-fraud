IMAGE_TAG=cs440-fraud-detection
CONATINER_NAME=cs440-fraud-detection

ifdef DOCKER_IMAGE_TAG
	IMAGE_TAG = ${DOCKER_IMAGE_TAG}
endif

build:
	- docker build -t ${IMAGE_TAG} .

stop:
	- docker stop ${CONATINER_NAME} || true \
	echo "Container ${CONATINER_NAME} stopped"

remove:
	- docker rm ${CONATINER_NAME} || true \
	echo "Container ${CONATINER_NAME} removed"

run: stop remove
	docker run -d \
	-p 7474:7474 \
	-p 7687:7687 \
	--name ${CONATINER_NAME} \
	${IMAGE_TAG}
