# DP5
Dit project realiseert de volledige Azure cloud-infrastructuur voor Powerplay
De infrastructuur is volledig geautomatiseerd via Terraform, CloudInit en Ansible

## Inhoud
* [Vereisten](#vereisten)
* [Opbouw IaC](#opbouw-iac)
* [Terraform opzet](#terraform-opzet)
* [Ansible opzet](#ansible-opzet)
* [Aanpassen voor eigen gebruik](#aanpassen-voor-eigen-gebruik)
* [Installatie](#installatie)
* [Verificatie](#verificatie)
* [Bekende beperkingen](#bekende-beperkingen)

---

## Vereist
- Terraform >= 1.4.0
- Ansible >= 2.12
- Azure CLI (ingelogd via `az login`)
- SSH keypair op `~/.ssh/id_azure` en `~/.ssh/id_azure.pub`

## Opbouw IaC
```
├── c2-dp5-applicaties
│   ├── matchmaking-api
│   │   ├── Dockerfile
│   │   └── server.js
│   ├── player-dashboard
│   │   ├── Dockerfile
│   │   └── server.js
│   └── telemetry-collector
│       ├── Dockerfile
│       └── server.js
├── ansible
│   ├── inventory-gameservers.ini
│   ├── inventory-vpn.ini
│   ├── ansible.cfg
│   ├── gameserver.yml
│   ├── vpn-bgp.yml
│   └── templates
│       └── frr.conf.j2
├── modules
│   ├── network
│   ├── vm
│   ├── acr
│   ├── aci
│   ├── storage
│   ├── monitoring
│   └── vpn
├── main.tf
├── variables.tf
├── outputs.tf
└── cloud-init.yaml
```
---

## Terraform opzet

De infrastructuur is opgebouwd met Terraform modules. Elke module heeft een eigen
functie en bevat een `main.tf`, `variables.tf` en `outputs.tf`.
Alle modules worden centraal aangeroepen vanuit de root `main.tf`.

### Module network
De module `network` richt een Azure Virtual Network in met het adresblok `10.1.0.0/16`.
Het netwerk is gesegmenteerd in vijf subnets voor verschillende workloads:
`sb-frontend` voor ACI platformdiensten, `sb-gameserver` voor de game server VMs,
`sb-mgmt` voor beheertoegang via Bastion, `sb-telemetry` voor de Telemetry Collector
en `sb-vpn` voor de VPN router. Elke subnet heeft een eigen NSG (Network Security Group)
op basis van least-privilege — SSH toegang is bijvoorbeeld alleen toegestaan vanuit
het management subnet.

### Module vm
De module `vm` deployt twee gameserver VMs van het type `Standard_F2s_v2` met Ubuntu 24.04.
De VMs worden verdeeld over Availability Zone 1 en 2 voor hoge beschikbaarheid.
Elke VM krijgt een 32GB managed data disk voor game world opslag gemount op `/mnt/gamedata`.
Docker wordt geïnstalleerd via cloud-init bij de eerste boot. Na de deploy wordt automatisch
een Ansible inventory bestand gegenereerd met de juiste publieke IPs.

### Module acr
De module `acr` maakt een Azure Container Registry aan met admin toegang ingeschakeld.
Na het aanmaken van de registry worden de drie applicatie images automatisch gebouwd
en gepusht via `az acr build` zodat docker lokaal niet nodig is.
Dit gebeurt via een `null_resource` met een `local-exec` provisioner die de buildtaken
in serie uitvoert.

### Module aci
De module `aci` deployt drie containergroepen op Azure Container Instances:
de `matchmaking-api` voor sessiebeheer, het `player-dashboard` als webinterface
voor spelerstatistieken en de `telemetry-collector` voor het verzamelen van logs.
De images worden opgehaald uit de ACR.
Elke containergroep heeft een publiek IP en een DNS label om ze te bereiken.

### Module storage
De module `storage` maakt een Azure Storage Account aan met Zone-Redundant Storage (ZRS).
Er worden twee blob containers aangemaakt: `gamelogs` voor
logbestanden en `world-snapshots` voor game world snapshots. Daarnaast wordt
een Azure File Share `gameconfigs` aangemaakt die via SMB gemount wordt op de
game server VMs.

### Module monitoring
De module `monitoring` richt twee Azure Monitor Metric Alerts in. 
De eerste alert triggert bij gemiddeld CPU gebruik
van meer dan 80% op de game server VMs over een periode van 15 minuten. De tweede alert
triggert wanneer de storage account capaciteit boven de 80% komt.

### Module vpn
De module `vpn` deployt een Ubuntu VM (`Standard_DS1_v2`) als VPN router in het
`sb-vpn` subnet. Via cloud-init worden strongSwan en FRR geïnstalleerd en
geconfigureerd bij de eerste boot. strongSwan verzorgt de IPsec tunnel naar de
Skylab pfSense, FRR stelt een BGP tunnel sessie in.
Na de deploy wordt automatisch een Ansible inventory bestand gegenereerd.

---

## Ansible opzet

Ansible wordt gebruikt voor de verdere configuratie van de VMs na de Terraform deploy.
Er zijn twee playbooks: een voor de game servers en een voor de VPN router.

### gameserver.yml
Stelt beide game server VMs in: formatteert en mount de data disk op `/mnt/gamedata`,
installeert benodigde packages, configureert UFW firewall regels conform de NSG regels,
controleert of Docker actief is en mount de Azure File Share op `/mnt/gameconfigs`.

### vpn-bgp.yml
Configureert FRR BGP op de VPN router via een "Jinja2" template. De ontwerpkeuzes
zoals AS nummers, peer IP en prefix zijn als Ansible variabelen
in het playbook gezet. De FRR configuratie wordt via een template gegenereerd en gedeployt,
waarna de BGP sessie automatisch opkomt over de bestaande IPsec tunnel.

---

## Aanpassen voor eigen gebruik
Pas de volgende waarden aan voordat je de code deployt:

| Bestand                       | Waarde                                    | Omschrijving 
|-------------------------------|-------------------------------------------|--------------
| `main.tf`                     | `c064671c-8f74-4fec-b088-b53c568245eb`    | Azure Subscription ID
| `main.tf`                     | `s1202501`                                | Resource Group naam
| `variables.tf`                | `DP5`                                     | Naamprefix voor alle resources
| `variables.tf`                | `~/.ssh/id_azure.pub`                     | Pad naar SSH public key
| `modules/vpn/variables.tf`    | `145.44.233.88`                           | Skylab WAN IP
| `modules/vpn/variables.tf`    | `Powerplay2026StrongKey!`                 | IPsec Pre-Shared Key
| `modules/network/main.tf`     | `145.44.233.88/32`                        | Skylab WAN IP in NSG regels
| `ansible/vpn-bgp.yml`         | `65002`                                   | Azure AS nummer
| `ansible/vpn-bgp.yml`         | `65001`                                   | Skylab BGP AS nummer
| `ansible/vpn-bgp.yml`         | `192.168.1.1`                             | Skylab pfSense LAN IP
| `ansible/vpn-bgp.yml`         | `10.1.0.0/16`                             | Eigen VNet CIDR
| `ansible/gameserver.yml`      | `dp5storageprod`                          | Storage account naam
| `ansible/gameserver.yml`      | `s1202501`                                | Resource Group naam
| `modules/acr/main.tf`         | `acrpowerplay`                            | Uniek ACR naam suffix
| `modules/storage/main.tf`     | `storageprod`                             | Uniek storage naam suffix

## Installatie

### Stap 1: Terraform initialiseren en deployen
```bash
terraform init
terraform apply
```

> Na de apply worden `ansible/inventory-gameservers.ini` en `ansible/inventory-vpn.ini`
> automatisch gegenereerd met de juiste publieke IPs.

#### Stap 2: Gameservers configureren via Ansible
```bash
ansible-playbook -i ansible/inventory-gameservers.ini ansible/gameserver.yml
```

### Stap 3: VPN router configureren via Ansible
```bash
ansible-playbook -i ansible/inventory-vpn.ini ansible/vpn-bgp.yml
```

### Stap 4: Skylab pfSense handmatig configureren

Haal het nieuwe Azure VPN public IP op:
```bash
terraform output vpn_public_ip
```

Pas dan het volgende aan in de Skylab pfSense web UI:

1. **VPN → IPsec → Edit P1 → Remote Gateway** → nieuw Azure VPN IP invullen
2. **Firewall → Rules → IPsec → bestaande regel** → source aanpassen naar nieuw Azure VPN IP
3. **Status → IPsec** → klik "Connect P1 and P2s"

## Verification
### Terraform outputs
```bash
terraform output
```

### File share mount op gameservers
```bash
ansible gameservers -i ansible/inventory-gameservers.ini -m command -a "df -h /mnt/gameconfigs"
```

### BGP status
```bash
ansible vpn -i ansible/inventory-vpn.ini -b -m command -a "vtysh -c 'show bgp summary'"

ansible vpn -i ansible/inventory-vpn.ini -b -m command -a "vtysh -c 'show ip bgp'"
```

### SSH naar VPN router
```bash
ssh -i ~/.ssh/id_azure deploy@$(terraform output -raw vpn_public_ip)
```

### Containers bereikbaar
```bash
terraform output matchmaking_fqdn
terraform output dashboard_fqdn
terraform output telemetry_fqdn
```

> Als containers niet meer aanwezig zijn:
> ```bash
> terraform apply -target=module.aci
> ```

## Beperkingen
- CPU en storage alerts konden alleen worden aangemaakt via Azure Monitor Metric Alerts
- Skylab pfSense configuratie (IPsec + BGP) moet na elke terraform destroy
  handmatig bijgewerkt worden met het nieuwe Azure VPN public IP
- ACI containers worden na ongeveer 10 minuten automatisch verwijdert


## Modules

network      # VNet, subnets, NSGs
vm           # Gameserver VMs, data disks, Ansible inventory
acr          # Container Registry, image builds
aci          # Container instances
storage      # Storage account, blob containers, file share
monitoring   # Metric alerts
vpn          # VPN router VM, Ansible inventory