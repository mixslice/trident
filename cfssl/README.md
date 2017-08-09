# CFSSL Guide:

CN: used by some CAs to determine which domain the certificate is to be generated. kube-apiserver 从证书中提取该字段作为请求的用户名 (usr)；浏览器使用该字段验证网站是否合法

Hosts:  a list of the domain names which the certificate should be valid for

Names:

"C": country

"L": location

"O": company/organization (Organization，kube-apiserver 从证书中提取该字段作为请求用户所属的组 (Group))

"OU": department

"ST": province

# Caution:

Right now we use a single role for all components on master machine (system:masters), such as apiserver, proxy, controller and scheduler. For more cautious safety measures, change those roles to specified roles as in [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/).

# For more information:

- [Create a new CSR by cloudflare](https://github.com/cloudflare/cfssl/wiki/Creating-a-new-CSR)
- [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/)
