Запуск эфимерного контейнера (ephemeral debug container)
```
# kubectl debug -it nginx-distroless-pod --image=nicolaka/netshoot --share-processes --target=nginx-distroless-container -- /bin/sh
```

-------
Вывод процессов в эфимерном контейнере
```
# ps -a
PID   USER     TIME  COMMAND
    1 root      0:00 nginx: master process nginx -g daemon off;
    7 101       0:00 nginx: worker process
    8 root      0:00 /bin/sh
   14 root      0:00 ps -a
```
-------

Вывод файлов целевого контейнера из эфимерного
```
# ls -la /proc/1/root/etc/nginx/
total 48
drwxr-xr-x    3 root     root          4096 Oct  5  2020 .
drwxr-xr-x    1 root     root          4096 Nov 30 12:46 ..
drwxr-xr-x    2 root     root          4096 Oct  5  2020 conf.d
-rw-r--r--    1 root     root          1007 Apr 21  2020 fastcgi_params
-rw-r--r--    1 root     root          2837 Apr 21  2020 koi-utf
-rw-r--r--    1 root     root          2223 Apr 21  2020 koi-win
-rw-r--r--    1 root     root          5231 Apr 21  2020 mime.types
lrwxrwxrwx    1 root     root            22 Apr 21  2020 modules -> /usr/lib/nginx/modules
-rw-r--r--    1 root     root           643 Apr 21  2020 nginx.conf
-rw-r--r--    1 root     root           636 Apr 21  2020 scgi_params
-rw-r--r--    1 root     root           664 Apr 21  2020 uwsgi_params
-rw-r--r--    1 root     root          3610 Apr 21  2020 win-utf
```
-------

Вывод Конфигурации Nginx из целевого контейнера
```
# cat /proc/1/root/etc/nginx/nginx.conf

user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
```
------
Мониторинг трафика целевого контейноа

```
# kubectl debug -it nginx-distroless-pod --image=nicolaka/netshoot --share-processes --target=nginx-distroless-container -- /bin/sh

# tcpdump -nn -i any -e port 80
tcpdump: data link type LINUX_SLL2
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
13:24:08.374384 eth0  In  ifindex 2 d2:6f:f7:7c:14:30 ethertype IPv4 (0x0800), length 80: 10.42.0.185.50936 > 10.42.0.201.80: Flags [S], seq 3248701222, win 64860, options [mss 1410,sackOK,TS val 2086295179 ecr 0,nop,wscale 7], length 0
13:24:08.374532 eth0  Out ifindex 2 7a:81:08:b2:7a:72 ethertype IPv4 (0x0800), length 80: 10.42.0.201.80 > 10.42.0.185.50936: Flags [S.], seq 2301028855, ack 3248701223, win 64308, options [mss 1410,sackOK,TS val 1798905685 ecr 2086295179,nop,wscale 7], length 0
13:24:08.374581 eth0  In  ifindex 2 d2:6f:f7:7c:14:30 ethertype IPv4 (0x0800), length 72: 10.42.0.185.50936 > 10.42.0.201.80: Flags [.], ack 1, win 507, options [nop,nop,TS val 2086295180 ecr 1798905685], length 0
13:24:08.374627 eth0  In  ifindex 2 d2:6f:f7:7c:14:30 ethertype IPv4 (0x0800), length 698: 10.42.0.185.50936 > 10.42.0.201.80: Flags [P.], seq 1:627, ack 1, win 507, options [nop,nop,TS val 2086295180 ecr 1798905685], length 626: HTTP: GET / HTTP/1.1
13:24:08.374631 eth0  Out ifindex 2 7a:81:08:b2:7a:72 ethertype IPv4 (0x0800), length 72: 10.42.0.201.80 > 10.42.0.185.50936: Flags [.], ack 627, win 501, options [nop,nop,TS val 1798905685 ecr 2086295180], length 0
13:24:08.374721 eth0  Out ifindex 2 7a:81:08:b2:7a:72 ethertype IPv4 (0x0800), length 252: 10.42.0.201.80 > 10.42.0.185.50936: Flags [P.], seq 1:181, ack 627, win 501, options [nop,nop,TS val 1798905685 ecr 2086295180], length 180: HTTP: HTTP/1.1 304 Not Modified
13:24:08.374757 eth0  In  ifindex 2 d2:6f:f7:7c:14:30 ethertype IPv4 (0x0800), length 72: 10.42.0.185.50936 > 10.42.0.201.80: Flags [.], ack 181, win 506, options [nop,nop,TS val 2086295180 ecr 1798905685], length 0
13:25:08.376013 eth0  In  ifindex 2 d2:6f:f7:7c:14:30 ethertype IPv4 (0x0800), length 72: 10.42.0.185.50936 > 10.42.0.201.80: Flags [F.], seq 627, ack 181, win 506, options [nop,nop,TS val 2086355181 ecr 1798905685], length 0
13:25:08.376084 eth0  Out ifindex 2 7a:81:08:b2:7a:72 ethertype IPv4 (0x0800), length 72: 10.42.0.201.80 > 10.42.0.185.50936: Flags [F.], seq 181, ack 628, win 501, options [nop,nop,TS val 1798965686 ecr 2086355181], length 0
13:25:08.376118 eth0  In  ifindex 2 d2:6f:f7:7c:14:30 ethertype IPv4 (0x0800), length 72: 10.42.0.185.50936 > 10.42.0.201.80: Flags [.], ack 182, win 506, options [nop,nop,TS val 2086355181 ecr 1798965686], length 0
^C
10 packets captured
10 packets received by filter
0 packets dropped by kernel
```
------
Нода на котой развёрнут Pod
```
kubectl get pod nginx-distroless-pod -o jsonpath='{.spec.nodeName}'
```
------
Эфимерный контейнер для ноды
```
kubectl debug node/k3s -it --image=busybox -- /bin/sh
```
------
Файловая система ноды
```
# ls -la /host/root/lessons/kube-state-metrics/
total 264
drwxr-xr-x   13 root     root          4096 Sep 20 11:40 .
drwxr-xr-x    8 root     root          4096 Oct 11 11:15 ..
drwxr-xr-x    8 root     root          4096 Sep 20 14:30 .git
drwxr-xr-x    4 root     root          4096 Sep 20 11:40 .github
-rw-r--r--    1 root     root           513 Sep 20 11:40 .gitignore
-rw-r--r--    1 root     root           692 Sep 20 11:40 .golangci.yml
-rw-r--r--    1 root     root           991 Sep 20 11:40 .markdownlint-cli2.jsonc
drwxr-xr-x    3 root     root          4096 Sep 20 11:40 .openvex
-rw-r--r--    1 root     root         40292 Sep 20 11:40 CHANGELOG.md
-rw-r--r--    1 root     root          3223 Sep 20 11:40 CONTRIBUTING.md
-rw-r--r--    1 root     root           457 Sep 20 11:40 Dockerfile
-rw-r--r--    1 root     root         11357 Sep 20 11:40 LICENSE
-rw-r--r--    1 root     root          1900 Sep 20 11:40 MAINTAINER.md
-rw-r--r--    1 root     root          8187 Sep 20 11:40 Makefile
-rw-r--r--    1 root     root           225 Sep 20 11:40 OWNERS
-rw-r--r--    1 root     root         24647 Sep 20 11:40 README.md
-rw-r--r--    1 root     root         24788 Sep 20 11:40 README.md.tpl
-rw-r--r--    1 root     root          2629 Sep 20 11:40 RELEASE.md
-rw-r--r--    1 root     root          2226 Sep 20 11:40 SECURITY-INSIGHTS.yml
-rw-r--r--    1 root     root          1069 Sep 20 11:40 SECURITY.md
-rw-r--r--    1 root     root           543 Sep 20 11:40 SECURITY_CONTACTS
-rw-r--r--    1 root     root           318 Sep 20 11:40 cloudbuild.yaml
-rw-r--r--    1 root     root           148 Sep 20 11:40 code-of-conduct.md
-rw-r--r--    1 root     root           478 Sep 20 11:40 data.yaml
drwxr-xr-x    5 root     root          4096 Sep 20 11:40 docs
drwxr-xr-x    6 root     root          4096 Sep 20 11:40 examples
-rw-r--r--    1 root     root          4384 Sep 20 11:40 go.mod
-rw-r--r--    1 root     root         23787 Sep 20 11:40 go.sum
drwxr-xr-x    4 root     root          4096 Sep 20 11:40 internal
drwxr-xr-x    4 root     root          4096 Sep 20 11:40 jsonnet
-rw-r--r--    1 root     root           229 Sep 20 11:40 kustomization.yaml
-rw-r--r--    1 root     root          1160 Sep 20 11:40 main.go
drwxr-xr-x   18 root     root          4096 Sep 20 11:40 pkg
drwxr-xr-x    2 root     root          4096 Sep 20 11:40 scripts
drwxr-xr-x    6 root     root          4096 Sep 20 11:40 tests
drwxr-xr-x    2 root     root          4096 Sep 20 11:40 tools
```
-------
Логи которые распологаются на ноде целевого контейнера из эфимерного
```
# ls -la /host/var/log/containers/nginx-distroless-pod_default_nginx-distroless-container-3e93df68e448b56301a4a11740fdc47420ce73e63095554ce6d382335985cc69.log
lrwxrwxrwx    1 root     root           112 Nov 30 12:46 /host/var/log/containers/nginx-distroless-pod_default_nginx-distroless-container-3e93df68e448b56301a4a11740fdc47420ce73e63095554ce6d382335985cc69.log -> /var/log/pods/default_nginx-distroless-pod_b07e18d5-8eae-41d7-8e1f-c329a23fb801/nginx-distroless-container/0.log

/ # cat /host/var/log/pods/default_nginx-distroless-pod_b07e18d5-8eae-41d7-8e1f-c329a23fb801/nginx-distroless-container/0.log
2024-11-30T12:57:27.503711475Z stdout F 10.42.0.185 - - [30/Nov/2024:20:57:27 +0800] "GET / HTTP/1.1" 200 612 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:133.0) Gecko/20100101 Firefox/133.0" "10.42.0.1"
2024-11-30T12:57:27.641491692Z stderr F 2024/11/30 20:57:27 [error] 7#7: *1 open() "/usr/share/nginx/html/favicon.ico" failed (2: No such file or directory), client: 10.42.0.185, server: localhost, request: "GET /favicon.ico HTTP/1.1", host: "nd.homework.otus", referrer: "http://nd.homework.otus/"
2024-11-30T12:57:27.641527192Z stdout F 10.42.0.185 - - [30/Nov/2024:20:57:27 +0800] "GET /favicon.ico HTTP/1.1" 404 153 "http://nd.homework.otus/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:133.0) Gecko/20100101 Firefox/133.0" "10.42.0.1"
2024-11-30T13:24:08.374861447Z stdout F 10.42.0.185 - - [30/Nov/2024:21:24:08 +0800] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:133.0) Gecko/20100101 Firefox/133.0" "10.42.0.1"
```

-------
Трасеровка процесса
```
echo 0 > /proc/sys/kernel/yama/ptrace_scope

kubectl debug -it nginx-distroless-pod --image=nicolaka/netshoot --share-processes --target=nginx-distroless-container -- /bin/sh

Targeting container "nginx-distroless-container". If you don't see processes from this container it may be because the container runtime doesn't support this feature.
Defaulting debug container name to debugger-5qd74.
If you don't see a command prompt, try pressing enter.
~ # ps
PID   USER     TIME  COMMAND
    1 root      0:00 nginx: master process nginx -g daemon off;
    7 bird      0:00 nginx: worker process
   26 root      0:00 /bin/sh
   32 root      0:00 ps
~ # strace -p 1
strace: Process 1 attached
rt_sigsuspend([], 8
```
