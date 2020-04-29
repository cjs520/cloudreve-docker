docker build -t cjs520/cloudreve-docker .
dir=“/root”
read -p "请输入你的安装目录:(默认root) " dir
docker run -itd --name=cloudreve -e PUID=1000   -e PGID=1000 -e TZ="Asia/Shanghai"  -p 5212:5212  --restart=unless-stopped  -v $dir/uploads:/cloudreve/uploads -v $dir/conf.ini:/cloudreve/conf.ini -v $dir/cloudreve.db:/cloudreve/cloudreve.db cjs520/cloudreve-docker

