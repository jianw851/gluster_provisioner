for node in node1 node2 node3;
  do scp -r /mnt/heketi/.ssh root@${node}:/mnt/heketi;
done
