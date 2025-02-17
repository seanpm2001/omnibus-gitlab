#
# Copyright 2012-2014 Chef Software, Inc.
# Copyright 2017-2022 GitLab Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'mixlib/shellout'

name 'chef-gem'
# The version here should be in agreement with /Gemfile.lock so that our rspec
# testing stays consistent with the package contents.
default_version '17.10.0'

license 'Apache-2.0'
license_file 'LICENSE'
license_file 'NOTICE'

skip_transitive_dependency_licensing true

dependency 'ruby'
dependency 'rubygems'
dependency 'libffi'
dependency 'rb-readline'

build do
  patch source: "license/add-license-file.patch"
  patch source: "license/add-notice-file.patch"
  env = with_standard_compiler_flags(with_embedded_path)

  gem 'install chef' \
      " --clear-sources" \
      " -s https://packagecloud.io/cinc-project/stable" \
      " -s https://rubygems.org" \
      " --version '#{version}'" \
      " --bindir '#{install_dir}/embedded/bin'" \
      ' --no-document', env: env

  block 'patch Chef files' do
    prefix_path = "#{install_dir}/embedded"
    gem_path = shellout!("#{embedded_bin('ruby')} -e \"puts Gem.path.find { |path| path.start_with?(\'#{prefix_path}\') }\"", env: env).stdout.chomp

    patch source: "Version-17-EOL-detection.patch",
          target: "#{gem_path}/gems/chef-#{version}/lib/chef/client.rb"

    patch source: "utf8-locale-support.patch",
          target: "#{gem_path}/gems/chef-config-#{version}/lib/chef-config/config.rb"
  end
end
