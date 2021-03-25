FROM ubuntu:latest

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM=dumb \
    DEBIAN_FRONTEND=noninteractive

ENV ANDROID_HOME="/opt/android-sdk" \
    JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/"

ENV TZ=America/Los_Angeles

# Get the latest version from https://developer.android.com/studio/index.html
ENV ANDROID_SDK_TOOLS_VERSION="4333796"

# Set locale
ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8"

RUN apt-get clean && \
    apt-get update -qq && \
    apt-get install -qq -y apt-utils software-properties-common locales  && \
    locale-gen $LANG

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM=dumb \
    DEBIAN_FRONTEND=noninteractive

# Variables must be references after they are created
ENV ANDROID_SDK_HOME="$ANDROID_HOME"

ENV PATH="$JAVA_HOME/bin:$PATH:$ANDROID_SDK_HOME/emulator:$ANDROID_SDK_HOME/tools/bin:$ANDROID_SDK_HOME/tools:$ANDROID_SDK_HOME/platform-tools"

WORKDIR /tmp

# Installing packages
RUN add-apt-repository ppa:git-core/ppa > /dev/null && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0 > /dev/null && \
    apt-add-repository https://cli.github.com/packages > /dev/null && \
    apt-get update -qq > /dev/null && \
    apt-get install -qq locales > /dev/null && \
    locale-gen "$LANG" > /dev/null && \
    apt-get install -qq --no-install-recommends \
        autoconf \
        build-essential \
        curl \
        file \
        git \
        m4 \
        ncurses-dev \
        openjdk-11-jdk \
        unzip \
        vim-tiny \
        wget \
        zip \
        gh \
        ruby rubygems-integration \
        zlib1g-dev > /dev/null && \
    echo "set timezone" && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    rm -rf /tmp/* /var/tmp/* && \
    gem install github_changelog_generator > /dev/null 


# Install Android SDK
RUN echo "sdk tools ${ANDROID_SDK_TOOLS_VERSION}" && \
    wget --quiet --output-document=sdk-tools.zip \
        "https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS_VERSION}.zip" && \
    mkdir --parents "$ANDROID_HOME" && \
    unzip -q sdk-tools.zip -d "$ANDROID_HOME" && \
    rm --force sdk-tools.zip

# Install SDKs
# Please keep these in descending order!
# The `yes` is for accepting all non-standard tool licenses.
RUN mkdir --parents "$HOME/.android/" && \
    echo '### User Sources for Android SDK Manager' > \
        "$HOME/.android/repositories.cfg" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager --licenses > /dev/null

RUN echo "platforms" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "platforms;android-30" \
        "platforms;android-29" > /dev/null

# RUN echo "platform tools" && \
#     yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
#         "platform-tools" > /dev/null

RUN echo "build tools 29-30" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "build-tools;30.0.0" "build-tools;30.0.1" "build-tools;30.0.3" "build-tools;30.0.3" \
        "build-tools;29.0.3" "build-tools;29.0.2" > /dev/null

# RUN echo "emulator" && \
#     yes | "$ANDROID_HOME"/tools/bin/sdkmanager "emulator" > /dev/null

# Copy sdk license agreement files.
RUN mkdir -p $ANDROID_HOME/licenses
COPY sdk/licenses/* $ANDROID_HOME/licenses/
