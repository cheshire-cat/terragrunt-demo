terragrunt = {
  terraform {
    source = "../../../sources//vpc"
  }

  include = {
    path = "${find_in_parent_folders()}"
  }
}
