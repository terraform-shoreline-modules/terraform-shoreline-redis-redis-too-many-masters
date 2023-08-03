terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "redis_too_many_masters_incident" {
  source    = "./modules/redis_too_many_masters_incident"

  providers = {
    shoreline = shoreline
  }
}