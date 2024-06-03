import Queues

struct MatchJob: AsyncJob {
    typealias Payload = Match
    
    func dequeue(_ context: QueueContext, _ payload: Match) async throws {
        let db = context.application.db
        
        let match = try await Match.find(payload.id, on: db)!
        
        let home = try await Team.find(match.home.id, on: db)!
        let away = try await Team.find(match.away.id, on: db)!
        
        let homePlayers = try await home.$players.get(on: db).prefix(11) // [0..<21]
        let awayPlayers = try await away.$players.get(on: db).prefix(11) // [0..<21]
        
        print("Match starting: \(home.abr) - \(away.abr)")
        
        let base = 0.019 // 0.0223
        
        let homeChance = base * 1.02 * 1 * average(t1: homePlayers, t2: awayPlayers, f1: home.formation, f2: away.formation)
        let awayChance = base * 0.98 * 1 * average(t1: awayPlayers, t2: homePlayers, f1: away.formation, f2: home.formation)
        
        print("Home chance: \(homeChance)")
        print("Away chance: \(awayChance)")
        
        for min in 0...90 {
            print("Minute : \(min)")
            try? await Task.sleep(nanoseconds: 1000000000) // 1000000000 = 1 second
        
            // MARK: Goal
            
            if Double.random(in: 0...1) < homeChance {
                let player = homePlayers.randomElement()!
                
                let action = Action.goal(player: player, assist: nil, team: home, minute: min)
                
                match.actions.append(action)
                try await match.save(on: db)
            }
            else if Double.random(in: 0...1) > 1 - awayChance {
                let player = awayPlayers.randomElement()!
                
                let action = Action.goal(player: player, assist: nil, team: away, minute: min)
                
                match.actions.append(action)
                try await match.save(on: db)
            }
            if Double.random(in: 0...1).distance(to: 0.5) < 0.05 {
                let rand = Bool.random()
                let team = rand ? home : away
                let players = rand ? homePlayers : awayPlayers
                let player = players.randomElement()!
                let action = Action.yellowCard(player: player, team: team, minute: min)
            }
            
            // MARK: Over
            if min == 90 {
                match.actions.append(.over)
                try await match.save(on: db)
            }
        }
        
        func average(t1: ArraySlice<Player>, t2: ArraySlice<Player>, f1: Formation, f2: Formation) -> Double {
            let a = f1.atk
            let attack = t1[11-a..<11].reduce(0) { $0 + $1.score } / a
            
            let m = f1.mid
            let midfield = t1[11-a-m..<11-a].reduce(0) { $0 + $1.score } / m
            
            let d = f2.def
            let defence = t2[1..<d+1].reduce(0) { $0 + $1.score } / d
            
            let m2 = f2.mid
            let midfield2 = t2[1+d..<1+d+m2].reduce(0) { $0 + $1.score } / m2
            
            let gk = t2[10].score
            
            print("T1: Atk: \(attack), Mid: \(midfield)")
            print("T2: Mid \(midfield2), Def: \(defence), Goal: \(gk)")
            
            let multiplier = 1 + (Double((attack * 2) + (midfield / 2) - (midfield2 / 2) - defence - gk) / 100)
            
            print("Multiplier: \(multiplier)")
            return multiplier
        }
    }
    
    func error(_ context: QueueContext, _ error: Error, _ payload: Match) async throws {
        // If you don't want to handle errors you can simply return. You can also omit this function entirely.
        print("MatchJob Error: \(error)")
        return
    }
}
