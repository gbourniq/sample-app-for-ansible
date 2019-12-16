- use ansible to deploy instance and get back public ip 
- use ansible to kill instance and run full workflow



!!! for ansible to support instance creation in eu-west-3, need to replace
/Users/guillaume.bournique/.local/lib/python3.6/site-packages/boto/endpoints.json
/Users/guillaume.bournique/anaconda3/lib/python3.7/site-packages/boto


# create encrypted password

ansible-vault encrypt_string --vault-id user@~/.ssh/ansible-vault-pw 'uCCTvzTZZCrmT3nR+2EZPuGqwefqwefqwefweqfweKBEQIXcuLEwefzErCkgf' --name 'aws_secret_key'

Note that `boto3` must also be installed in the system python, which you can perform as follows:

```bash
$ sudo -H /usr/bin/python -m easy_install pip
...
...
$ sudo -H /usr/bin/python -m pip install boto3 --ignore-installed six
...
...
```

Once you have installed `boto3` in your system python, it is recommended to run the following commands to ensure your Homebrew and system python environments are configured correctly:

```
$ brew unlink python
...
$ brew link --overwrite python
...
```