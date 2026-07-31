# Allow read/update access to user management
path "identity/entity/*" {
  capabilities = ["create", "read", "update", "list"]
}

# Allow entity merge
path "identity/entity/merge" {
  capabilities = ["update"]
}

# Allow read/update access to user alias management
path "identity/entity-alias/*" {
  capabilities = ["create", "read", "update", "list"]
}

# Allow group management
path "identity/group/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow group alias management
path "identity/group-alias/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow lookup on identity
path "identity/lookup/*" {
  capabilities = ["create", "update"]
}

# Allow read-only access to auth method config
path "auth/+/config" {
  capabilities = ["read"]
}

# Allow read-only access to role
path "auth/+/role/*" {
  capabilities = ["read", "list"]
}

# Allow read-only access to system backend
path "sys/*" {
  capabilities = ["read", "list", "sudo"]
}

# Allow lease management
path "sys/leases/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Allow lookup on leases
path "sys/leases/lookup" {
  capabilities = ["list", "sudo"]
}
