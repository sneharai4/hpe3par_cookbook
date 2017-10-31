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
  fail ArgumentError, 'Attribute storage_system is required for volume set creation' unless new_resource.storage_system
  fail ArgumentError, 'Attribute name is required for volume set creation' unless new_resource.name
  
  if !volume_set_exists?(new_resource.storage_system, new_resource.name)
    op_status = create_volume_set(new_resource.storage_system, new_resource.name, new_resource.domain, new_resource.setmembers)
    new_resource.updated_by_last_action(true) if op_status
    Chef::Log.info("Created volume set #{new_resource.name}.")
  else
    Chef::Log.info("Volume set #{new_resource.name} already exists. Nothing to do.")
  end

end

action :delete do
# validations
  fail ArgumentError, 'Attribute storage_system is required for  volume set deletion' unless new_resource.storage_system
  fail ArgumentError, 'Attribute name is required for volume set deletion' unless new_resource.name
  op_status = delete_volume_set(new_resource.storage_system, new_resource.name)
  new_resource.updated_by_last_action(true) if op_status
end

action :add_volume do
# validations
  fail ArgumentError, 'Attribute storage_system is required to add volume to volume set' unless new_resource.storage_system
  fail ArgumentError, 'Attribute name is required to add volume to volume set' unless new_resource.name
  fail ArgumentError, 'Attribute name is required to add volume to volume set' unless new_resource.setmembers
  op_status = add_volume_to_volume_set(new_resource.storage_system, new_resource.name, new_resource.setmembers)
  new_resource.updated_by_last_action(true) if op_status
end

action :remove_volume do
# validations
  fail ArgumentError, 'Attribute storage_system is required to remove volume from volume set' unless new_resource.storage_system
  fail ArgumentError, 'Attribute name is required to remove volume from volume set' unless new_resource.name
  fail ArgumentError, 'Attribute name is required to remove volume from volume set' unless new_resource.setmembers 
  op_status = remove_volume_from_volume_set(new_resource.storage_system, new_resource.name, new_resource.setmembers)
  new_resource.updated_by_last_action(true) if op_status
end