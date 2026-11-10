# frozen_string_literal: true

require 'spec_helper'

describe 'sssd' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_service('sssd') }

      # Match the ownership the sssd package itself applies, so the service
      # restart on every run goes away.
      case [os_facts[:os]['name'], os_facts[:os]['release']['major']]
      when %w[SLES 15]
        it { is_expected.to contain_file('sssd.conf').with(owner: 'root', group: 'sssd', mode: '0640') }
      when %w[Debian 13]
        it { is_expected.to contain_file('sssd.conf').with(owner: 'root', group: 'root', mode: '0640') }
      else
        it { is_expected.to contain_file('sssd.conf').with(owner: 'root', group: 'root', mode: '0600') }
      end

      case os_facts[:os]['family']
      when 'RedHat'
        it { is_expected.to contain_package('authselect') }
        it { is_expected.to contain_package('oddjob-mkhomedir') }
        it { is_expected.to contain_exec('authselect-mkhomedir').with_command('/bin/authselect select sssd with-mkhomedir --force') }
      when 'Debian'
        it { is_expected.to contain_package('libpam-sss') }
        it { is_expected.to contain_exec('pam-auth-update') }
      when 'Suse'
        it { is_expected.to contain_exec('pam-config -a --mkhomedir') }
        it { is_expected.to contain_package('sssd-ldap') }
        it { is_expected.not_to contain_package('sssd-32bit') }
        it { is_expected.to contain_exec('nsswitch-sss').that_requires('Package[sssd]') }
      end
    end
  end
end
