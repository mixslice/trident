CA_CERT=./secrets/ca.pem
ADMIN_KEY=./secrets/admin-key.pem
ADMIN_CERT=./secrets/admin.pem
MASTER_HOST=$(shell terraform output | grep -A1 master_ip | awk 'NR>1 {print $1}' | xargs echo)

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

kubecfg:
	kubectl config set-cluster default-cluster \
	--server=https://$(MASTER_HOST) --certificate-authority=$(CA_CERT)
	kubectl config set-credentials default-admin \
	--certificate-authority=$(CA_CERT) --client-key=$(ADMIN_KEY) --client-certificate=$(ADMIN_CERT)
	kubectl config set-context default-system --cluster=default-cluster --user=default-admin
	kubectl config use-context default-system

node_clean:
	kubectl get no | grep NotReady | awk '{print $$1}' | xargs kubectl delete node
