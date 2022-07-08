require "#{base_path}/embedded/service/omnibus-ctl/lib/gitlab_ctl/upgrade_check"

add_command('upgrade-check', 'Check if the upgrade is acceptable', 2) do
  old_version = ARGV[3]
  new_version = ARGV[4]
  unless GitlabCtl::UpgradeCheck.valid?(old_version, new_version)
    warn "It seems you are upgrading from version #{old_version} to version #{new_version}."
    warn "It is required to upgrade to the latest #{GitlabCtl::UpgradeCheck::MIN_VERSION}.x version first before proceeding."
    warn "Please follow the upgrade documentation at https://docs.gitlab.com/ee/update/index.html"
    Kernel.exit 1
  end
end
