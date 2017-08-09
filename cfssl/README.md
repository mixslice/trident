# CFSSL Guide:

CN: used by some CAs to determine which domain the certificate is to be generated. kube-apiserver 从证书中提取该字段作为请求的用户名 (User Name)；浏览器使用该字段验证网站是否合法

Hosts:  a list of the domain names which the certificate should be valid for

Names:

"C": country

"L": location

"O": company/organization (Organization，kube-apiserver 从证书中提取该字段作为请求用户所属的组 (Group)

"OU": department

"ST": province

# For more information:

- [Create a new CSR](https://github.com/cloudflare/cfssl/wiki/Creating-a-new-CSR)
