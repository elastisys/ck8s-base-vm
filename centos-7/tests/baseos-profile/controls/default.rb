# Check binaries
describe command('which docker') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match('/usr/bin/docker') }
end

ck8s_binaries = ['kubectl', 'kubeadm', 'kubelet']
ck8s_binaries.each do |ck8s_binary|
  describe command(ck8s_binary).exist? do
    it { should eq true }
  end
end

# Verify control-plane ports. See: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/
tcp_ports = [2379, 2380, 6443, 10250, 10251, 10252]
tcp_ports.each do |tcp_port|
  describe port(tcp_port) do
    it {should be_listening}
    its('protocols') {should be_in ['tcp', 'tcp6']}
  end
end