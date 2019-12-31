terragrunt = {
  terraform {
    source = "../../../sources//repo"
  }

  include = {
    path = "${find_in_parent_folders()}"
  }
}
