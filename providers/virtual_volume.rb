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
  fail ArgumentError, 'Attribute storage_system is required for volume creation' unless new_resource.storage_system
  fail ArgumentError, 'Attribute name is required for volume creation' unless new_resource.name
  fail ArgumentError, 'Attribute cpg is required for volume creation' unless new_resource.cpg
  fail ArgumentError, 'Attribute size is required for volume creation' unless new_resource.size
  fail ArgumentError, 'Attribute size_unit is required for volume creation' unless new_resource.size_unit

  if !volume_exists?(new_resource.storage_system, new_resource.name)


    op_status = create_volume(new_resource.storage_system, new_resource.name, new_resource.cpg,
                              new_resource.size, new_resource.size_unit, new_resource.type,
                              new_resource.compression, new_resource.snap_cpg)
    new_resource.updated_by_last_action(true) if op_status
  else
    Chef::Log.info("Volume #{new_resource.name} already exists. Nothing to do.")
  end
end

action :delete do
# validations
  fail ArgumentError, 'Attribute storage_system is required for volume deletion' unless new_resource.storage_system
  fail ArgumentError, 'Attribute name is required for volume deletion' unless new_resource.name
  op_status = delete_volume(new_resource.storage_system, new_resource.name)
  new_resource.updated_by_last_action(true) if op_status
end

action :grow do
# validations
  fail ArgumentError, 'Attribute storage_system is required for volume deletion' unless new_resource.storage_system
  fail ArgumentError, 'Attribute name is required for volume deletion' unless new_resource.name
  fail ArgumentError, 'Attribute size is required for volume creation' unless new_resource.size
  fail ArgumentError, 'Attribute size_unit is required for volume creation' unless new_resource.size_unit
  op_status = grow_volume(new_resource.storage_system, new_resource.name,
                          new_resource.size, new_resource.size_unit)
  new_resource.updated_by_last_action(true) if op_status
end

action :change_snap_cpg do
# validations
  fail ArgumentError,
       'Attribute storage_system is required for changing the snap cpg of a volume' unless new_resource.storage_system
  fail ArgumentError,
       'Attribute name is required for changing the snap cpg of a volume' unless new_resource.name
  fail ArgumentError,
       'Attribute snap_cpg is required for changing the snap cpg of a volume' unless new_resource.snap_cpg
  op_status = change_snap_cpg(new_resource.storage_system, new_resource.name,
                              new_resource.snap_cpg, new_resource.wait_for_task_to_end)
  new_resource.updated_by_last_action(true) if op_status
end

action :change_user_cpg do
# validations
  fail ArgumentError,
       'Attribute storage_system is required for changing the user cpg of a volume' unless new_resource.storage_system
  fail ArgumentError,
       'Attribute name is required for changing the user cpg of a volume' unless new_resource.name
  fail ArgumentError,
       'Attribute snap_cpg is required for changing the user cpg of a volume' unless new_resource.cpg
  op_status = change_user_cpg(new_resource.storage_system, new_resource.name,
                              new_resource.cpg, new_resource.wait_for_task_to_end)
  new_resource.updated_by_last_action(true) if op_status
end

action :convert_type do
# validations
  fail ArgumentError,
       'Attribute storage_system is required for changing the type of a volume' unless new_resource.storage_system
  fail ArgumentError,
       'Attribute name is required for changing the type of a volume' unless new_resource.name
  fail ArgumentError,
       'Attribute type is required for changing the type of a volume' unless new_resource.type
  fail ArgumentError,
       'Attribute cpg is required for changing the type of a volume' unless new_resource.cpg
  op_status = convert_volume_type(new_resource.storage_system, new_resource.name, new_resource.cpg,
                                  new_resource.type, new_resource.keep_vv, new_resource.compression,
                                  new_resource.wait_for_task_to_end)
  new_resource.updated_by_last_action(true) if op_status
end

action :modify do
# validations
  fail ArgumentError,
       'Attribute storage_system is required' unless new_resource.storage_system
  fail ArgumentError,
       'Attribute name is required' unless new_resource.name
  op_status = modify_base_volume(new_resource.storage_system, new_resource.name,
                                 new_resource.new_name,
                                 new_resource.expiration_hours,
                                 new_resource.retention_hours,
                                 new_resource.ss_spc_alloc_warning_pct,
                                 new_resource.ss_spc_alloc_limit_pct,
                                 new_resource.usr_spc_alloc_warning_pct,
                                 new_resource.usr_spc_alloc_limit_pct,
                                 new_resource.rm_ss_spc_alloc_warning,
                                 new_resource.rm_usr_spc_alloc_warning,
                                 new_resource.rm_exp_time,
                                 new_resource.rm_usr_spc_alloc_limit,
                                 new_resource.rm_ss_spc_alloc_limit)
  new_resource.updated_by_last_action(true) if op_status
end

action :set_snap_cpg do
# validations
  fail ArgumentError,
       'Attribute storage_system is required' unless new_resource.storage_system
  fail ArgumentError,
       'Attribute name is required' unless new_resource.name
  fail ArgumentError,
       'Attribute snap_cpg is required' unless new_resource.snap_cpg

  op_status = set_snap_cpg(new_resource.storage_system, new_resource.name, new_resource.snap_cpg) 
  new_resource.updated_by_last_action(true) if op_status
end
