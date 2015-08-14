tmp_dir := tmp
user    := vagrant@default
ssh_cfg := tmp/.ssh-config

mount_dir := /opt/bioboxes/

rsync := rsync -avz --quiet --exclude='.git*' -e "ssh -F $(ssh_cfg)"

all:

#######################################
#
# Provisioning the VM
#
#######################################

# This task will launch and provision the VM
init: up permissions rsync provision

permissions: $(ssh_cfg)
	ssh -F $(ssh_cfg) $(user) 'sudo mkdir -p $(mount_dir) && sudo chmod 770 $(mount_dir) && sudo chown vagrant:admin $(mount_dir)'

auto_rsync: $(ssh_cfg)
	@clear && make rsync
	@fswatch -o ./mount | xargs -n 1 -I {} bash -c "clear && make rsync"

rsync: $(ssh_cfg)
	$(rsync) ./mount/bin    $(user):$(mount_dir)
	$(rsync) ./mount/home/* $(user):.

provision: rsync
	ssh -F $(ssh_cfg) $(user) '$(mount_dir)/bin/provision'

#######################################
#
# Connecting to the VM
#
#######################################

ssh: $(ssh_cfg)
	ssh -F $(ssh_cfg) $(user)

$(ssh_cfg):
	vagrant ssh-config | grep -v WARNING > $@
	chmod 400 $@

#######################################
#
# Stopping and starting the VM
#
#######################################

$(tmp_dir)/.instance:
	rm -f $(ssh_cfg)
	vagrant up
	touch $@

up: $(tmp_dir)/.instance

down:
	vagrant destroy --force
	rm -f $(ssh_cfg) $(tmp_dir)/.instance

.PHONY: init ssh provision rsync up down
