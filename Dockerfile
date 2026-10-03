FROM arcadiatechnology/crafty-4:4.11.0

USER root

# Guarda a versão da aplicação que veio da imagem.
# /crafty será substituído pelo Volume em runtime.
RUN cp -a /crafty /crafty-image

COPY railway-entrypoint.sh /railway-entrypoint.sh

RUN chmod +x /railway-entrypoint.sh

ENTRYPOINT ["/railway-entrypoint.sh"]
