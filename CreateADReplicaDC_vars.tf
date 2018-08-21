variable location {
  type = "string"
}

variable new_dc_resourcegroup {
  type = "string"
}

variable target_vnet_resourcegroup {
  type = "string"
}

variable target_vnet {
  type = "string"
}

variable target_subnet {
  type = "string"
}

variable vmname_prefix {
  type = "string"
}

variable count {
  default = 2
}

variable addomain {
  type = "string"
}

variable adsitename {
  type    = "string"
  default = "Default-First-Site-Name"
}

variable admin_username {
  type = "string"
}

variable admin_password {
  type = "string"
}

variable safemode_password {
  type = "string"
}

variable vm_size {
  type    = "string"
  default = "Standard_D2_v2"
}
