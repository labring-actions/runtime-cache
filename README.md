# runtime

* __[containerd](https://github.com/containerd/containerd)__
* __[cri-o](https://github.com/cri-o/cri-o)__
* __[docker](https://github.com/moby/moby)__ with [cri-dockerd](https://github.com/Mirantis/cri-dockerd)

支持的内置环境变量：

- SEALOS_SYS_CRI_ENDPOINT: cri的Unix套接字地址
- SEALOS_SYS_CRI_RUNTIME: cri runtime的类别（runc,crun等）
- SEALOS_SYS_SANDBOX_IMAGE: cri的sandbox镜像地址
