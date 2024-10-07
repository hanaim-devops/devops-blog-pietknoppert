# DevOps dev blog naar aanleiding van onderzoek

<img src="plaatjes/cncf-logo.png" alt="CNCF logo" width="100" align="right">

Hier vind je de blog posts van studenten van de minor DevOps over hun onderzoek naar technologien uit de [Cloud Native Computing Foundation](https://landscape.cncf.io/) (CNCF) en andere DevOps tools, frameworks, talen etc.

Waar vind je verder nog zo'n verzameling Nederlandstalig DevOps blogs!? Die je helpen om de pareltjes te vinden, de disruptive technologies, tussen alle one day flies en de 'only buzz' tech.

Per 2022 zijn blog posts geschreven met hulp van ChatGPT. Maar moeten studenten uiteraard wel door prompten en handmatig aanpassen totdat het ook echt zinnig is. Daarnaast presenteren studenten eind van de week kort hun onderzoeksbevindingen in korte pitches die zij in teamverband geven.

Met dank aan alle studenten!

*[Bart van der Wal, docent minor DevOps](mailto:bart.vanderwal@han.nl)*

<figure align="right">
    <img src="plaatjes/all-buzz.jpg" alt="Is it all just buzzwords?" width="500">
    <figcaption>Figuur 1: Een dag niet gememe'd, is een dag niet geleefd :)</figcaption>
</figure>




# Blog ding

## voor mijzelf; 
- wat is het
- waarom is het belangrijk
- hoe werkt het 
- hoe kan ik het gebruiken > applicatie
- wat zijn de voordelen
- wat zijn de nadelen
- wat zijn de alternatieven
- wat zijn de use-cases
- wat zijn de best practices
- wat zijn de uitdagingen
- devops aspecten > die focus group results opschrijven

| Kenmerk                   | **Thanos**                                                                                                                                                           | **VictoriaMetrics**                                                                                                    | **OpenTelemetry**                                                                                                    |
|---------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| **Schaalbaarheid**        | Schaalbaar met object storage; goed voor multi-cluster omgevingen met bijvoorbeeld meerdere Prometheus instanties.                                                   | Uitstekend schaalbaar dankzij vmstorage en vmselect; kan horizontaal schalen door meer nodes toe te voegen.             | Zeer flexibel; ondersteunt zowel metrics, traces als logs zonder zelf opslag te implementeren.                        |
| **Complexiteit**          | Vereist setup van meerdere componenten (Sidecar, Querier, Store Gateway); vereist ervaring met Prometheus.                                                           | Eenvoudigere setup in vergelijking met Thanos; vereist geen Sidecars of complexe verbindingen tussen datacenters.      | Heeft een iets steilere leercurve door focus op verschillende observability signalen; vereist kennis van tracing en logging. |
| **Use-cases**             | Beste voor organisaties met bestaande Prometheus-omgevingen wanneer; lange-termijn dataopslag vereist is, HA, goede schaalbaarheid, compacter maken van data         | Ideaal voor bedrijven met focus op lage operationele kosten en hoge prestaties bij het verwerken van grote hoeveelheden data. | Geschikt voor organisaties die op zoek zijn naar een alles-in-één oplossing voor metrics, traces en logs.             |
| **Flexibiliteit**         | Gebaseerd op het Prometheus-model, wat beperkingen heeft in metric types.                                                                                            | Ondersteunt Prometheus query API en biedt extra flexibiliteit met PromQL-extensies en meerdere data-ingestieprotocollen. | Zeer flexibel; ondersteunt unieke metric types zoals DELTA-metrics en exponential histograms die Prometheus mist.     |
| **Integratie**            | Ontworpen als een uitbreiding van Prometheus; werkt het beste in omgevingen die al Prometheus gebruiken.                                                             | Kan data uit Prometheus ontvangen via de standaard remote_write API; eenvoudig te integreren in bestaande systemen.    | Kan integreren met veel systemen en backends, en kan als frontend voor Prometheus fungeren.                          |
| **Data opslag en query**  | Opslag in object stores en querying via PromQL; biedt goede prestaties voor real-time data maar kan vertraagd zijn bij grote datasets.                               | Maakt gebruik van blokopslag met efficiënte on-disk compressie; biedt uitstekende query-prestaties met lage latentie.   | Geen eigen opslag; stuurt data door naar een andere database, zoals Prometheus, voor opslag en query.                 |
| **Stabiliteit**           | Stabiel maar afhankelijk van meerdere componenten.                                                                                                                   | Zeer robuust met minimale componenten; hogere beschikbaarheid en minder faalpunten vergeleken met Thanos.               | Nog relatief jong; evolueert snel met nieuwe functies maar minder battle-tested dan Prometheus/Thanos.               |
| **High Availability (HA)**| Ondersteunt meerdere Query-componenten in verschillende beschikbaarheidszones voor redundantie.                                                                      | Vereist geen extra configuratie voor HA; kan automatisch data repliceren tussen verschillende clusters voor hoge beschikbaarheid. | Ondersteunt HA door het gebruik van distributed tracing en logs, maar vereist configuratie met externe storageoplossingen. |
| **Hostingkosten**         | Kosteneffectief op lange termijn door gebruik van object storage, maar afhankelijk van egress- en API-kosten. Zelf lokaal opslaan is niet aangeraden door productie. | Lagere kosten dankzij efficiënte compressie en ondersteuning voor goedkopere HDD-opslag in plaats van SSD's.           | Flexibel door geen eigen opslag te gebruiken, maar afhankelijk van gekozen storage-oplossing voor kosten.            |

| Kenmerk                   | **Thanos** | **VictoriaMetrics** | **OpenTelemetry** |
|---------------------------|------------|--------------------|-------------------|
| **Schaalbaarheid**        | ✅         | ✅                  | ✅                |
| **Setup Complexiteit**    | Hoog       | Laag               | Gemiddeld         |
| **Multi-Signal Support**  | ❌         | ❌                  | ✅ (metrics, logs, traces) |
| **Gebruik voor Prometheus** | ✅         | ✅                  | Kan fungeren als frontend |
| **Long-term Data Opslag** | ✅         | ✅                  | ❌                |
| **Query Performance**     | Gemiddeld  | Hoog               | Afhankelijk van de backend |
| **High Availability (HA)**| ✅         | ✅                  | ✅                |
| **Kosten-efficiëntie**    | Gemiddeld  | Hoog               | Flexibel, afhankelijk van opslag |
| **Integratie**            | Gemakkelijk met Prometheus | Direct met Prometheus | Veelzijdig, maar afhankelijk van setup |
