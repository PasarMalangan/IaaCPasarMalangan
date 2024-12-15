output "ids" {
  value = [for instance in module.pm-instances : instance.id]
}
