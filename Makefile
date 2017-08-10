CA_CERT = ./secrets/ca.pem
ADMIN_KEY = ./secrets/admin-key.pem
ADMIN_CERT = ./secrets/admin.pem
MASTER_HOST = $(shell terraform output | grep -A1 master_ip | awk 'NR>1 {print $1}' | xargs echo)
NAMESPACE ?= kube-system

plan: tf_get
	terraform plan

apply: tf_get
	terraform apply

build: apply kubecfg sync_upload kubectl_dockertoken create_essential_addons build_complete

build_complete:
	osascript -e 'display notification "Your build has finished!" with title "Jobs Done"'

clean: tf_clean key_clean

output:
	terraform output

tf_get:
	terraform get

tf_clean: tf_get
	terraform destroy

key_clean:
	ls secrets | grep -v README  | sed "s/^/secrets\//" | xargs rm -rf

kubecfg:
	./cfssl/generate.sh client admin
	kubectl config set-cluster default-cluster \
	--server=https://$(MASTER_HOST) --certificate-authority=$(CA_CERT)
	kubectl config set-credentials default-admin \
	--certificate-authority=$(CA_CERT) --client-key=$(ADMIN_KEY) --client-certificate=$(ADMIN_CERT)
	kubectl config set-context default-system --cluster=default-cluster --user=default-admin
	kubectl config use-context default-system

remote_kubecfg: key_clean sync_download kubecfg

node_clean:
	kubectl get no | grep NotReady | awk '{print $$1}' | xargs kubectl delete node

kubectl_dockertoken:
	./local_setup_secret.sh

delete_essential_addons:
	kubectl delete -f addons/dashboard/.
	kubectl delete -f addons/heapster/.
	kubectl delete -f addons/dns/.

create_essential_addons:
	kubectl apply -f addons/dns/.
	kubectl apply -f addons/heapster/.
	kubectl apply -f addons/dashboard/.

sync_upload:
	aws s3 sync --exclude="admin*" --exclude="README.md" ./secrets/ s3://k8s-secrets
	aws s3 cp terraform.tfstate s3://k8s-secrets

sync_download:
	aws s3 sync s3://k8s-secrets ./secrets/
	cp ./secrets/terraform.tfstate terraform.tfstate
