#! /bin/bash

TF_VAR_db_username=databaseusername \
TF_VAR_db_password=databasepassword \
TF_VAR_secret_key_base=verylongrandomsecretkey \
terragrunt apply-all
# terragrunt destroy-all
