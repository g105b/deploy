#!/bin/bash
old_pwd="$(pwd)"
cd "$(dirname ${BASH_SOURCE[0]})"

required_environment_variables=(
	deploy_ssh
	distribution_directory
)

# Optional variables with defaults:
: ${deploy_tmp:="/tmp/deploy"}
: ${deploy_dir:="/var/deploy"}
: ${post_copy_command:="echo 'No post-copy command set'"}

function check_environment_variable_exists {
	varname=$1
	[ -z "${!varname}" ] && echo "ERROR: Missing environment variable: $varname" && exit 1;
}

for varname in "${required_environment_variables[@]}"
do
	check_environment_variable_exists $varname 
	echo "$varname: ${!varname}"
done

echo "deploy_tmp: $deploy_tmp_path"
echo "deploy_dir: $deploy_dir"
echo "post_copy_command: $post_copy_command"

echo "Streaming distribution directory over SSH to temp directory..."

remote_command__create_deploy_tmp_path="mkdir -p $deploy_dir; cd $deploy_dir"
remote_command__extract_tar="tar -xzvf -"
# TODO: Post-copy commands, including back up of existing deployment.
# Build up remote command from above commands:
remote_command="set -e; $remote_command; $remote_command__create_deploy_tmp_path; $remote_command__extract_tar"

tar -zcf - "$distribution_directory" | "$deploy_ssh" "$remote_command"

echo "Done"
cd "$old_pwd"
