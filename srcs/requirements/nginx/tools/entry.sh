#!/bin/bash

# NGINX como Ponto de Entrada

#     Ponto de Entrada Único: O NGINX deve ser configurado como o único ponto de entrada para sua infraestrutura. Isso significa que todas 
#     as solicitações externas para seus serviços devem passar pelo contêiner NGINX. 
#     Essa abordagem centraliza o gerenciamento do tráfego, permitindo melhor controle e segurança.

#     Conexões Apenas pela Porta 443: A porta 443 é a porta padrão para HTTPS, que é a versão segura do HTTP. 
#     Permitir conexões apenas por essa porta ajuda a proteger os dados transmitidos entre o cliente e o servidor, pois o tráfego será criptografado. 
#     Ao restringir o acesso a essa porta, você evita que conexões não seguras (HTTP, que usa a porta 80) sejam estabelecidas, 
#     aumentando a segurança da sua aplicação.

#     Uso de TLSv1.2 ou TLSv1.3: TLS (Transport Layer Security) é um protocolo que fornece segurança nas comunicações pela internet. 
#     O TLSv1.2 e o TLSv1.3 são versões modernas e seguras do protocolo, oferecendo melhor proteção contra ataques. Usar uma dessas versões 
#     assegura que as comunicações entre o cliente e o servidor sejam criptografadas e que os dados não possam ser interceptados ou manipulados por terceiros.

# Benefícios dessa Abordagem

#     Segurança: Com o NGINX controlando o acesso, você pode implementar autenticação, limitar o tráfego, aplicar regras de firewall 
#     e usar certificados SSL/TLS para proteger os dados.
#     Desempenho: O NGINX é conhecido por sua alta eficiência e capacidade de lidar com grandes volumes de tráfego, 
#     atuando como um balanceador de carga e melhorando a performance geral.
#     Escalabilidade: Centralizar o tráfego através do NGINX facilita a adição de novos serviços ou contêineres 
#     sem alterar a configuração da rede ou o acesso externo.

# Resumo

# Configurar o NGINX como o único ponto de entrada pela porta 443, utilizando TLS, é uma prática recomendada para garantir a segurança 
# e eficiência da sua infraestrutura de contêineres. Essa configuração não só protege os dados em trânsito, 
# mas também centraliza o gerenciamento de acessos e otimiza o desempenho do sistema.

certify_path="/etc/ssl/private/$DOMAIN"

openssl req -x509 -nodes -out $certify_path.csr -keyout $certify_path.key \
            -subj "/C=PT/ST=OPO/L=Porto/O=42/OU=42/CN=$DOMAIN/UID=$DOMAIN_NAME"

echo "
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name www.$DOMAIN $DOMAIN;

    ssl_protocols TLSv1.3;

    ssl_certificate $certify_path.csr;
    ssl_certificate_key $certify_path.key;

    root $WP_DIR;
    index index.html index.php index.htm index.nginx-debian.html;

    location / {
        try_files \$uri \$uri/ /index.html\$is_args\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass wordpress:9000;
    }
}
" >  /etc/nginx/sites-available/default



nginx -t

nginx -g "daemon off;"
