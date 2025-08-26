# --- all hosts and whether they need fresh install ---
locals {
  hosts = {
    #"agent-0" = {
    #  hostname      = "agent-0"
    #  needs_install = false
    #}
    "laptop" = {
      hostname      = "laptop"
      needs_install = false
    }
    "laptop-huawei" = {
      hostname      = "laptop-huawei"
      needs_install = false
    }
    #"server-0" = {
    #  hostname      = "server-0"
    #  needs_install = false
    #}
  }
}
