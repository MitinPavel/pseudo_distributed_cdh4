require_relative 'spec_helper'

describe 'pseudo_distributed_cdh4::default' do
  context 'on ubuntu' do
    let(:chef_run) { ChefSpec::ChefRunner.new.converge('pseudo_distributed_cdh4::default') }

    before {  Fauxhai.mock(platform: 'ubuntu', version: '12.04') }

    it 'installs hadoop-0.20-conf-pseudo' do
      chef_run.should install_package('hadoop-0.20-conf-pseudo')
    end
  end
end
