import Foundation

struct PremiumContentItem: Identifiable {
    let id: String
    let title: String
    let date: String          // YYYY-MM-DD
    let difficulty: Int
    let textFilePath: String
    var sessionId: String?    // linked when pipeline has processed it
}

enum PremiumContent {

    // MARK: - Static Data

    static let items: [PremiumContentItem] = [
        // March 12
        PremiumContentItem(
            id: "premium-20260312-noma",
            title: "Noma's Harder Test",
            date: "2026-03-12",
            difficulty: 3,
            textFilePath: "docs/text/premium/original/20260312_noma.md"
        ),
        // March 13
        PremiumContentItem(
            id: "premium-20260313-ai-ipo-rivalry",
            title: "The IPO Race in AI",
            date: "2026-03-13",
            difficulty: 3,
            textFilePath: "docs/text/premium/original/20260313_ai-ipo-rivalry.md"
        ),
        // March 14
        PremiumContentItem(
            id: "premium-20260314-africas-new-growth-story",
            title: "Africa's New Growth Story: From Aid to Investment",
            date: "2026-03-14",
            difficulty: 2,
            textFilePath: "docs/text/premium/original/20260314_africas-new-growth-story-2.md"
        ),
        // March 15
        PremiumContentItem(
            id: "premium-20260315-american-power-symbols",
            title: "American Power: Symbols, Cyberspace, and the Exodus",
            date: "2026-03-15",
            difficulty: 3,
            textFilePath: "docs/text/premium/original/20260315_american-power-symbols-cyberspace-and-the-exodus-3.md"
        ),
        // March 16
        PremiumContentItem(
            id: "premium-20260316-chinas-shifting-calculus",
            title: "China's Shifting Calculus: Pollution, Power, and Public Opinion",
            date: "2026-03-16",
            difficulty: 4,
            textFilePath: "docs/text/premium/original/20260316_chinas-shifting-calculus-4.md"
        ),
        // March 17
        PremiumContentItem(
            id: "premium-20260317-cultural-crosscurrents",
            title: "Cultural Crosscurrents: Comedy, Happiness, and Hidden Economies",
            date: "2026-03-17",
            difficulty: 2,
            textFilePath: "docs/text/premium/original/20260317_cultural-crosscurrents-comedy-happiness-and-hidden-economies-2.md"
        ),
        // March 18
        PremiumContentItem(
            id: "premium-20260318-europes-economic-reset",
            title: "Europe's Economic Reset: From Brexit to Rearmament",
            date: "2026-03-18",
            difficulty: 3,
            textFilePath: "docs/text/premium/original/20260318_europes-economic-reset-3.md"
        ),
        // March 19
        PremiumContentItem(
            id: "premium-20260319-forces-reshaping-corporate",
            title: "The Forces Reshaping Corporate Management",
            date: "2026-03-19",
            difficulty: 3,
            textFilePath: "docs/text/premium/original/20260319_forces-reshaping-corporate-management-3.md"
        ),
        // March 20
        PremiumContentItem(
            id: "premium-20260320-gaps-ai-cannot-close",
            title: "The Gaps AI Still Cannot Close",
            date: "2026-03-20",
            difficulty: 3,
            textFilePath: "docs/text/premium/original/20260320_gaps-ai-cannot-close-3.md"
        ),
        // March 21
        PremiumContentItem(
            id: "premium-20260321-gulf-energy-shock",
            title: "The Gulf Energy Shock: No Quick Fix",
            date: "2026-03-21",
            difficulty: 4,
            textFilePath: "docs/text/premium/original/20260321_gulf-energy-shock-no-quick-fix-4.md"
        ),
        // March 22
        PremiumContentItem(
            id: "premium-20260322-hidden-fragilities",
            title: "Hidden Fragilities in Global Markets",
            date: "2026-03-22",
            difficulty: 4,
            textFilePath: "docs/text/premium/original/20260322_hidden-fragilities-global-markets-4.md"
        ),
        // March 23
        PremiumContentItem(
            id: "premium-20260323-indias-contradictions",
            title: "India's Contradictions: Wealth and Vulnerability",
            date: "2026-03-23",
            difficulty: 2,
            textFilePath: "docs/text/premium/original/20260323_indias-contradictions-wealth-and-vulnerability-2.md"
        ),
        // March 24
        PremiumContentItem(
            id: "premium-20260324-iran-deadlock",
            title: "The Iran Deadlock: No Exit Strategy",
            date: "2026-03-24",
            difficulty: 4,
            textFilePath: "docs/text/premium/original/20260324_iran-deadlock-no-exit-strategy-4.md"
        ),
        // March 25
        PremiumContentItem(
            id: "premium-20260325-latin-americas-crossroads",
            title: "Latin America's Economic Crossroads: Cuba and Argentina",
            date: "2026-03-25",
            difficulty: 2,
            textFilePath: "docs/text/premium/original/20260325_latin-americas-economic-crossroads-2.md"
        ),
        // March 26
        PremiumContentItem(
            id: "premium-20260326-russias-war-economy",
            title: "Russia's War Economy Under Strain",
            date: "2026-03-26",
            difficulty: 4,
            textFilePath: "docs/text/premium/original/20260326_russias-war-economy-under-strain-4.md"
        ),
        // March 27 batch
        PremiumContentItem(
            id: "premium-20260327-africas-ambition",
            title: "Bold Moves: How African Ambition Is Reshaping the Continent",
            date: "2026-03-27",
            difficulty: 2,
            textFilePath: "docs/text/premium/original/20260327_africas-ambition-reshaping-continent_2.md"
        ),
        PremiumContentItem(
            id: "premium-20260327-ai-power-struggle",
            title: "The AI Power Struggle: Chips, Cash, and Boundless Ambition",
            date: "2026-03-27",
            difficulty: 4,
            textFilePath: "docs/text/premium/original/20260327_ai-power-struggle-chips-cash-ambition_4.md"
        ),
        PremiumContentItem(
            id: "premium-20260327-body-hacking",
            title: "The Promise and Peril of Body Hacking",
            date: "2026-03-27",
            difficulty: 3,
            textFilePath: "docs/text/premium/original/20260327_body-hacking-science-vs-hype_3.md"
        ),
        PremiumContentItem(
            id: "premium-20260327-chinas-growth-dilemma",
            title: "China's Triple Bind: Slowing Growth, Inherited Fortunes, and Energy Vulnerability",
            date: "2026-03-27",
            difficulty: 4,
            textFilePath: "docs/text/premium/original/20260327_chinas-growth-dilemma-wealth-energy-slowdown_4.md"
        ),
        PremiumContentItem(
            id: "premium-20260327-dollar-decline",
            title: "The Weakening Dollar and the Global Investment Shift",
            date: "2026-03-27",
            difficulty: 4,
            textFilePath: "docs/text/premium/original/20260327_dollar-decline-reshaping-global-markets_4.md"
        ),
        PremiumContentItem(
            id: "premium-20260327-energy-shock",
            title: "How an Energy Shock Ripples Differently Across Continents",
            date: "2026-03-27",
            difficulty: 4,
            textFilePath: "docs/text/premium/original/20260327_energy-shock-ripples-across-continents_4.md"
        ),
        PremiumContentItem(
            id: "premium-20260327-iran-war",
            title: "The Iran Conflict: Four Paths, All Painful",
            date: "2026-03-27",
            difficulty: 4,
            textFilePath: "docs/text/premium/original/20260327_iran-war-no-good-options_4.md"
        ),
        PremiumContentItem(
            id: "premium-20260327-love-money-status",
            title: "Love, Money, and Status Through the Ages",
            date: "2026-03-27",
            difficulty: 2,
            textFilePath: "docs/text/premium/original/20260327_love-money-and-status-through-the-ages_2.md"
        ),
        PremiumContentItem(
            id: "premium-20260327-russias-isolation",
            title: "Russia's Isolation Deepens Under Economic and Diplomatic Pressure",
            date: "2026-03-27",
            difficulty: 4,
            textFilePath: "docs/text/premium/original/20260327_russias-isolation-deepens-under-pressure_4.md"
        ),
        PremiumContentItem(
            id: "premium-20260327-scientific-frontiers",
            title: "Scientific Frontiers: Brain Power, Fusion Energy, and Fast Charging",
            date: "2026-03-27",
            difficulty: 3,
            textFilePath: "docs/text/premium/original/20260327_scientific-frontiers-brain-fusion-and-batteries_3.md"
        ),
        // March 24 batch
        PremiumContentItem(id: "premium-20260324-africa-after-aid", title: "Africa After Aid: A Continent Finds Its Own Path", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_africa-after-aid_4.md"),
        PremiumContentItem(id: "premium-20260324-africa-reform-conflict", title: "Reform, Conflict, and the Unfinished Business of African Governance", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_africa-reform-conflict_4.md"),
        PremiumContentItem(id: "premium-20260324-ai-arms-race", title: "The AI Arms Race: Who Will Win the Biggest Prize in Business?", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_ai-arms-race_4.md"),
        PremiumContentItem(id: "premium-20260324-ai-next-frontier", title: "AI's Next Frontier: From Physics to Processors", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_ai-next-frontier_4.md"),
        PremiumContentItem(id: "premium-20260324-business-changing-rules", title: "The Changing Rules of Corporate Life", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_business-changing-rules_4.md"),
        PremiumContentItem(id: "premium-20260324-china-growth-dilemma", title: "China's Growth Dilemma: Between Deflation and Ambition", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_china-growth-dilemma_4.md"),
        PremiumContentItem(id: "premium-20260324-china-new-money", title: "New Money, Old Problems: Wealth and Power in Modern China", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_china-new-money_4.md"),
        PremiumContentItem(id: "premium-20260324-energy-global-crunch", title: "The Global Energy Crunch: Winners, Losers, and No Easy Exits", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_energy-global-crunch_4.md"),
        PremiumContentItem(id: "premium-20260324-energy-trump-oil", title: "Trump, Oil, and the Limits of American Energy Power", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_energy-trump-oil_4.md"),
        PremiumContentItem(id: "premium-20260324-europe-economic-identity", title: "Europe's Search for a New Economic Identity", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_europe-economic-identity_4.md"),
        PremiumContentItem(id: "premium-20260324-finance-falling-dollar", title: "The Falling Dollar and What It Means for the World", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_finance-falling-dollar_4.md"),
        PremiumContentItem(id: "premium-20260324-finance-smart-money", title: "Where the Smart Money Is Moving", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_finance-smart-money_4.md"),
        PremiumContentItem(id: "premium-20260324-india-reality-check", title: "India's Economic Reality Check", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_india-reality-check_4.md"),
        PremiumContentItem(id: "premium-20260324-iran-war-economic-shockwave", title: "The Economic Shockwave of the Iran War", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_iran-war-economic-shockwave_4.md"),
        PremiumContentItem(id: "premium-20260324-iran-war-lebanon-question", title: "The Lebanon Question: Strategy, Chaos, and the Limits of Regime Change", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_iran-war-lebanon-question_4.md"),
        PremiumContentItem(id: "premium-20260324-iran-war-military-gamble", title: "America's Military Gamble in the Persian Gulf", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_iran-war-military-gamble_4.md"),
        PremiumContentItem(id: "premium-20260324-iran-war-trump-options", title: "Why None of Trump's Options in Iran Look Good", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_iran-war-trump-options_4.md"),
        PremiumContentItem(id: "premium-20260324-latam-reform-ruin", title: "Reform and Ruin in Latin America", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_latam-reform-ruin_4.md"),
        PremiumContentItem(id: "premium-20260324-russia-shifting-front", title: "The Shifting Front: Ukraine, Europe, and the New Rules of War", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_russia-shifting-front_4.md"),
        PremiumContentItem(id: "premium-20260324-russia-war-economy", title: "Russia's War Economy: Resilience or Illusion?", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_russia-war-economy_4.md"),
        PremiumContentItem(id: "premium-20260324-science-body-optimization", title: "The Body Optimization Craze: What Science Actually Says", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_science-body-optimization_4.md"),
        PremiumContentItem(id: "premium-20260324-science-edge", title: "Science at the Edge: From Gut Bacteria to Fusion Reactors", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_science-edge_4.md"),
        PremiumContentItem(id: "premium-20260324-social-gilded-age", title: "The New Gilded Age: Inequality, Plutocrats, and Shifting Norms", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_social-gilded-age_4.md"),
        PremiumContentItem(id: "premium-20260324-social-modern-discontent", title: "Modern Discontent: Why the Western World Feels Adrift", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_social-modern-discontent_4.md"),
        PremiumContentItem(id: "premium-20260324-us-inward-turn", title: "America's Inward Turn: Power, Symbols, and Fractures", date: "2026-03-24", difficulty: 4, textFilePath: "docs/text/premium/original/20260324_us-inward-turn_4.md"),
    ]

    // MARK: - Grouped by date (newest first)

    static var groupedByDate: [(date: String, items: [PremiumContentItem])] {
        let grouped = Dictionary(grouping: items, by: \.date)
        return grouped.sorted { $0.key > $1.key }
            .map { (date: $0.key, items: $0.value) }
    }

    // MARK: - Helpers

    static func getItem(_ id: String) -> PremiumContentItem? {
        items.first { $0.id == id }
    }
}
