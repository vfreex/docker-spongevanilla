FROM openjdk:8-jre-alpine

ARG SPONGE_VERSION=1.10.2-5.2.0-BETA-387
ARG LAUNCHWRAPPER_VERSION=1.12

LABEL \
  name=spongevanilla \
  version="$SPONGE_VERSION" \
  maintainer='Yuxiang Zhu <vfreex@gmail.com>'

ENV SPONGE_WORKSPACE=/var/local/sponge \
  SPONGE_ROOT=/opt/sponge \
  SPONGE_USER=sponge \
  SPONGE_GROUP=sponge \
  SPONGE_VERSION="$SPONGE_VERSION" \
  LAUNCHWRAPPER_VERSION="$LAUNCHWRAPPER_VERSION" \
  JAVA_OPTS='-Xms1G -Xmx2G'

RUN \
  apk update \
  && apk add --virtual build-deps wget ca-certificates \
  # install SpongeVanilla
  && mkdir -p "$SPONGE_ROOT" \
  && wget -O "$SPONGE_ROOT/spongevanilla-$SPONGE_VERSION.jar" https://repo.spongepowered.org/maven/org/spongepowered/spongevanilla/"$SPONGE_VERSION"/spongevanilla-"$SPONGE_VERSION".jar \
  && ln -s "$SPONGE_ROOT/spongevanilla-$SPONGE_VERSION.jar" "$SPONGE_ROOT/spongevanilla.jar" \
  # install Vanilla
  && MINECRAFT_VERSION=$(echo "$SPONGE_VERSION" | cut -d - -f 1) \
  && wget -O "$SPONGE_ROOT/minecraft_server.$MINECRAFT_VERSION.jar" https://s3.amazonaws.com/Minecraft.Download/versions/"$MINECRAFT_VERSION"/minecraft_server."$MINECRAFT_VERSION".jar \
  && LAUNCHWRAPPER_DIR=$SPONGE_ROOT/libraries/net/minecraft/launchwrapper/$LAUNCHWRAPPER_VERSION \
  && mkdir -p "$LAUNCHWRAPPER_DIR" \
  && wget -O "$LAUNCHWRAPPER_DIR/launchwrapper-$LAUNCHWRAPPER_VERSION.jar" \
    "https://libraries.minecraft.net/net/minecraft/launchwrapper/$LAUNCHWRAPPER_VERSION/launchwrapper-$LAUNCHWRAPPER_VERSION.jar" \
  # create user and workspace
  && addgroup -S "$SPONGE_GROUP" \
  && adduser -G "$SPONGE_GROUP" -S "$SPONGE_USER" \
  && mkdir -p "$SPONGE_WORKSPACE" \
  && chown -R "$SPONGE_USER":"$SPONGE_GROUP" "$SPONGE_WORKSPACE" \
  # install utils
  && apk add su-exec tini \
  # clean up
  && apk del build-deps \
  && rm -rf /var/lib/apk/

COPY files/ /

WORKDIR "$SPONGE_WORKSPACE"
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/sbin/entrypoint.sh"]
CMD ["/usr/local/bin/spongevanilla"]
VOLUME "$SPONGE_WORKSPACE"
