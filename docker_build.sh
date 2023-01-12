export IMAGE=itecgo2021/drl
export TAG=latest

docker build -t ${IMAGE}:${TAG} .
docker push ${IMAGE}:${TAG}