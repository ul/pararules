import unittest
import pararules
import tables, sets

type
  Id = enum
    Global
    Player
  Attr = enum
    DeltaTime
    State
  TState = enum
    Idle
    Acting

schema Fact(Id, Attr):
  DeltaTime: float
  State: TState

test "thenFinally is not double-fired":
  var triggerCount = 0
  var triggerEmptyCount = 0

  let rules =
    ruleset:
      rule act(Fact):
        what:
          (Global, DeltaTime, dt)
          (id, State, Acting)
        thenFinally:
          triggerCount.inc
          let xs = session.queryAll(this)
          if xs.len == 0:
            triggerEmptyCount.inc
          for x in xs:
            session.insert(x.id, State, Idle)

  var session = initSession(Fact, autoFire = false)
  for r in rules.fields:
    session.add(r)

  session.insert(Global, DeltaTime, 1.0)
  session.insert(Player, State, Acting)

  session.fireRules()

  check triggerCount == 1
  check triggerEmptyCount == 0
