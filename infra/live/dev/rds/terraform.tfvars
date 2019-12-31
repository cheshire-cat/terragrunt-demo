terragrunt = {
  terraform {
    source = "../../../sources//rds"
  }

  include = {
    path = "${find_in_parent_folders()}"
  }

  dependencies {
    paths = ["../vpc"]
  }
}

db_name = "dev_demo_db"
db_instance = "db.t2.micro"
