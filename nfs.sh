helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install mailu-nfs  -n mailu-mailserver  --create-namespace  nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set image.repository=scjtqs/k8s \
    --set image.tag=nfs-subdir-external-provisioner-v4.0.2 \
    --set nfs.server=10.0.0.10 \
    --set nfs.path=/data/share/k8s/mailu  --set storageClass.name=mailu-nfs  --set storageClass.provisionerName=mailu-nfs
