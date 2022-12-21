# ---------------------------
# TEMPLATE FILE
# ---------------------------

# Configure the Template Provider
provider "cloudinit" {
}

# ---------------------------
# TEMPLATE CLOUD-INIT CONFIG
# ---------------------------
data "cloudinit_config" "default" {

  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/templates/default.yml")
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/users.tpl", { user_group = "users", harsha_id = var.users["harsha.id"],
      harsha_name = var.users["harsha.name"], harsha_key = var.users["harsha.key"], jyothi_id = var.users["jyothi.id"],
    jyothi_name = var.users["jyothi.name"], jyothi_key = var.users["jyothi.key"] })
    merge_type = "list(append)+dict(recurse_array)+str()"
  }
  part {
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/templates/docker.tpl", { keep_disk = var.keep_disk })
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/templates/ethereum.yml")
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
}

data "cloudinit_config" "shared" {

  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/templates/default.yml")
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/users.tpl", { user_group = "users", harsha_id = var.users["harsha.id"],
      harsha_name = var.users["harsha.name"], harsha_key = var.users["harsha.key"], jyothi_id = var.users["jyothi.id"],
    jyothi_name = var.users["jyothi.name"], jyothi_key = var.users["jyothi.key"] })
    merge_type = "list(append)+dict(recurse_array)+str()"
  }
  part {
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/templates/docker.tpl", { keep_disk = var.keep_disk })
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/templates/shared.yml")
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
}

data "cloudinit_config" "defichain" {

  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/templates/default.yml")
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
  part {
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/templates/docker.tpl", { keep_disk = var.keep_disk })
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/templates/defichain.yml")
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
}