tmp_dir := tmp
user    := vagrant@default
ssh_cfg := tmp/.ssh-config

data_url := 'https://www.dropbox.com/s/hcquyvihmy0cpy7/reads.fq.xz?dl=1'

all:

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

bootstrap: mount/data/reads.fq.gz

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

rsync: $(ssh_cfg)
	rsync -avz --exclude='.git/' -e "ssh -F $(ssh_cfg)" ./mount/* $(user):.

provision: rsync
	ssh -F $(ssh_cfg) $(user) './bin/provision'

# This task will launch and provision the instance
init: up rsync provision
