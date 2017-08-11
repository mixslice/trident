CA_CERT = ./secrets/ca.pem
ADMIN_KEY = ./secrets/admin-key.pem
ADMIN_CERT = ./secrets/admin.pem
MASTER_HOST = $(shell terraform output | grep -A1 master_ip | awk 'NR>1 {print $1}' | xargs echo)
NAMESPACE ?= kube-system

plan: tf_get
	terraform plan

apply: tf_get
	terraform apply

build: apply kubecfg sync_upload kubectl_dockertoken create_all_addons build_complete

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
	NAMESPACE=$(NAMESPACE) ./local_setup_secret.sh

label_edge_node:
	$(eval NODE_NAME := $(shell make output | awk '/worker_private_dns/{getline; print}' | sed 's/\,$///g'))
	until kubectl get no | grep $(NODE_NAME); do printf 'waiting on node...\n'; sleep 5; done

	kubectl label no $(NODE_NAME) role="edge-router" --overwrite

unlabel_edge_node:
	kubectl label no node-1 role-

delete_traefik:
	kubectl apply -f addons/traefik/.

create_traefik:
	kubectl apply -f addons/traefik/.

create_all_addons: label_edge_node create_essential_addons create_traefik

delete_all_addons: delete_essential_addons delete_traefik

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
