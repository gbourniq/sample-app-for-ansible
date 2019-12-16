- use ansible to deploy instance and get back public ip 
- use ansible to kill instance and run full workflow



!!! for ansible to support instance creation in eu-west-3, need to replace
/Users/guillaume.bournique/.local/lib/python3.6/site-packages/boto/endpoints.json

# create encrypted password

ansible-vault encrypt_string --vault-id user@~/.ssh/ansible-vault-pw 'uCCTvzTZZCrmT3nR+2EZPuGqwefqwefqwefweqfweKBEQIXcuLEwefzErCkgf' --name 'aws_secret_key'
