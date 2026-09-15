# -*- coding: utf-8 -*-
"""
Anade ejercicios a las 10 unidades de gramatica que solo tenian 1 (las
avanzadas B2-C1 / C1). Idempotente: si el id de la pregunta ya existe, la salta.
Actualiza el seed del backend y el de deploy-nas y luego sincroniza los assets
offline de la app.

Uso:
    python scripts/add_grammar_exercises.py            # aplica y sincroniza
    python scripts/add_grammar_exercises.py --dry-run  # solo muestra el conteo
"""
import json, os, sys, subprocess

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TARGETS = [
    os.path.join(ROOT, "backend", "app", "seed", "grammar.json"),
    os.path.join(ROOT, "deploy-nas", "backend", "app", "seed", "grammar.json"),
]
SYNC = os.path.join(ROOT, "tools", "sync_offline_seeds.py")


def q(qid, prompt, ctx, options, correct, es, audio):
    return {
        "id": qid, "prompt": prompt, "contextSentence": ctx,
        "options": options, "correctAnswer": correct,
        "spanishExplanation": es, "audioText": audio,
    }


# 3 ejercicios nuevos por unidad. Ids en rango 2101+ para no colisionar (<=918).
NEW = {
  "unit-16-mid": [
    q(2101, "The rollback procedure _____ automatically triggered by the health-check service when error rates spike.",
      "Passive with agent: 'by + system'.", ["is", "by", "was been", "does"], "is",
      "Voz pasiva presente: 'is triggered by...'. El agente va con 'by'.",
      "The rollback procedure is automatically triggered by the health-check service when error rates spike."),
    q(2102, "The new rate-limiting policy _____ enforced _____ the API gateway, not by each service.",
      "Passive + agent 'by'.", ["is / by", "is / from", "was / with", "has / by"], "is / by",
      "Pasiva con complemento agente: 'is enforced by the gateway'.",
      "The new rate-limiting policy is enforced by the API gateway, not by each service."),
    q(2103, "All privileged actions _____ logged _____ the audit service for compliance.",
      "Passive with agent.", ["are / by", "are / to", "is / by", "were / with"], "are / by",
      "Sujeto plural 'actions' -> 'are logged by the audit service'.",
      "All privileged actions are logged by the audit service for compliance."),
  ],
  "unit-21-senior": [
    q(2111, "If we _____ proper observability last year, we would not be guessing about the root cause now.",
      "Mixed conditional: past cause -> present result.", ["had built", "built", "would build", "have built"], "had built",
      "Condicional mixto: 'If we had built... we would not be guessing now'.",
      "If we had built proper observability last year, we would not be guessing about the root cause now."),
    q(2112, "If the schema _____ versioned from the start, our current migrations _____ far less risky.",
      "Mixed conditional.", ["had been / would be", "was / will be", "had been / would have been", "were / would be"], "had been / would be",
      "Causa pasada (had been versioned) + resultado presente (would be less risky).",
      "If the schema had been versioned from the start, our current migrations would be far less risky."),
    q(2113, "We would own this domain end to end today if the previous team _____ it properly.",
      "Mixed conditional, inverted order.", ["had documented", "documented", "documents", "would document"], "had documented",
      "Resultado presente + causa pasada: '...if the previous team had documented it'.",
      "We would own this domain end to end today if the previous team had documented it properly."),
  ],
  "unit-23-senior": [
    q(2121, "_____ the read and write paths, we were able to scale them independently.",
      "Participle clause of cause.", ["Having separated", "After we separate", "Separating have", "We had separated"], "Having separated",
      "Clausula de participio perfecto: 'Having separated..., we were able to...'.",
      "Having separated the read and write paths, we were able to scale them independently."),
    q(2122, "_____ on a single region, the service could not survive a full data-center outage.",
      "Participle clause (reduced relative).", ["Relying", "Relied", "It relies", "To rely"], "Relying",
      "Participio presente que reduce 'Because it relied on...': 'Relying on a single region...'.",
      "Relying on a single region, the service could not survive a full data-center outage."),
    q(2123, "_____ the legacy queue, we cut infrastructure costs by a third.",
      "Participle clause of time/cause.", ["Having decommissioned", "We decommissioned", "Decommission", "After decommission"], "Having decommissioned",
      "'Having decommissioned the legacy queue, we cut costs...' (accion previa).",
      "Having decommissioned the legacy queue, we cut infrastructure costs by a third."),
  ],
  "unit-24-senior": [
    q(2131, "_____ fault tolerance, I would replicate the queue across three availability zones.",
      "Discourse marker for topic shift.", ["With regard to", "For make", "Talking of that", "In front of"], "With regard to",
      "Marcador de transicion formal: 'With regard to fault tolerance, ...'.",
      "With regard to fault tolerance, I would replicate the queue across three availability zones."),
    q(2132, "That covers the ingestion layer. _____, let us examine how we index the data for fast reads.",
      "Discourse marker: moving on.", ["Moving on", "So then now", "For the next", "By the other side"], "Moving on",
      "'Moving on, let us examine...' guia la entrevista al siguiente tema.",
      "That covers the ingestion layer. Moving on, let us examine how we index the data for fast reads."),
    q(2133, "_____ the trade-offs, the managed service wins on operational cost even if it is less flexible.",
      "Discourse marker: weighing up.", ["On balance", "In the balance of", "By the end all", "At all"], "On balance",
      "'On balance, ...' introduce una conclusion tras sopesar pros y contras.",
      "On balance, the managed service wins on operational cost even if it is less flexible."),
  ],
  "unit-26-staff": [
    q(2141, "_____ the added latency of the extra hop, the gateway pattern centralizes auth and pays for itself.",
      "Concessive clause + noun phrase.", ["Notwithstanding", "Although is", "Despite of", "Even it has"], "Notwithstanding",
      "'Notwithstanding + sustantivo': reconoce el coste sin restar firmeza a la propuesta.",
      "Notwithstanding the added latency of the extra hop, the gateway pattern centralizes auth and pays for itself."),
    q(2142, "_____ the migration carries short-term risk, standing still would cost us more within a year.",
      "Concessive clause + full clause.", ["While", "Despite", "Notwithstanding of", "In spite"], "While",
      "'While + oracion completa' concede el riesgo: 'While the migration carries risk, ...'.",
      "While the migration carries short-term risk, standing still would cost us more within a year."),
    q(2143, "The approach is sound; _____, I would pilot it on one squad before a full rollout.",
      "Concessive/hedging adverb.", ["that said", "by that", "in against", "with all"], "that said",
      "'That said,' concede matizando: acepta la idea pero propone cautela.",
      "The approach is sound; that said, I would pilot it on one squad before a full rollout."),
  ],
  "unit-28-staff": [
    q(2151, "With autoscaling and read replicas in place, the platform _____ handle the holiday peak.",
      "Compound modal of readiness.", ["is poised to", "is bound without", "may to", "should to be"], "is poised to",
      "'is poised to' = esta preparada/lista para. Modal compuesto de disposicion.",
      "With autoscaling and read replicas in place, the platform is poised to handle the holiday peak."),
    q(2152, "If we keep ignoring the flaky tests, they _____ erode the team's trust in the pipeline.",
      "Compound modal of near-certainty.", ["are bound to", "are poised without", "ought to must", "will can"], "are bound to",
      "'are bound to' = es casi seguro que ocurra (consecuencia inevitable).",
      "If we keep ignoring the flaky tests, they are bound to erode the team's trust in the pipeline."),
    q(2153, "The vendor's SLA is strong, so the integration _____ be a reliability risk for us.",
      "Compound modal of low probability.", ["is unlikely to", "is likely without", "cannot to", "must not to"], "is unlikely to",
      "'is unlikely to' expresa baja probabilidad con precision ejecutiva.",
      "The vendor's SLA is strong, so the integration is unlikely to be a reliability risk for us."),
  ],
  "unit-25-staff": [
    q(2161, "A staff engineer pushing to fund an internal platform team says:",
      "Register: assertive and quantitative.",
      ["The metrics make a clear case: the shared platform cut onboarding time for new services from three weeks to four days.",
       "It would be nice to have a platform team, I guess.",
       "Other big companies have platform teams, so we should too.",
       "Building platforms is fun and the engineers would enjoy it."],
      "The metrics make a clear case: the shared platform cut onboarding time for new services from three weeks to four days.",
      "Nivel Staff: afirmacion cuantitativa y basada en datos, no en gustos ni en imitacion.",
      "The metrics make a clear case: the shared platform cut onboarding time for new services from three weeks to four days."),
    q(2162, "Advocating for time to reduce technical debt, the strongest phrasing is:",
      "Register: strong advocacy.",
      ["I strongly recommend ring-fencing twenty percent of each sprint for debt reduction, based on our incident trend.",
       "Maybe we could fix some old code when we have a free moment.",
       "The code is ugly and it annoys me a lot.",
       "We should rewrite everything because it is old."],
      "I strongly recommend ring-fencing twenty percent of each sprint for debt reduction, based on our incident trend.",
      "'I strongly recommend... based on...' es asertivo y justificado con datos.",
      "I strongly recommend ring-fencing twenty percent of each sprint for debt reduction, based on our incident trend."),
    q(2163, "Closing a negotiation for more headcount, a principal engineer states:",
      "Register: confident close.",
      ["Given the roadmap and our current on-call load, two additional engineers is the minimum to deliver without burning out the team.",
       "Please, we really really need more people or things will be bad.",
       "Everyone is tired so hiring would be nice.",
       "If you do not hire, I cannot promise anything at all."],
      "Given the roadmap and our current on-call load, two additional engineers is the minimum to deliver without burning out the team.",
      "Cierre firme y cuantificado, ligando la peticion a roadmap y carga real.",
      "Given the roadmap and our current on-call load, two additional engineers is the minimum to deliver without burning out the team."),
  ],
  "unit-29-staff": [
    q(2171, "Nominalize: 'Because we decoupled the services, teams can deploy on their own.'",
      "Nominalization for executive summaries.",
      ["Service decoupling enabled autonomous, team-level deployments.",
       "We decoupled things so teams deploy alone now.",
       "Because of decoupling, teams are deploying by themselves happily.",
       "Teams deploy on their own since we did decoupling."],
      "Service decoupling enabled autonomous, team-level deployments.",
      "La nominalizacion condensa la accion en sustantivo: 'Service decoupling enabled...'.",
      "Service decoupling enabled autonomous, team-level deployments."),
    q(2172, "Nominalize: 'When we adopted feature flags, we released more safely.'",
      "Nominalization.",
      ["Feature-flag adoption significantly improved release safety.",
       "Adopting flags made releases safer for us.",
       "We used flags and then releases were more safe.",
       "Because of flags, releasing became less scary."],
      "Feature-flag adoption significantly improved release safety.",
      "'Feature-flag adoption improved release safety' condensa causa y efecto.",
      "Feature-flag adoption significantly improved release safety."),
    q(2173, "Nominalize: 'Because we consolidated the clusters, we spend less on infrastructure.'",
      "Nominalization.",
      ["Cluster consolidation reduced our infrastructure spend.",
       "We joined the clusters so we pay less now.",
       "Consolidating clusters made the bill smaller.",
       "Since clusters were consolidated, costs went down a bit."],
      "Cluster consolidation reduced our infrastructure spend.",
      "Sujeto nominalizado + verbo de impacto: 'Cluster consolidation reduced...'.",
      "Cluster consolidation reduced our infrastructure spend."),
  ],
  "unit-30-staff": [
    q(2181, "Disagreeing tactfully with a PM who wants to skip load testing before a launch:",
      "Tactful disagreement + rationale.",
      ["I understand the launch pressure; however, skipping load testing risks an outage on day one, which would cost us more than the delay.",
       "No, we are not launching without load tests, end of discussion.",
       "You clearly do not understand how servers work under load.",
       "Load testing is always mandatory no matter what the business says."],
      "I understand the launch pressure; however, skipping load testing risks an outage on day one, which would cost us more than the delay.",
      "Reconoce el punto ('I understand...'), luego matiza con 'however' y da el motivo.",
      "I understand the launch pressure; however, skipping load testing risks an outage on day one, which would cost us more than the delay."),
    q(2182, "Steering a design review back on track without dismissing a colleague:",
      "Tactful steering.",
      ["That is a fair point about caching; can we park it and come back once we have agreed on the data model?",
       "Stop talking about caching, it is not important right now.",
       "We are wasting time, let me just decide this myself.",
       "Caching again? We always get stuck on the same thing."],
      "That is a fair point about caching; can we park it and come back once we have agreed on the data model?",
      "Valida ('fair point'), aparca con tacto ('park it') y reencauza la reunion.",
      "That is a fair point about caching; can we park it and come back once we have agreed on the data model?"),
    q(2183, "Pushing back on an unrealistic deadline while staying collaborative:",
      "Tactful pushback.",
      ["I want us to hit this date; to do that responsibly, we would need to cut the reporting module from the first release.",
       "That deadline is impossible and whoever set it was wrong.",
       "Fine, we will try, but do not blame me when it breaks.",
       "Deadlines like this are why good engineers quit."],
      "I want us to hit this date; to do that responsibly, we would need to cut the reporting module from the first release.",
      "Se alinea con el objetivo y ofrece un trade-off concreto en vez de un 'no' seco.",
      "I want us to hit this date; to do that responsibly, we would need to cut the reporting module from the first release."),
  ],
  "unit-31-staff": [
    q(2191, "Describing a long-term architectural vision in a senior interview:",
      "Strategic vision register.",
      ["Over the next two years we aim to evolve toward an event-driven core so product squads can ship independently.",
       "We want to use whatever framework is trending each year.",
       "My vision is basically zero bugs everywhere forever.",
       "We will rewrite the whole system every couple of years to stay modern."],
      "Over the next two years we aim to evolve toward an event-driven core so product squads can ship independently.",
      "Vision a plazo, con objetivo y beneficio ('so product squads can ship independently').",
      "Over the next two years we aim to evolve toward an event-driven core so product squads can ship independently."),
    q(2192, "Framing a platform strategy to leadership:",
      "Strategic framing.",
      ["Our strategy is to invest in self-service tooling now so that delivery speed compounds as we scale the org.",
       "We should buy the most expensive tools to look serious.",
       "Let us just copy exactly what the biggest tech company does.",
       "The plan is to keep everything as it is and hope it scales."],
      "Our strategy is to invest in self-service tooling now so that delivery speed compounds as we scale the org.",
      "Liga la inversion presente a un beneficio compuesto futuro ('compounds as we scale').",
      "Our strategy is to invest in self-service tooling now so that delivery speed compounds as we scale the org."),
    q(2193, "Explaining how the vision guides day-to-day trade-offs:",
      "Vision-to-execution link.",
      ["Every design choice is measured against one question: does it move us toward autonomous, loosely coupled services?",
       "We decide things based on whatever is fastest to code today.",
       "Honestly we just do what the loudest person wants.",
       "The vision is nice but it does not really change what we build."],
      "Every design choice is measured against one question: does it move us toward autonomous, loosely coupled services?",
      "Conecta la vision con decisiones diarias mediante un criterio unico y claro.",
      "Every design choice is measured against one question: does it move us toward autonomous, loosely coupled services?"),
  ],
}


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def main():
    dry = "--dry-run" in sys.argv
    src = next((t for t in TARGETS if os.path.exists(t)), None)
    if not src:
        print("No encuentro grammar.json en:", TARGETS)
        sys.exit(1)
    data = load(src)
    units = data.get("items", data) if isinstance(data, dict) else data
    byid = {u.get("id"): u for u in units}

    added = 0
    for uid, qs in NEW.items():
        u = byid.get(uid)
        if not u:
            print("  (aviso) no existe la unidad:", uid)
            continue
        existing = {q.get("id") for q in u.get("questions", [])}
        for q in qs:
            if q["id"] in existing:
                continue
            u.setdefault("questions", []).append(q)
            added += 1
        print("  %-18s -> %d ejercicios" % (uid, len(u.get("questions", []))))

    print("Ejercicios anadidos:", added)
    if dry:
        print("(dry-run) No se ha escrito nada.")
        return

    out = data if isinstance(data, dict) else units
    for t in TARGETS:
        if not os.path.isdir(os.path.dirname(t)):
            print("  (aviso) no existe carpeta, salto:", t)
            continue
        with open(t, "w", encoding="utf-8") as f:
            json.dump(out, f, ensure_ascii=False, indent=2)
        print("  escrito:", t)

    if os.path.exists(SYNC):
        print("Sincronizando assets offline...")
        r = subprocess.run([sys.executable, SYNC], cwd=ROOT)
        print("  sync OK" if r.returncode == 0 else "  sync FALLO")
    else:
        print("  (aviso) no encuentro tools/sync_offline_seeds.py; ejecuta el sync a mano.")


if __name__ == "__main__":
    main()
