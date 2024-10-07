# Thanos snapt je DevOps together
## Hoofdvraag
Hoe kan Thanos effectief worden ingezet in een devops omgeving voor monitoring en alerting?

## Deelvragen
1. Wat is de architectuur en de belangrijkste componenten van Thanos?
    - Hoe werkt Thanos samen met Prometheus?
    -  Welke problemen lost Thanos op ten opzichte van standaard Prometheus-implementaties?
    - Onderzoeksmethode: Literature study 
      - Toelichting: Bestudeer de officiële Thanos-documentatie, whitepapers, en technische blogs om een diepgaand begrip te krijgen van de architectuur en componenten. Analyseer schema's, architectuurdiagrammen en functionele beschrijvingen.
2. Hoe integreert Thanos met container-orkestratiesystemen zoals Kubernetes?
    - Wat zijn de stappen voor het implementeren van Thanos in een Kubernetes-cluster?
    - Onderzoeksmethode: Prototyping
      - Toelichting: Voer een hands-on implementatie uit van Thanos binnen een Kubernetes-cluster om de integratiestappen en uitdagingen te begrijpen.
3. Wat zijn de voordelen en nadelen van het gebruik van Thanos in vergelijking met andere monitoringoplossingen?
    - Hoe verhoudt Thanos zich tot alternatieven zoals Cortex of M3DB?
    - Welke use-cases zijn het meest geschikt voor Thanos?
    - Onderzoeksmethode: Community Research
      - Toelichting: Analyseer en vergelijk Thanos met alternatieven zoals Cortex en M3DB op basis van criteria zoals schaalbaarheid, complexiteit en functionaliteit.
4. Op welke manieren kan Thanos bijdragen aan betere samenwerking tussen development en operations teams?
    - Hoe faciliteert Thanos gedeelde inzichten in systeemprestaties?
    - Misschien: Onderzoeksmethode: Focus group
      - Toelichting: Organiseer een focusgroep met DevOps-teamleden om kwalitatieve inzichten te verzamelen over hoe Thanos de samenwerking en communicatie tussen teams beïnvloedt.


## Bronnen: > later nog ff netjes
- Thanos Documentation: https://thanos.io/
- Prometheus Documentation: https://prometheus.io/docs/introduction/overview/
- Cortex Documentation: https://cortexmetrics.io/
- M3DB Documentation: https://m3db.io/
- aim controle kaart
- https://ictresearchmethods.nl/
- chatgpt
- extra bron per deelvraag??? vgm werdt daarmee link naar iedere ict method per deelvraag https://minordevops.nl/week-5-slack-ops/workshop-onderzoeksplan-prompt-engineering.html#c-vastleggen-format-checks

### misschien of backup:
- Hoe draagt Thanos bij aan de betrouwbaarheid en schaalbaarheid van monitoringdata in een DevOps-context?
  - Hoe ondersteunt Thanos long-term storage en global querying? 
  - Op welke manier verbetert Thanos de fouttolerantie van monitoringdiensten?
- Welke best practices en uitdagingen zijn er bij het implementeren van Thanos? 
  - Wat zijn de veelvoorkomende valkuilen tijdens de implementatie? 
  - Hoe kunnen deze uitdagingen worden overwonnen?
- Welke security-overwegingen moeten in acht worden genomen bij het gebruik van Thanos in een DevOps-omgeving? 
  - Hoe kan men zorgen voor veilige gegevensoverdracht en opslag binnen Thanos? 
- Hoe kan Thanos helpen bij het proactief identificeren en oplossen van performance issues in applicaties? 
  - Welke monitoring metrics zijn cruciaal en hoe visualiseert Thanos deze?