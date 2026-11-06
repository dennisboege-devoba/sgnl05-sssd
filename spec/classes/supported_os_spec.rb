# frozen_string_literal: true

require 'spec_helper'

describe 'sssd' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_service('sssd') }

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
      end
    end
  end
end
