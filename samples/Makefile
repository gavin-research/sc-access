DOCKER_COMPOSE ?= docker compose
TRUFFLE ?= npx truffle
TEST_OPTS ?= --compile-none --migrate-none

# setup
.PHONY: setup down
setup: build network sleep migrate 
down: network-down

# build
.PHONY: build build-contract build-container
build: build-contract build-container

build-contract:
	@make -C ../contracts/access build

build-container:
	@make -C chains build

# network
.PHONY: network network-down
network:
	@make -C chains network

network-down:
	@make -C chains network-down

# contract migration
.PHONY: migrate
migrate:
	npm run migrate:ibc0





# textlint
.PHONY: lint
lint:
	npm run lint

.PHONY: test-give-access test-getGivenAccesses test-getInfo test-gas
# 
test-give-access:
	${TRUFFLE} exec test/access/1-giveAccess.js --network=ibc0 \


test-getGivenAccesses:
	${TRUFFLE} exec test/access/2-getGivenAccesses.js --network=ibc0 
	

test-getInfo:
	${TRUFFLE} exec test/access/3-access.js --network=ibc0 

test-gas: 
	${TRUFFLE} test test/gas/1-gas-giveAccess.test.js --network=ibc0 ${TEST_OPTS} \
	&& sleep 3 \
	&& ${TRUFFLE} test test/gas/2-gas-getGivenAccesses.test.js --network=ibc0 ${TEST_OPTS} \
	&& sleep 3 \
	&& ${TRUFFLE} test test/gas/3-gas-access.test.js --network=ibc0 ${TEST_OPTS}



.PHONY: sleep
sleep:
	sleep 5
