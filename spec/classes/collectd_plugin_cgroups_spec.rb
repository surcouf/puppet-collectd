require 'spec_helper'

describe 'collectd::plugin::cgroups', type: :class do
  on_supported_os(baseline_os_hash).each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      let :pre_condition do
        'include collectd'
      end

      options = os_specific_options(facts)

      context ':ensure => present, default params' do
        it "Will create #{options[:plugin_conf_dir]}/10-cgroups.conf" do
          is_expected.to contain_file('cgroups.load').with(
            ensure: 'present',
            path: "#{options[:plugin_conf_dir]}/10-cgroups.conf",
            content: %r{# Generated by Puppet\n<LoadPlugin cgroups>\n  Globals false\n</LoadPlugin>\n\n<Plugin cgroups>\n  IgnoreSelected false\n</Plugin>}
          )
        end
      end

      context ':ensure => present, specific params, collectd version 5.4.0' do
        let :facts do
          facts.merge(collectd_version: '5.4.0')
        end
        let :params do
          {
            cgroups: ['/var/lib/test1', '/var/lib/test2'],
            ensure: 'present',
            ignore_selected: true
          }
        end

        it "Will create #{options[:plugin_conf_dir]}/10-cgroups.conf for collectd >= 5.4" do
          is_expected.to contain_file('cgroups.load').with(
            ensure: 'present',
            path: "#{options[:plugin_conf_dir]}/10-cgroups.conf",
            content: %r{# Generated by Puppet\n<LoadPlugin cgroups>\n  Globals false\n</LoadPlugin>\n\n<Plugin cgroups>\n  CGroup "/var/lib/test1"\n  CGroup "/var/lib/test2"\n  IgnoreSelected true\n</Plugin>}
          )
        end
      end

      context ':ensure => absent' do
        let :params do
          { ensure: 'absent' }
        end

        it "Will not create #{options[:plugin_conf_dir]}/10-cgroups.conf" do
          is_expected.to contain_file('cgroups.load').with(
            ensure: 'absent',
            path: "#{options[:plugin_conf_dir]}/10-cgroups.conf"
          )
        end
      end
    end
  end
end
