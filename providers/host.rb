# (c) Copyright 2016-2017 Hewlett Packard Enterprise Development LP
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

include HPE3PAR::RestHelper

action :create do
# validations
  fail ArgumentError, 'Attribute storage_system is required for host creation' unless new_resource.storage_system
  fail ArgumentError, 'Attribute name is required for host creation' unless new_resource.name
  if !new_resource.fc_wwns.nil? and !new_resource.iscsi_names.nil?
    fail ArgumentError, 'Both attribute fc_wwns and iscsi_names cannot be given at the same time for host creation'
  end

  if !host_exists?(new_resource.storage_system, new_resource.name)
    op_status = create_host(new_resource.storage_system, new_resource.name, new_resource.domain,
                            new_resource.fc_wwns, new_resource.iscsi_names, new_resource.persona)
    new_resource.updated_by_last_action(true) if op_status
  else
    Chef::Log.info("Host #{new_resource.name} already exists. Nothing to do.")
  end
end

action :delete do
# validations
  fail ArgumentError, 'Attribute storage_system is required for host deletion' unless new_resource.storage_system
  fail ArgumentError, 'Attribute name is required for host deletion' unless new_resource.name
  op_status = delete_host(new_resource.storage_system, new_resource.name)
  new_resource.updated_by_last_action(true) if op_status
end

action :modify do
# validations
  fail ArgumentError, 'Attribute storage_system is required for host modification' unless new_resource.storage_system
  fail ArgumentError, 'Attribute name is required for host modification' unless new_resource.name
  op_status = modify_host(new_resource.storage_system, new_resource.name, new_resource.new_name, new_resource.persona, new_resource.domain)
  new_resource.updated_by_last_action(true) if op_status
end

action :add_initiator_chap do
# validations
  fail ArgumentError, 'Attribute storage_system is required for host modification' unless new_resource.storage_system
  fail ArgumentError, 'Attribute name is required for host modification' unless new_resource.name
  fail ArgumentError, 'Attribute chap_name is required for host modification' unless new_resource.chap_name
  fail ArgumentError, 'Attribute chap_secret is required for host modification' unless new_resource.chap_secret
  if new_resource.chap_secret_hex && new_resource.chap_secret.length != 32
    fail ArgumentError, 'Attribute chap_secret must be 32 hexadecimal characters if chap_secret_hex is true'
  end
  if !new_resource.chap_secret_hex && (new_resource.chap_secret.length < 12 || new_resource.chap_secret.length > 16)
    fail ArgumentError, 'Attribute chap_secret must be 12 to 16 character if chap_secret_hex is false'
  end
  op_status = add_initiator_chap(new_resource.storage_system, new_resource.name, new_resource.chap_name,
                                 new_resource.chap_secret, new_resource.chap_secret_hex)
  new_resource.updated_by_last_action(true) if op_status
end

action :remove_initiator_chap do
# validations
  fail ArgumentError, 'Attribute storage_system is required for host modification' unless new_resource.storage_system
  fail ArgumentError, 'Attribute name is required for host modification' unless new_resource.name
  op_status = remove_initiator_chap(new_resource.storage_system, new_resource.name)
  new_resource.updated_by_last_action(true) if op_status
end

action :add_target_chap do
# validations
  fail ArgumentError, 'Attribute storage_system is required for host modification' unless new_resource.storage_system
  fail ArgumentError, 'Attribute name is required for host modification' unless new_resource.name
  fail ArgumentError, 'Attribute chap_name is required for host modification' unless new_resource.chap_name
  fail ArgumentError, 'Attribute chap_secret is required for host modification' unless new_resource.chap_secret
  if new_resource.chap_secret_hex && new_resource.chap_secret.length != 32
    fail ArgumentError, 'Attribute chap_secret must be 32 hexadecimal characters if chap_secret_hex is true'
  end
  if !new_resource.chap_secret_hex && (new_resource.chap_secret.length < 12 || new_resource.chap_secret.length > 16)
    fail ArgumentError, 'Attribute chap_secret must be 12 to 16 character if chap_secret_hex is false'
  end

  if initiator_chap_exists?(new_resource.storage_system, new_resource.name)
    op_status = add_target_chap(new_resource.storage_system, new_resource.name, new_resource.chap_name,
                                new_resource.chap_secret, new_resource.chap_secret_hex)
    new_resource.updated_by_last_action(true) if op_status
  else
    Chef::Log.info("Initiator CHAP needs to be enabled before target CHAP is set for host #{new_resource.name}")
  end
end

action :remove_target_chap do
# validations
  fail ArgumentError, 'Attribute storage_system is required for host modification' unless new_resource.storage_system
  fail ArgumentError, 'Attribute name is required for host modification' unless new_resource.name
  op_status = remove_target_chap(new_resource.storage_system, new_resource.name)
  new_resource.updated_by_last_action(true) if op_status
end

action :add_fc_path_to_host do
# validations
  fail ArgumentError, 'Attribute storage_system is required for host modification' unless new_resource.storage_system
  fail ArgumentError, 'Attribute name is required for host modification' unless new_resource.name
  fail ArgumentError, 'Attribute fc_wwns is required to add fc path to host' unless new_resource.fc_wwns
  op_status = add_fc_path_to_host(new_resource.storage_system, new_resource.name, new_resource.fc_wwns)
  new_resource.updated_by_last_action(true) if op_status
end

action :remove_fc_path_from_host do
# validations
  fail ArgumentError, 'Attribute storage_system is required for host modification' unless new_resource.storage_system
  fail ArgumentError, 'Attribute name is required for host modification' unless new_resource.name
  fail ArgumentError, 'Attribute fc_wwns is required to remove fc path from host' unless new_resource.fc_wwns
  op_status = remove_fc_path_from_host(new_resource.storage_system, new_resource.name, new_resource.fc_wwns, new_resource.force_path_removal)
  new_resource.updated_by_last_action(true) if op_status
end

action :add_iscsi_path_to_host do
# validations
  fail ArgumentError, 'Attribute storage_system is required for host modification' unless new_resource.storage_system
  fail ArgumentError, 'Attribute name is required for host modification' unless new_resource.name
  fail ArgumentError, 'Attribute iscsi_names is required to add iscsi path to host' unless new_resource.iscsi_names
  op_status = add_iscsi_path_to_host(new_resource.storage_system, new_resource.name, new_resource.iscsi_names)
  new_resource.updated_by_last_action(true) if op_status
end

action :remove_iscsi_path_from_host do
# validations
  fail ArgumentError, 'Attribute storage_system is required for host modification' unless new_resource.storage_system
  fail ArgumentError, 'Attribute name is required for host modification' unless new_resource.name
  fail ArgumentError, 'Attribute iscsi_names is required to remove iscsi path from host' unless new_resource.iscsi_names
  op_status = remove_iscsi_path_from_host(new_resource.storage_system, new_resource.name, new_resource.iscsi_names, new_resource.force_path_removal)
  new_resource.updated_by_last_action(true) if op_status
end