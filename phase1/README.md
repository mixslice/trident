# Phase 1

set up virtual/physical machines on AWS

### Limitions

- Static vs. dynamic IP address vs. internal DNS

  Instances have a static private IP address. I’m using a simple address pattern to make them human-friendly: 10.43.0.1x are etcd instances, 10.43.0.2x Controllers and 10.43.0.3x Workers (aka Kubernetes Nodes or Minions), but this is not a requirement.

  A static address is required to have a fixed “handle” for each instance. In a big project, you have to create and maintain a “map” of assigned IPs  and be careful to avoid clashes. It sounds easy, but it could become messy in a big project. On the flip side, dynamic IP addresses change if (when) VMs restart for any uncontrollable event (hardware failure, the provider moving to different physical hardware, etc.), therefore DNS entry must be managed by the VM, not by Terraform… but this a different story.

  Real-world projects use internal DNS names as stable handles, not static IP. But to keep this project simple, I will use static IP addresses, assigned by Terraform, and no DNS.

- All instances are in a single, public subnet.
- All instances are directly accessible from outside the VPC. No VPN, no Bastion (though, traffic is allowed only from a single, configurable IP).
- Instances have static internal IP addresses. Any real-world environment should use DNS names and, possibly, dynamic IPs.
- A single server certificate for all components and nodes.
