#lab-snc-config.sh
 
#Copyright 2022 illumio
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.
 
get_config_yml(){
    source $BASEDIR/.lab-snc-config.yml || get_lab_snc_vars
}

get_lab_snc_vars(){
    echo "Running lab SNC config script..."
    echo "PCE versions:"
    code_versions=($(ls /illumio-repo/))
    version_count=0
    for code_version in "${code_versions[@]}"; do
        ((version_count++))
        echo $version_count") "$code_version
    done
    read -p "Version selection (1-${#code_versions[@]}): " PCE_VERSION_SELECTION
    if ! [[ "$PCE_VERSION_SELECTION" =~ ^[[:digit:]]+$ ]]; then
        echo "ERROR: version selection. Only key in 1-${#code_versions[@]}"
        get_lab_snc_vars
        return 0
    fi
    PCE_VERSION=${code_versions[(($PCE_VERSION_SELECTION-1))]}
    read -p "Enter PCE domain name: " PCE_DOMAIN
    read -p "Enter PCE username email address: " PCE_USERNAME
    echo -n "Enter PCE password (alphanumeric, 8 characters, upper and lower case): " && read -s PCE_PASSWORD
    echo " "
    cat << EOF > $BASEDIR/.lab-snc-config.yml
export PCE_VERSION=$PCE_VERSION
export PCE_DOMAIN=$PCE_DOMAIN
export PCE_USERNAME=$PCE_USERNAME
export PCE_PASSWORD=$PCE_PASSWORD
EOF
}

reset(){
    while true; do
        read -p "Reset PCE? (y/n): " RESET_RESPONSE
        case $RESET_RESPONSE in
            [Yy]* ) break;;
            [Nn]* ) exit 0;;
            * ) echo "Please answer yes or no.";;
        esac
    done
    sudo -u ilo-pce /opt/illumio-pce/illumio-pce-ctl reset --truncate-logs --no-prompt
    rpm -e illumio-pce-ui
    rpm -e illumio-pce
    rm -rf /var/lib/illumio-pce
    rm -rf /var/log/illumio-pce
    rm -rf /etc/illumio-pce
    rm -rf /opt/illumio-pce
    rm -f $BASEDIR/.lab-snc-config.yml
    sed -i '/localhost/!d' /etc/hosts
}

install_and_config(){
    echo " "
    get_config_yml
    #install rpms
    echo "Installing..."
    rpm -Uvh /illumio-repo/$PCE_VERSION/illumio-pce-*.rpm
    error_code=$? && if [ "$error_code" -ne 0 ]; then echo "ERROR: "$error_code && reset && install_and_config && exit 0; fi
    #generate certificate
    ldconfig /usr/local/lib64/
    ls /var/lib/illumio-pce/cert/server.crt | grep server.crt || openssl req -x509 -CAkey /root/root-ca.key -CA /root/root-ca.crt -newkey rsa:2048 -nodes -sha256 -keyout /var/lib/illumio-pce/cert/server.key -out /var/lib/illumio-pce/cert/server.crt -subj '/CN='$PCE_DOMAIN -days 10950
    error_code=$? && if [ "$error_code" -ne 0 ]; then echo "ERROR: "$error_code && exit 1; fi
    openssl x509 -text -noout -in /var/lib/illumio-pce/cert/server.crt
    chmod 400 /var/lib/illumio-pce/cert/server.key
    chown ilo-pce:ilo-pce /var/lib/illumio-pce/cert/server.key
    yes|cp -fu /var/lib/illumio-pce/cert/server.crt /etc/pki/ca-trust/source/anchors/
    update-ca-trust enable && update-ca-trust extract
    #echo ip and hostname to local hosts file
    cat /etc/hosts|grep $PCE_DOMAIN || echo $((ip a ls ens192||ip a ls eth0)|grep 'inet '|cut -d' ' -f 6|cut -d'/' -f1) $(echo $PCE_DOMAIN) >> /etc/hosts
    #setup runtime yaml
    illumio-pce-env setup --batch node_type='snc0' email_address=$PCE_USERNAME pce_fqdn=$PCE_DOMAIN metrics_collection_enabled=false
    error_code=$? && if [ "$error_code" -ne 0 ]; then echo "ERROR: "$error_code && rm -f $BASEDIR/.lab-snc-config.yml && install_and_config && exit 0; fi
    #start pce
    illumio-pce-env setup --list
    illumio-pce-env setup --list --test 5
    sudo -u ilo-pce illumio-pce-ctl start --runlevel 1
    sleep 60
    sudo -u ilo-pce illumio-pce-ctl status -svw
    sleep 10
    sudo -u ilo-pce illumio-pce-ctl status -svw
    sudo -u ilo-pce illumio-pce-db-management setup
    sleep 10
    sudo -u ilo-pce illumio-pce-ctl set-runlevel 5
    sudo -u ilo-pce illumio-pce-ctl status -svw
    sleep 10
    sudo -u ilo-pce illumio-pce-ctl status -svw
    #create domain
    sudo -u ilo-pce ILO_PASSWORD=$PCE_PASSWORD illumio-pce-db-management create-domain --user-name $PCE_USERNAME --full-name admin --org-name $PCE_DOMAIN
    #install ven bundle
    sudo -u ilo-pce illumio-pce-ctl ven-software-install /illumio-repo/$PCE_VERSION/illumio-ven-bundle-* --compatibility-matrix /illumio-repo/$PCE_VERSION/illumio-release-compatibility-* --default --no-prompt --orgs 1 || sudo -u ilo-pce illumio-pce-ctl ven-software-install /illumio-repo/$PCE_VERSION/illumio-ven-bundle-* --default --no-prompt --orgs 1
    echo "Install complete."
}

BASEDIR=$(dirname $0)
bash $BASEDIR/download-bins-from-repo.sh
install_and_config

exit 0