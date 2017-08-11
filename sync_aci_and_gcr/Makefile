FLANNEL_VERSION ?= v0.7.1
HYPERKUBE_VERSION ?= v1.7.3_coreos.0
GCR_IMAGES ?= heapster@v1.3.0 \
			addon-resizer@1.7 \
			kubernetes-dashboard-amd64:v1.6.3 \
			k8s-dns-kube-dns-amd64@1.14.4 \
			k8s-dns-sidecar-amd64@1.14.4 \
			k8s-dns-dnsmasq-nanny-amd64@1.14.4 \
			cluster-proportional-autoscaler-amd64@@1.1.2-r2 \
			echoserver@1.4

sync_targets = $(addprefix image_, $(GCR_IMAGES))
GCR_PREFIX = gcr.io/google_containers
ECR_PREFIX = 493490470276.dkr.ecr.cn-north-1.amazonaws.com.cn

sync_all: sync_all_aci sync_all_gcr

dockercfg:
	eval $$(aws ecr get-login --no-include-email --region cn-north-1)

sync_all_aci: sync_flannel sync_hyperkube

sync_flannel: fetch_flannel upload_flannel

fetch_flannel:
	docker2aci docker://quay.io/coreos/flannel:$(FLANNEL_VERSION)

upload_flannel:
	aws s3 cp --acl public-read \
		coreos-flannel-$(FLANNEL_VERSION).aci \
		s3://kubernetes-bin/flannel_$(FLANNEL_VERSION).aci

sync_hyperkube: fetch_hyperkube upload_hyperkube

fetch_hyperkube:
	docker2aci docker://quay.io/coreos/hyperkube:$(HYPERKUBE_VERSION)

upload_hyperkube:
	aws s3 cp --acl public-read \
		coreos-hyperkube-$(HYPERKUBE_VERSION).aci \
		s3://kubernetes-bin/hyperkube_$(HYPERKUBE_VERSION).aci

sync_all_gcr: $(sync_targets)

$(sync_targets): image_%:
	$(eval IMAGE_NAME := $(shell echo $* | sed -e 's/@/:/g'))
	$(eval REPO_NAME := $(shell echo $* | cut -d@ -f1))
	docker pull $(GCR_PREFIX)/$(IMAGE_NAME)
	docker tag $(GCR_PREFIX)/$(IMAGE_NAME) $(ECR_PREFIX)/$(IMAGE_NAME)
	if [ -z $$(aws ecr describe-repositories --repository-names $(REPO_NAME) --query "repositories[].repositoryName" --output text) ]; then \
		aws ecr create-repository --repository-name $(REPO_NAME); \
	fi
	docker push $(ECR_PREFIX)/$(IMAGE_NAME)
