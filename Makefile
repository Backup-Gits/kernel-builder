.DEFAULT_GOAL := help
IMG_NAME = fpf.local/kernel-builder

.PHONY: vanilla
vanilla: ## Builds latest stable kernel, unpatched
	# Include reproducibility patch, for Debian changelog timestamp
	LINUX_LOCAL_PATCHES_PATH="$(PWD)/patches/00-debian-reproducibility.patch" \
		./scripts/build-kernel-wrapper

.PHONY: grsec
grsec: ## Builds grsecurity-patched kernel (requires credentials)
	GRSECURITY=1 ./scripts/build-kernel-wrapper

.PHONY: reprotest
reprotest: ## Builds simple kernel multiple times to confirm reproducibility
	./scripts/reproducibility-test

.PHONY: reprotest-sd
reprotest-sd: ## DEBUG Builds SD kernel config without grsec in CI
	GRSECURITY=0 LOCALVERSION="-securedrop" \
		LINUX_LOCAL_CONFIG_PATH="$(PWD)/configs/config-securedrop-5.4" \
		LINUX_LOCAL_PATCHES_PATH="$(PWD)/patches" \
		./scripts/reproducibility-test

securedrop-core: ## Builds kernels for SecureDrop servers, 5.4.x
	GRSECURITY=1 GRSECURITY_PATCH_TYPE=stable4 LOCALVERSION="-securedrop" \
		LINUX_LOCAL_CONFIG_PATH="$(PWD)/configs/config-securedrop-5.4" \
		LINUX_LOCAL_PATCHES_PATH="$(PWD)/patches" \
		./scripts/build-kernel-wrapper

securedrop-workstation: ## Builds kernels for SecureDrop Workstation
	GRSECURITY=1 GRSECURITY_PATCH_TYPE=stable3 LOCALVERSION="-workstation" \
		LINUX_LOCAL_CONFIG_PATH="$(PWD)/configs/config-workstation-4.14" \
		./scripts/build-kernel-wrapper

.PHONY: help
help: ## Prints this message and exits.
	@printf "Subcommands:\n\n"
	@perl -F':.*##\s+' -lanE '$$F[1] and say "\033[36m$$F[0]\033[0m : $$F[1]"' $(MAKEFILE_LIST) \
		| sort \
		| column -s ':' -t
