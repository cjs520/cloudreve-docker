FROM golang:1.14.1-alpine3.11 as builder

ARG CLOUDREVE_VERSION="3.0.0"

WORKDIR /ProjectCloudreve
RUN apk add openssh \
     && echo "root:Docker!" | chpasswd
   
RUN apk update \
    && apk add git yarn build-base gcc abuild binutils binutils-doc gcc-doc

RUN git clone --recurse-submodules https://github.com/cloudreve/Cloudreve.git

RUN cd ./Cloudreve/assets \
    && yarn install --network-timeout 100000 \
    && yarn run build

RUN cd ./Cloudreve \
    && go get github.com/rakyll/statik \
    && statik -src=assets/build/ -include=*.html,*.js,*.json,*.css,*.png,*.svg,*.ico -f \
    && git checkout ${CLOUDREVE_VERSION} \
    && export COMMIT_SHA=$(git rev-parse --short HEAD) \
    && go build -a -o cloudreve -ldflags " -X 'github.com/HFO4/cloudreve/pkg/conf.BackendVersion=$CLOUDREVE_VERSION' -X 'github.com/HFO4/cloudreve/pkg/conf.LastCommit=$COMMIT_SHA'"

FROM  alpine:3.11

ENV PUID=1000
ENV PGID=1000
ENV TZ="Asia/Shanghai"

LABEL MAINTAINER="Lones jay"

WORKDIR /cloudreve

COPY --from=builder /ProjectCloudreve/Cloudreve/cloudreve ./

RUN echo ">>>>>> update dependencies" \
    && apk update && apk add tzdata \
    && echo ">>>>>> set up timezone" \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && echo ">>>>>> clean up" \
    && apk del tzdata \
    && chmod +x ./cloudreve 

VOLUME ["/cloudreve/uploads", "/downloads","/cloudreve/conf.ini", "/cloudreve/cloudreve.db"]

EXPOSE 5212 80 2222

ENTRYPOINT ["./cloudreve &&/usr/sbin/sshd"]
