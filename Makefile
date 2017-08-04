CA_CERT=./secrets/ca.pem
ADMIN_KEY=./secrets/admin-key.pem
ADMIN_CERT=./secrets/admin.pem
MASTER_HOST=$(shell terraform output | grep -A1 master_ip | awk 'NR>1 {print $1}' | xargs echo)

.PHONY: apply kubecfg

plan: docker_token_gen tf_get
	terraform plan

apply: docker_token_gen tf_get
	terraform apply

build: apply kubecfg

tf_get:
	terraform get

docker_token_remove:
	rm -rf ./secrets/docker_login

docker_token_gen: docker_token_remove
	aws ecr get-login --no-include-email --region cn-north-1 | sed "s/^/\/usr\/bin\//" > ./secrets/docker_login

tf_clean:
	terraform destroy

key_clean:
	ls secrets | grep -v README  | sed "s/^/secrets\//" | xargs rm -rf

clean: tf_clean key_clean

output:
	terraform output

kubecfg:
	./cfssl/generate_admin.sh
	kubectl config set-cluster default-cluster \
	--server=https://$(MASTER_HOST) --certificate-authority=$(CA_CERT)
	kubectl config set-credentials default-admin \
	--certificate-authority=$(CA_CERT) --client-key=$(ADMIN_KEY) --client-certificate=$(ADMIN_CERT)
	kubectl config set-context default-system --cluster=default-cluster --user=default-admin
	kubectl config use-context default-system

kube_ecr_token_refresh_addon:
	kubectl create -f addons/ecr-dockercfg-refresh

node_clean:
	kubectl get no | grep NotReady | awk '{print $$1}' | xargs kubectl delete node

kubect_dockertoken:
	./local_setup_secrets.sh

upload_secrets:
	aws s3 cp --recursive ./secrets/ s3://k8s-secrets/

download_secrets:
	aws s3 cp --recursive s3://k8s-secrets/
