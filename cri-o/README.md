### support cri-o

crio need cni plugins 

if you need using other cni plugins

I recommend you remove the default /etc/cni/net.d/100-crio-bridge.conf if you're using calico

We have dropped the bridge plugin installing by default in cri-o 1.24.0, so this should work better now

https://github.com/cri-o/cri-o/issues/5799
