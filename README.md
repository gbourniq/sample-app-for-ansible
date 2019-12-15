to dos:
- finish make file with docker-compose commands
- create new branch using docker stacks and overlay network for swarm configuration
- review ansible best practices with other project. 
- add sensitive infos to gitignore
- put more in makefile: ec2-deployment ansible stuff
- use ansible tags to run installation commands or not > add env var INSTALL_DOCKER=true, and add ansible commands to makefile





make release > mongo:
	# ${INFO} "Running db migrations..."
	# @ docker-compose $(RELEASE_ARGS) run microtrader-audit java -cp /app/app.jar com.pluralsight.dockerproductionaws.admin.Migrate
	 


# - name: Tagging release images with tags latest...
#     shell: "cd {{ repo_folder }} && make tag-latest"
#     register: cmdln
#     failed_when: "cmdln.rc == 2"

# - name: Logging in to Docker registry {{ DOCKER_REGISTRY }}...
#     shell: "cd {{ repo_folder }} && make login"
#     register: cmdln
#     failed_when: "cmdln.rc == 2"

# - name: Publishing release images to {{ DOCKER_REGISTRY }}/{{ ORG_NAME }}...
#     shell: "cd {{ repo_folder }} && make publish"
#     register: cmdln
#     failed_when: "cmdln.rc == 2"