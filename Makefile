SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

.PHONY: help seeds hyperv apply check test destroy
help:
	@printf '%s\n' 'seeds   Build cloud-init seed ISOs' 'hyperv Create Hyper-V resources' 'apply   Configure guests with Ansible' 'check   Run static checks' 'test    Run policy smoke tests' 'destroy Remove disposable VMs'
seeds:
	./scripts/build-seeds.sh
hyperv: seeds
	powershell.exe -NoProfile -ExecutionPolicy Bypass -File hyperv/Apply.ps1
apply:
	ansible-playbook -i ansible/inventory.yml ansible/site.yml
check:
	shellcheck scripts/*.sh tests/*.sh
	yamllint ansible cloud-init
	ansible-playbook -i ansible/inventory.yml ansible/site.yml --syntax-check
test:
	./tests/network-policy.sh
destroy:
	powershell.exe -NoProfile -ExecutionPolicy Bypass -File hyperv/Destroy.ps1

