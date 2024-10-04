https://github.com/Ornstein89/docker-nginx-module-vts/blob/main/build_separate/Dockerfile

docker build --progress plain --no-cache -t ng .

docker run -ti -d -p 80:80 -p 9113:9113 ng