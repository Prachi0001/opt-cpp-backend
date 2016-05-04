docker:
	docker build -t="pgbovine/opt-cpp-backend:v1" .

dockerbash:
	docker run -t -i --rm --user=netuser --net=none --cap-drop all pgbovine/opt-cpp-backend:v1 bash
