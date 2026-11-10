# frozen_string_literal: true

require 'spec_helper'

describe 'sssd with an LDAP domain' do
  describe service('sssd') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  describe command('getent passwd testuser') do
    its(:stdout) { is_expected.to match(%r{^testuser:.*:10001:10001:.*:/home/testuser:/bin/bash$}) }
  end

  describe command('id -nG testuser') do
    its(:stdout) { is_expected.to match(%r{\btestgroup\b}) }
  end

  if File.executable?('/usr/bin/pamtester')
    describe command('echo wrong | pamtester login testuser authenticate') do
      its(:exit_status) { is_expected.not_to eq 0 }
    end

    describe command('echo secret | pamtester login testuser authenticate open_session') do
      its(:exit_status) { is_expected.to eq 0 }
    end
  else
    # SLES has no pamtester; su reads the password from a terminal, and only
    # after its prompt, hence script and the delay.
    su = "runuser -u nobody -- script -qec 'su -l -c true testuser' /dev/null"

    describe command("(sleep 2; echo wrong) | #{su}") do
      its(:exit_status) { is_expected.not_to eq 0 }
    end

    describe command("(sleep 2; echo secret) | #{su}") do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end

  describe file('/home/testuser') do
    it { is_expected.to be_directory }
    it { is_expected.to be_owned_by 'testuser' }
  end
end
