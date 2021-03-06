test_name "Test a specific, existing directory environment with an explicit environment.conf file"
require 'puppet/acceptance/environment_utils'
extend Puppet::Acceptance::EnvironmentUtils
require 'puppet/acceptance/classifier_utils'
extend Puppet::Acceptance::ClassifierUtils

classify_nodes_as_agent_specified_if_classifer_present

step "setup environments"

stub_forge_on(master)

testdir = create_tmpdir_for_user master, "confdir"
puppet_conf_backup_dir = create_tmpdir_for_user(master, "puppet-conf-backup-dir")

apply_manifest_on(master, environment_manifest(testdir), :catch_failures => true)

step  "Test"
master_opts = {
  'main' => {
    'environmentpath' => '$confdir/environments',
    'config_version' => '$confdir/static-version.sh',
  }
}
general = [ master_opts, testdir, puppet_conf_backup_dir, { :directory_environments => true } ]

results = use_an_environment("testing_environment_conf", "directory with environment.conf testing", *general)

expectations = {
  :puppet_config => {
    :exit_code => 0,
    :matches => [%r{manifest.*#{master['puppetpath']}/environments/testing_environment_conf/nonstandard-manifests$},
                 %r{modulepath.*#{master['puppetpath']}/environments/testing_environment_conf/nonstandard-modules:.+},
                 %r{config_version = #{master['puppetpath']}/environments/testing_environment_conf/local-version.sh$}]
  },
  :puppet_module_install => {
    :exit_code => 0,
    :matches => [%r{Preparing to install into #{master['puppetpath']}/environments/testing_environment_conf/nonstandard-modules},
                 %r{pmtacceptance-nginx}],
  },
  :puppet_module_uninstall => {
    :exit_code => 0,
    :matches => [%r{Removed.*pmtacceptance-nginx.*from #{master['puppetpath']}/environments/testing_environment_conf/nonstandard-modules}],
  },
  :puppet_apply => {
    :exit_code => 0,
    :matches => [%r{include directory testing with environment\.conf testing_mod}],
  },
  :puppet_agent => {
    :exit_code => 2,
    :matches => [%r{Applying configuration version 'local testing_environment_conf'},
                 %r{in directory testing with environment\.conf site.pp},
                 %r{include directory testing with environment\.conf testing_mod}],
  },
}

review_results(results,expectations)
