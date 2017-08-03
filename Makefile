BIN=/usr/bash

plan: docker_token_gen tf_get
	terraform plan

apply: docker_token_gen tf_get
	terraform apply

tf_get:
	terraform get

docker_token_remove:
	rm -rf ./secrets/docker_login

docker_token_gen: docker_token_remove
	aws ecr get-login --no-include-email --region cn-north-1 | sed "s/^/\/usr\/bin\//" > ./secrets/docker_login

tf_clean:
	terraform destroy

key_clean:
	ls secrets | grep -v README | xargs rm -rf

clean: tf_clean key_clean

output:
	terraform output
