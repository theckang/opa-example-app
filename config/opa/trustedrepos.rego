package main

deny[msg] {
  input.kind == "Deployment"
  image := input.spec.template.spec.containers[_].image
  not startswith(image, "quay.io/")
  msg := sprintf("image '%v' comes from untrusted registry", [image])
}
