all:
	./auto-everything.sh

docker:
	docker build -t="pgbovine/opt-cpp-backend:v1" .

dockerbash:
	docker run -t -i --rm --user=netuser --net=none --cap-drop all pgbovine/opt-cpp-backend:v1 bash

test:
	docker run -t -i --rm --user=netuser --net=none --cap-drop all pgbovine/opt-cpp-backend:v1 /bin/sh -c 'cd /tmp/opt-cpp-backend/tests && python golden_test.py --all'
