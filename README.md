# phpIPAM dockerized in rootless fashion

For environment variables, please see original [config.docker.php](https://github.com/phpipam/phpipam/blob/master/config.docker.php).

Additionally, the image accepts IPAM_TIMEZONE to set the correct timezone.

As the container runs rootless, http is exposed on port 8080 instead of 80. Otherwise, usage/configuration is similar to [phpipam-www](https://hub.docker.com/r/phpipam/phpipam-www).