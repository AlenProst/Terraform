output stg_acc_name_1 {
  value       = module.storage_account.stg_act_name_out
}

output rg_acc_name_1 {
  value       = module.W10.rg_name_out
}

output key_to_access {
  value       = module.file_share.key_out
  sensitive = true
}
