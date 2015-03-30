tmp_dir := tmp
user    := vagrant@default
ssh_cfg := tmp/.ssh-config

mount_dir := /opt/docker_workshop/

rsync := rsync -avz --exclude='.git/' -e "ssh -F $(ssh_cfg)"

data_url := 'https://www.dropbox.com/s/gcy0q3m2h67zxmr/reads.fq.xz?dl=0'

all:

mount/tmp:
	mkdir -p $@

#######################################
#
# Fetch data for testing images
#
#######################################

$(tmp_dir)/reads.fq.xz:
	mkdir -p $(dir $@)
	wget \
		--quiet \
		--output-document $@ \
		$(data_url)

mount/data/reads.fq.gz: $(tmp_dir)/reads.fq.xz
	mkdir -p $(dir $@)
	xzcat $< | gzip > $@

bootstrap: mount/data/reads.fq.gz mount/tmp

#######################################
#
# Launching the vagrant instance
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

#######################################
#
# Connecting to the instance
#
#######################################

ssh: $(ssh_cfg)
	ssh -F $(ssh_cfg) $(user)

$(ssh_cfg):
	vagrant ssh-config | grep -v WARNING > $@
	chmod 400 $@

permissions: $(ssh_cfg)
	ssh -F $(ssh_cfg) $(user) 'sudo mkdir -p $(mount_dir) && sudo chmod 770 $(mount_dir) && sudo chown vagrant:admin $(mount_dir)'

rsync: $(ssh_cfg)
	$(rsync) ./mount/bin  $(user):$(mount_dir)
	$(rsync) ./mount/data $(user):$(mount_dir)
	$(rsync) ./mount/tmp  $(user):.

provision: rsync
	ssh -F $(ssh_cfg) $(user) '$(mount_dir)/bin/provision'

# This task will launch and provision the instance
init: up permissions rsync provision
