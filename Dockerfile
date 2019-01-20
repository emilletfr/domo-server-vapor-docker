

FROM helje5/rpi-swift:4.1.2
MAINTAINER Eric Millet <emilletfr@gmail.com>

RUN mkdir /app
WORKDIR /app
COPY . /app
RUN swift build -c release
EXPOSE 8080
CMD .build/release/Run serve --hostname "0.0.0.0"
