# Common settings
include ../Makefile.settings

roles:
	${INFO} "Installing Ansible roles from roles/requirements.yml..."
	@ ansible-galaxy install -r ec2-deployment/roles/requirements.yml --force
	${INFO} "Installation complete"

environment/%:
	@ mkdir -p group_vars/$*
	@ touch group_vars/$*/vars.yml
	@ echo >> inventory
	@ echo '[$*]' >> inventory
	@ echo '$* ansible_connection=local' >> inventory
	${INFO} "Created environment $*"

generate/%:
	${INFO} "Generating templates for $*..."
	@ ansible-playbook site.yml -e 'Sts.Disabled=true' -e env=$* $(FLAGS) --tags generate
	${INFO} "Generation complete"

deploy/%:
	${INFO} "Deploying environment $*..."
	@ ansible-playbook site.yml -e env=$* $(FLAGS)
	${INFO} "Deployment complete"

delete/%:
	${INFO} "Deleting environment $*..."
	@ ansible-playbook site.yml -e env=$* -e 'Stack.Delete=true' $(FLAGS)
	${INFO} "Delete complete"