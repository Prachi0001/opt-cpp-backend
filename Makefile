all:
	./auto-everything.sh

docker:
	docker build -t="pgbovine/opt-cpp-backend:v1" .

dockerbash:
	docker run -t -i --rm --user=netuser --net=none --cap-drop all pgbovine/opt-cpp-backend:v1 bash

rawtest:
	python $(HOME)/opt-cpp-backend/run_cpp_backend.py "int main() {int x=12345;}" c

test:
	docker run -t -i --rm --user=netuser --net=none --cap-drop all pgbovine/opt-cpp-backend:v1 python /tmp/opt-cpp-backend/run_cpp_backend.py "int main() {int x=12345;}" c

regtest:
	docker run -t -i --rm --user=netuser --net=none --cap-drop all pgbovine/opt-cpp-backend:v1 /bin/sh -c 'cd /tmp/opt-cpp-backend/tests && python golden_test.py --all'
