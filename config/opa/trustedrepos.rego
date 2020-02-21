package main

trustedRegistries := [
    {"name": "quay.io"}
]

deny[msg] {
    input.kind == "Deployment"
    c := input.spec.template.spec.containers[_]
    satisfy := [ good | registry = registries[_] ; good = startswith(c.image, registry) ]
    not any(satisfy)
    msg := sprintf("container <%v> has an invalid image registry <%v>, allowed registries are %v", [c.name, c.image, registries])
}

registries[name] {
    name := trustedRegistries[_].name
}

containers[c] {
    c := input.spec.template.spec.containers[_]
}

containers[c] {
    c := input.spec.template.spec.initContainers[_]
}
