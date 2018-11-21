# fluentd image based on alpine
FROM fluent/fluentd:v1.0-onbuild

# install github.com/awslabs/aws-fluent-plugin-kinesis
# install curl for container health check

RUN apk add --update --virtual .build-deps \
        sudo build-base ruby-dev \
 && sudo gem install \
        fluent-plugin-kinesis \
 && sudo gem sources --clear-all \
 && apk add curl \
 && apk del .build-deps \
 && rm -rf /var/cache/apk/* \
           /home/fluent/.gem/ruby/2.4.0/cache/*.gem
