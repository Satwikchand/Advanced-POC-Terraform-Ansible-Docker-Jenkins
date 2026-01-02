output "jenkins_ip" {
  description = "Public IP of Jenkins EC2 instance"
  value       = module.jenkins.public_ip
}

output "sonarqube_ip" {
  description = "Public IP of SonarQube EC2 instance"
  value       = module.sonarqube.public_ip
}

output "nexus_ip" {
  description = "Public IP of Nexus EC2 instance"
  value       = module.nexus.public_ip
}

output "docker_ip" {
  description = "Public IP of Docker host EC2 instance"
  value       = module.docker.public_ip
}
output "ansible_ip" {
  description = "Public IP of Ansible control node"
  value       = module.ansible.public_ip
}

