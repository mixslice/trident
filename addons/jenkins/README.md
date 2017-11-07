# Hmmm This is going to be long. Will come back to elaborate.

## Starting your jenkins

First, substitute <YOUR_DOMAIN> with your domain in jenkins-ingress.yml

Then, substitute <VOLUME_ID> with your pre-made EBS volume ID in jenkins-pv.yml

Also there's a start sequence. Make sure you have the PV first, then the pvc, then the rest.
