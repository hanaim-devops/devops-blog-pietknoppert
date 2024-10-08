# Thanos snapt je devops together
'Conclusie/ samenvatting' 

<img src="https://miro.medium.com/v2/resize:fit:1100/format:webp/0*pxjok2ACCc7PJOCM.jpg">

# Wat is Thanos en hoe red het je?
bron prometheus

Weet je al wat Prometheus is? De volgende monitoring tool; Thanos werkt is namelijk dependent op Prometheus. Het is handig om te weten te weten wat Prometheus doet, lees daarom een korte introductie over Prometheus van ... ;;
https://www.tigera.io/learn/guides/prometheus-monitoring/

Thanos is een extensie voor Prometheus die zich richt op het verbeteren van de schaalbaarheid, beschikbaarheid en persistentie van metrics in een gedistribueerde omgeving. Thanos kan dus niet zelfstandig opereren. Wanneer Thanos wordt ingezet, blijft Prometheus in zijn rol als een time-series database en metrics scraper werken. 

Voordat ik wat meer vertel over de voordelen en details van Thanos moet ik eerst de belangrijke details en architectuur uitleggen van Thanos.

## Thanos componenten
Laten we eerst kijken uit welke onderdelen Thanos bevat en welke interactie er is met Prometheus.

### Sidecar
Een van de belangrijkste is de ‘sidecar’ (bron zodalijk!). Deze wordt gekoppeld aan een Prometheus server. Deze sidecar dient zich als een interface tussen Prometheus en de opslag van Thanos. Het zorgt ervoor dat de block data (compacte opslag van [time-series](https://www.tableau.com/analytics/what-is-time-series-analysis) data) (https://thanos.io/tip/thanos/storage.md/#object-storage--data-format) die Prometheus periodiek genereert, geüpload wordt naar een long-term storage systeem, zoals een object store (data-opslag waarin data wordt opgeslagen als objecten, in tegenstelling tot de traditionele hiërarchische bestandsstructuren [bron]( https://cloud.google.com/learn/what-is-object-storage?hl=en)) (bijv. Amazon S3 of een vergelijkbare lokale oplossing).

### Store Gateway
die queries mogelijk maakt over zowel de lokale data als de opgeslagen data in de object store. Hierdoor is het mogelijk om oudere metrics op te vragen zonder dat de oorspronkelijke Prometheus instance beschikbaar hoeft te zijn.


Als de Sidecar data back-upt in de object storage kun je de retentieperiode (de tijdsduur waarvoor data wordt bewaard voordat deze wordt verwijderd of overschreven) van Prometheus verkorten om minder data lokaal op te slaan. Echter, om al deze historische data opnieuw op te vragen, hebben we een manier nodig om toegang te krijgen tot die data. De Store Gateway helpt bij de toegang tot hositorsche data door dezelfde API te implementeren als de Sidecar, maar het doet dit door de data te benaderen die het in de object storage kan vinden. Net als sidecars en query nodes, stelt de Store Gateway een Store API beschikbaar en moet deze door de Querier (hier later meer over) worden gedetecteerd.

```
thanos store \ --data-dir /var/thanos/store \ # Schijfruimte voor lokale caches --objstore.config-file bucket_config.yaml \ # Bucket om data uit op te halen --http-address 0.0.0.0:19191 \ # HTTP endpoint voor het verzamelen van metrics over de Store Gateway --grpc-address 0.0.0.0:19090 # GRPC endpoint voor StoreAPI
```

### Querier
Als je één of meerdere Sidecars hebt opgezet bij verschillende Prometheus instanties wil je kun je doormiddel van de Thanos Querier queries over alle instanties heen uitvoeren. De Querier fungeert als een [federated query-engine](https://blog.devgenius.io/understanding-federated-query-engines-624c57435118) die data verzamelt van meerdere Prometheus-instanties en Thanos componenten om een uniform overzicht van metrics te bieden, waardoor cluster-overschrijdende queries mogelijk zijn met één enkele API i.p.v. alle individuele instanties.

Dit lost het probleem van [Prometheus federation denk ik deze bron, nog ff nakijken later](https://last9.io/blog/prometheus-federation-guide/) elegant op.


### Downsampling
https://thanos.io/tip/thanos/quick-tutorial.md/#compactor
https://thanos.io/tip/components/compact.md/

Thanos ‘downsampling mechanisme’ wordt uitgevoerd door de Compactor component, die verantwoordelijk is voor het optimaliseren en comprimeren van de opgeslagen metrics-data. Het downsampling-proces werkt door het verminderen van de resolutie van de data naarmate deze ouder wordt. Thanos gebruikt hiervoor drie verschillende graten van dataopslag:
1.	Raw data (5s resolutie): De originele, onbewerkte metrics zoals ze door Prometheus zijn verzameld. Deze resolutie biedt de meest gedetailleerde inzichten en wordt bewaard voor kortetermijnanalyses.
2.	5m downsampled data: Zodra de metrics ouder worden, past de Compactor een gemiddelde toe over intervallen van 5 minuten, wat de opslagruimte aanzienlijk reduceert zonder de essentie van de trends in de data te verliezen.
3.	1h downsampled data: Voor de langetermijnarchivering wordt een nog grovere resolutie toegepast, waarbij data wordt geaggregeerd over intervallen van een uur. Deze resolutie is ideaal voor het bekijken van historische trends over een lange periode.

Misschien nog echte berekeningen plaatsen

Het proces van downsampling gebeurt vervolgens in 2 stappen:
1.	5-minuten resolutie: Alle metrics met de originele resolutie (raw resolution) die ouder zijn dan 40 uur, worden gedownsampled naar een resolutie van 5 minuten. Dit betekent dat datapunten worden geaggregeerd zodat er slechts één datapunt per 5 minuten overblijft.
2.	1-uur resolutie: Vervolgens, als de metrics met een 5-minuten resolutie ouder zijn dan 10 dagen, worden ze verder gedownsampled naar een resolutie van 1 uur.

Misschien weg dit: 

Dit is hoe je een compacter kan starten in K8 met YAML:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: thanos-compactor
spec:
  replicas: 1
  template:
    spec:
      containers:
      - name: compact
        image: thanosio/thanos:v0.32.2
        args:
          - compact
          - --data-dir=/var/thanos/compact
          - --objstore.config-file=/etc/thanos/bucket.yaml
          - --retention.resolution-raw=30d
          - --retention.resolution-5m=180d
          - --retention.resolution-1h=365d
```

## Architectuur

Nu ik heb verteld over de belangrijkste onderdelen ga ik de volledige architectuur in beeld brengen. Dit zit er zo uit:

<img src="https://docs.google.com/drawings/d/e/2PACX-1vSJd32gPh8-MC5Ko0-P-v1KQ0Xnxa0qmsVXowtkwVGlczGfVW-Vd415Y6F129zvh3y0vHLBZcJeZEoz/pub?w=960&h=720">

SRC: https://docs.google.com/drawings/d/e/2PACX-1vSJd32gPh8-MC5Ko0-P-v1KQ0Xnxa0qmsVXowtkwVGlczGfVW-Vd415Y6F129zvh3y0vHLBZcJeZEoz/pub?w=960&h=72

In deze afbeelding komen de eerder besproken componenten duidelijk naar voren, zoals de Sidecar, Store Gateway, Querier en de Compactor. Deze componenten werken samen om de schaalbaarheid, beschikbaarheid en persistentie van metrics binnen Thanos te optimaliseren. De afbeelding illustreert hoe data vanuit Prometheus naar de object storage stroomt en hoe Thanos componenten deze data kunnen verwerken en opvragen.

Eén component die ik in deze blog niet heb behandeld is de Ruler. Deze is component zorgt voornamelijk voor het evalueren van Prometheus alerting en recording rules, zelfs op basis van historische data. Dit maakt het mogelijk om ook bij storingen betrouwbare alerts te genereren.

## Verbinding met Prometheus
Bron prome

Ik ga er vanaf nu vanuit dat je een goed idee hebt wat Prometheus doet. Prometheus heeft onderanderen beperkingen op het gebied van schaalbaarheid en long-term dataopslag.

misschien nog ff uitleggen wat long-term mem isse is

Thanos bouwt voort op de kracht van Prometheus door deze beperkingen aan te pakken. Thanos werkt als een laag bovenop Prometheus en biedt mogelijkheden zoals long-term storage, high availability, en globale query-functionaliteiten. Dit betekent dat Thanos niet de data scraping of metric-verzameling van Prometheus vervangt, maar deze juist uitbreidt door alle verzamelde data op te slaan in een schaalbare object storage. Thanos maakt het eenvoudiger om op te schalen naar meerdere Prometheus-instanties en biedt één enkel overzicht van al deze metrics, zonder de noodzaak om Prometheus' federatiefuncties te gebruiken.

## Welke problemen lost Thanos op?

Thanos biedt een reeks oplossingen voor beperkingen en problemen die inherent zijn aan een standaard Prometheus-implementatie. Prometheus, heeft het duidelijke beperkingen als het gaat om schaalbaarheid, data-retentie en high availability (HA). Hier is hoe Thanos deze uitdagingen aanpakt:
1. Lange-termijn opslag en schaalbaarheid: Thanos gebruikt object storage om de beperkte dataretentie van Prometheus te omzeilen, waardoor metrics jarenlang kunnen worden bewaard zonder dure lokale opslag. 
2. High Availability (HA): Door datareplicatie en gedecentraliseerde query's zorgt Thanos ervoor dat metrics beschikbaar blijven, zelfs bij serveruitval. Dit voorkomt dat een enkele Prometheus-instance een single point of failure is. 
3. Global Query View: Met de Thanos Querier wordt een globale querylaag mogelijk gemaakt die metrics van meerdere Prometheus-instances verzamelt. Dit vereenvoudigt het monitoren van cluster-overschrijdende metrics zonder de complexiteit van Prometheus-federatie. 
4. Downsampling: Thanos comprimeert oudere data naar lagere resoluties met de Compactor, waardoor opslagkosten worden verlaagd en query-prestaties worden verbeterd zonder belangrijk trendinzicht te verliezen. 
5. Multi-cluster monitoring: Thanos biedt naadloze multi-cluster ondersteuning, waarbij metrics van verschillende locaties worden samengebracht in één overzicht. Dit maakt het uitermate geschikt voor gedistribueerde cloud-native omgevingen.

#### BRONNEN HIER NOG BIJ
Bijv bron wat prometheus faal punten zijn
En dingen referen in de eerder gemaakte in de blog
zeker nog wat compacter maken

# technische implementatie

# voor nadelen thanos en vergelijking met anderen

# devops