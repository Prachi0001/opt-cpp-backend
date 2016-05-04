all:
	./auto-everything.sh

test:
	cd tests && python golden_test.py --all

docker:
	docker build -t="pgbovine/opt-cpp-backend:v1" .

dockerbash:
	docker run -t -i --rm --user=netuser --net=none --cap-drop all pgbovine/opt-cpp-backend:v1 bash
