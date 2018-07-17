function checkLinuxDistr {
	cat /etc/os-release | grep -m 1 -i -o $1
}

function configureSSH {
	mkdir $HOME/.ssh || true; echo $PUBL_KEY | base64 -d >> $HOME/.ssh/authorized_keys
	sed -i 's/#Pubkey/Pubkey/' /etc/ssh/sshd_config
}

function installAndRunNgrok {
	curl https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip --output ngrok.zip
	unzip ./ngrok.zip
	./ngrok tcp 22 --authtoken $NGROK_TOKEN --log=stdout > /tmp/ngrok_log & 
	sleep 2
	grep 'Tunnel session failed' /tmp/ngrok_log && exit 1
	curl localhost:4040/status | grep -o '\S.tcp.ngrok.io:[0-9]\+' | awk -F ":" '{print "\nYour SSH command:\n\n ssh root@"$1" -p "$2}'
	while true; do sleep 600 && echo ...Keep alive...; done
}

if [ -z "$NGROK_TOKEN" ]; then echo "The ngrok token is not provided!" && exit 1; fi
#if [ -z "$PUBL_KEY" ]; then echo "The public key is not provided!" && exit 1; fi

if [ $(checkLinuxDistr alpine) ]; then
	apk update && apk add openssh curl unzip
	configureSSH
	ssh-keygen -A && /usr/sbin/sshd
	installAndRunNgrok
else
	apt-get update && apt-get install curl unzip openssh-server -y
	configureSSH
	service ssh start
	installAndRunNgrok
fi
