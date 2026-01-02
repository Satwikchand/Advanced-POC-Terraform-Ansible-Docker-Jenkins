output "jenkins_sg" {
  value = aws_security_group.jenkins.id
}

output "sonarqube_sg" {
  value = aws_security_group.sonarqube.id
}

output "nexus_sg" {
  value = aws_security_group.nexus.id
}

output "docker_sg" {
  value = aws_security_group.docker.id
}

output "ansible_sg" {
  value = aws_security_group.ansible.id
}
