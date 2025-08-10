include .env
export $(shell sed 's/=.*//' .env)
SHELL := /bin/bash

BROADCAST_FLAG :=
VERIFY_FLAG :=

ifeq ($(BROADCAST),1)
	BROADCAST_FLAG := --broadcast
endif

ifeq ($(VERIFY), 1)
	VERIFY_FLAG := --verify --etherscan-api-key $(ETHERSCAN_API_KEY)
endif

test_and_deploy-anvil: test-anvil deploy-anvil

test_and_deploy-sepolia: test-sepolia deploy-sepolia

test-anvil:
	@forge test

test-sepolia:
	@forge test --fork-url $(SEPOLIA_RPC_URL)

deploy-anvil:
	@forge script script/DeployFundMe.s.sol $(BROADCAST_FLAG) --rpc-url $(ANVIL_RPC)

deploy-sepolia:
	@forge script script/DeployFundMe.s.sol --account testnet_account $(BROADCAST_FLAG) --rpc-url $(SEPOLIA_RPC_URL) $(VERIFY_FLAG)