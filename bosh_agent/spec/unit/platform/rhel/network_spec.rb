# Copyright (c) 2009-2012 VMware, Inc.

require 'spec_helper'
require 'bosh_agent/platform/rhel/network'

describe Bosh::Agent::Platform::Rhel::Network do
  let(:network_wrapper) { subject }
  let(:complete_settings) do
    settings_json = %q[{"vm":{"name":"vm-273a202e-eedf-4475-a4a1-66c6d2628742","id":"vm-51290"},"disks":{"ephemeral":1,"persistent":{"250":2},"system":0},"mbus":"nats://user:pass@11.0.0.11:4222","networks":{"network_a":{"netmask":"255.255.248.0","mac":"00:50:56:89:17:70","ip":"172.30.40.115","default":["gateway","dns"],"gateway":"172.30.40.1","dns":["172.30.22.153","172.30.22.154"],"cloud_properties":{"name":"VLAN440"}}},"blobstore":{"plugin":"simple","properties":{"password":"Ag3Nt","user":"agent","endpoint":"http://172.30.40.11:25250"}},"ntp":["ntp01.las01.emcatmos.com","ntp02.las01.emcatmos.com"],"agent_id":"a26efbe5-4845-44a0-9323-b8e36191a2c8"}]
    Yajl::Parser.new.parse(settings_json)
  end

  context "vSphere" do
    before do
      Bosh::Agent::Config.infrastructure_name = "vsphere"
      Bosh::Agent::Config.instance_variable_set :@infrastructure, nil
      Bosh::Agent::Config.infrastructure.stub(:load_settings).and_return(complete_settings)
      Bosh::Agent::Config.settings = complete_settings

      Bosh::Agent::Util.stub(:update_file)
      network_wrapper.stub(:gratuitous_arp)
      network_wrapper.stub(detect_mac_addresses: {"00:50:56:89:17:70" => "eth0"})
    end

    it "should generate rhel network files" do
      network_wrapper.stub(:update_file) do |data, file|
        file.should == '/etc/network/interfaces'
        data.should == "auto lo\niface lo inet loopback\n\nauto eth0\niface eth0 inet static\n    address 172.30.40.115\n    network 172.30.40.0\n    netmask 255.255.248.0\n    broadcast 172.30.47.255\n    gateway 172.30.40.1\n\n"
      end
      network_wrapper.should_receive("sh").with("service network restart")

      network_wrapper.setup_networking
    end
  end
end
