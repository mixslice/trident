variable "pod_network" {}

output "rendered_data"{
  value = "${data.template_file.master_yml.rendered}"
}
