terraform {
  cloud {
    organization = "aura"

    workspaces {
      name = "keycloak"
    }
  }
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "3.11.0-rc.0"
    }
  }
}

provider "keycloak" {
  base_path = ""
}