# Signal-Based State/Ninja Refactoring Plan

## Goal

Remove the `State -> ninja_owner -> Ninja` dependency while keeping the existing state machine understandable and preserving shared state logic between Player and Enemy.

The intended dependency direction is:

```text
Ninja owns StateMachine
StateMachine owns State nodes
State emits requests/events
Ninja, NinjaPlayer, or NinjaEnemy handles those requests/events
```

`State` should not know that its owner is a `Ninja`, and it should not reach through `ninja_controller`, `state_machine`, `animation_player`, timers, or collision nodes.

This is a focused event/command boundary, not a new framework. The refactor should avoid introducing multiple context interfaces, handler objects, or a general event bus.

---

## Architectural Decisions

### 1. Use signals only for the State-to-owner boundary

Signals are appropriate where the state is expressing intent or reporting an event:

```text
State -> transition requested
State -> animation requested
State -> velocity requested
State -> damage received
State -> attack area requested
```

The receiver decides how to apply the request.

Do not replace every internal calculation with a signal. A state may still calculate acceleration, friction, gravity, or knockback locally; it emits the resulting request when the owner must mutate its own data.

### 2. Keep StateMachine responsible for transitions

The state machine already validates that only the active state can transition. Preserve that rule.

Recommended flow:

```text
State.transition_requested.emit(target_name)
StateMachine receives the signal
StateMachine.transition_state(current_state, target_name)
```

This is preferable to making `Ninja` manually mediate every transition. `Ninja` still owns the state machine, but states do not need to access it.

### 3. Keep shared state logic in shared states

`HurtState` should remain shared if its common responsibility is:

- applying shared hurt movement such as friction/gravity;
- requesting the hurt animation;
- reporting that damage was received;
- transitioning to `RecoverState` when the animation finishes.

It should not decide whether damage causes dismemberment, ragdoll, death, player recovery, AI changes, or loot.

### 4. Put divergent behavior in entity classes

`Ninja` owns the default response. `NinjaPlayer` and `NinjaEnemy` override only the behavior that differs.

For example:

```text
HurtState emits damage_received(attacker, attack_node)
Ninja receives it and calls its damage hook
NinjaPlayer applies player damage/recovery rules
NinjaEnemy applies hit-pool/dismemberment/death rules
```

This uses normal inheritance already present in the project instead of adding a strategy object for every behavior.

### 5. Separate events from requests by naming

Use names that communicate direction and intent:

- `transition_requested`
- `animation_requested`
- `velocity_requested`
- `damage_received`
- `attack_area_requested`

Avoid ambiguous names such as `velocity_changed` when the state is only asking the owner to change velocity. `changed` implies the mutation already happened.

---

## Proposed Signal Surface

Define the small common signal surface in `State` so all states can use the same boundary:

```text
signal transition_requested(state_name: String)
signal animation_requested(animation_name: String)
signal velocity_requested(new_velocity: Vector2)
signal velocity_delta_requested(delta_velocity: Vector2)
signal forward_direction_requested(direction: int)
signal gravity_requested(delta: float)
signal attack_area_requested
```

Define damage reporting in `HurtState` because it is specific to that state:

```text
signal damage_received(attacker: Ninja, attack_node: ComboNode)
```

The exact final list should be kept as small as possible. Start with signals required to remove an actual direct access. Do not add signals speculatively.

### Signal payload guidance

- Use `new_velocity` when the state intends to replace the complete velocity.
- Use `delta_velocity` when the owner should add momentum or knockback.
- Use a named request for an operation such as gravity or attack-area processing.
- Passing `attacker` and `ComboNode` is acceptable for the damage event because those are existing gameplay concepts already used by the combat code. Do not pass the `Ninja` owner itself as a generic context object.

---

## Refactoring Phases

### Phase 0: Establish a behavior inventory

Before changing behavior, record the current communication points.

Search and classify all `ninja_owner` accesses in:

- `scenes/states/base/state.gd`;
- `scenes/states/base/hurt_state.gd`;
- player airborne, grounded, wall, and combat states;
- any future files under `scenes/states/enemy/`.

Classify each access as one of:

1. state transition;
2. animation request;
3. velocity/physics mutation;
4. controller query;
5. sensor/timer query;
6. entity-specific behavior.

This classification is the change checklist and prevents accidental behavior changes during migration.

### Phase 1: Add the transition signal

Refactor `State.switch_state()` first:

```text
Current:
State -> ninja_owner.state_machine.transition_state(...)

Target:
State.transition_requested.emit(state_name)
StateMachine connects to each child State
```

Keep `StateMachine.transition_state()` as the single validation point. Connect state signals after discovering the state children and disconnect them when appropriate.

Validation:

- initial state starts as before;
- all existing transitions still work;
- a non-current state cannot transition the machine;
- no state accesses `ninja_owner.state_machine`.

### Phase 2: Move common presentation and physics requests

Refactor the base helpers in `state.gd` in small groups:

1. `set_animation()` becomes `animation_requested.emit(animation)`;
2. velocity helpers emit complete or delta velocity requests;
3. `update_forward_direction_h()` emits a direction request;
4. attack processing emits `attack_area_requested`;
5. gravity remains calculated by the state but is applied by the owner through a request.

`Ninja` connects these signals and remains responsible for mutating:

- `velocity`;
- `animation_player`;
- `flippable`;
- attack-area processing;
- gravity and movement integration.

Keep `State` calculations such as `move_toward()` in the state where they are part of state behavior. The owner should apply the result, not reimplement state decisions.

Validation:

- walking, jumping, falling, wall states, and attacks retain their existing movement;
- animation completion still reaches the active state;
- no state directly accesses `velocity`, `animation_player`, `wall_cast`, or `attack_area`.

### Phase 3: Replace controller and environment reach-through

The current base state and player states directly query:

```text
ninja_owner.ninja_controller
ninja_owner.is_grounded
ninja_owner.just_grounded
ninja_owner.wall_cast
ninja_owner.mario_jump_timer
```

Avoid exposing the entire `Ninja` through a new facade. Instead, add only the minimum signals or state-facing queries needed by the current state machine.

Recommended ownership split:

- `NinjaController` or `NinjaEnemyController` produces movement/action intent;
- `Ninja` stores the current environment facts and forwards only the facts needed by states;
- `State` consumes those facts through a small existing state API or values maintained by `StateMachine`.

Because Player and Enemy controllers differ, use neutral terms such as movement/action intent rather than player-specific "input" terminology. Do not force AI behavior into keyboard-shaped methods.

Validation:

- Player movement still responds to the player controller;
- Enemy controller behavior remains independent of Player input APIs;
- wall detection and Mario-jump timing remain frame-consistent.

### Phase 4: Refactor shared damage flow

The current path is:

```text
Ninja.on_attack_registered()
  -> target.current_state.switch_state(HURT)
  -> HurtState.apply_incoming_damage()
  -> ninja_owner.apply_incoming_damage()
```

Target path:

```text
Ninja.on_attack_registered()
  -> target state machine transitions to HURT
  -> HurtState receives the attack and emits damage_received
  -> target Ninja handles the signal
  -> virtual entity-specific damage hook runs
```

Keep the shared `HurtState` responsible for the shared hurt lifecycle. Move the response to the entity owner:

- `Ninja`: default damage hook or intentionally empty hook;
- `NinjaPlayer`: player-specific health, knockback, control/recovery behavior;
- `NinjaEnemy`: hit pool, dismemberment, varied animation, eradication/death behavior.

The state must not contain `if owner is NinjaEnemy` or cast its owner to `NinjaPlayer`. Subclass-specific behavior belongs in the subclass.

Important sequencing rule:

1. transition to `HurtState`;
2. deliver the attack payload once;
3. emit `damage_received` once;
4. let the target entity decide whether it remains hurt, recovers, dies, or becomes static.

This avoids duplicate damage handling while preserving the existing enemy dismemberment behavior.

Validation:

- an enemy still loses limbs and chooses varied animations;
- an enemy still dies when its body rules require it;
- Player and Enemy can share `HurtState` without state-level type checks;
- damage is applied exactly once per attack.

### Phase 5: Migrate state subclasses incrementally

Migrate in this order:

1. `hurt_state.gd` and `recover_state.gd`;
2. grounded states (`idle`, `walk`, `turn`, `land`);
3. airborne states (`jump`, `fall`);
4. wall states (`cling`, `slide`, `jump`, `run`);
5. `attack_state.gd` last, because it has combat, animation callbacks, buffered input, and eradication interactions.

For each file:

- replace one category of owner access;
- run the focused behavior check;
- remove the old direct path only after the signal path works.

Do not rewrite all state files in one pass. The attack state and wall states have different timing risks and should remain separately reviewable.

### Phase 6: Remove the circular reference

After all states are migrated:

- remove `@onready var ninja_owner: Ninja = owner` from `State`;
- remove any remaining owner casts from state scripts;
- remove any compatibility wrappers that only existed during migration;
- search the entire `scenes/states/` tree for `ninja_owner`, `.state_machine`, and direct Ninja component access;
- retain `Ninja -> StateMachine -> State` ownership and `Ninja` signal connections.

The final state should have no concrete dependency on `Ninja` except where a gameplay payload genuinely requires an attacker reference. That payload is not an owner back-reference.

---

## Player/Enemy Responsibility Matrix

| Responsibility | Shared State | Ninja | NinjaPlayer | NinjaEnemy |
|---|---|---|---|---|
| Decide common state transition | Yes | No, receives request | No | No |
| Calculate state movement | Yes | No | Optional override only if needed | Optional override only if needed |
| Apply velocity/animation | Requests | Yes | Inherits | Inherits/varies animation |
| Read controller intent | Consumes neutral intent | Provides owner-facing data | Player controller | Enemy controller |
| Report damage received | Emits event | Receives event | Handles player response | Handles dismemberment/death response |
| Hurt animation lifecycle | Shared | Applies animation request | Can override animation policy | Uses varied animation override |
| Death/dismemberment | No | Default hook | Player-specific | Enemy-specific |
| State ownership/transition validation | No | Owns machine | Inherits | Inherits |

The key rule is that sharing a state does not mean sharing every consequence of that state. Shared states should own the common lifecycle; entity subclasses should own consequences that differ.

---

## Testing and Validation Plan

### Static checks

- `rg "ninja_owner|ninja_controller|state_machine|animation_player|wall_cast|attack_area" scenes/states`
- Confirm only intended gameplay payload types remain in state signals.
- Confirm no state casts its owner to `NinjaPlayer` or `NinjaEnemy`.
- Confirm all state nodes in Player and Enemy scenes are connected through the same setup path.

### Focused runtime checks

1. Spawn Player: idle, walk, turn, jump, fall, wall cling/slide/run/jump, attack, recover.
2. Spawn Enemy: idle/controller behavior, hurt, limb loss, varied hurt animation, death/static behavior.
3. Hit Player and Enemy with the same attack:
   - both receive one damage event;
   - each applies its own response;
   - shared `HurtState` does not branch on entity type.
4. Verify animation-finished callbacks still transition the active state.
5. Verify a stale/inactive state cannot transition the state machine.

### Regression risks to watch

- signal connections made before all states are discovered;
- duplicate connections after scene reload or `_ready()`;
- damage emitted before the target has entered `HurtState`;
- animation callbacks arriving after a state transition;
- changing complete velocity where the old code changed only one axis;
- enemy varied-animation override being bypassed by a base animation handler.

---

## Definition of Done

The refactor is complete when:

- `State` no longer stores or assumes a `Ninja` owner;
- state transitions pass through a signal and remain validated by `StateMachine`;
- common state requests are signals handled by `Ninja`;
- shared `HurtState` emits a damage event and contains no Player/Enemy branching;
- Player and Enemy implement their different damage responses in their own classes;
- controller differences remain behind their respective controller implementations;
- Player and Enemy scene behavior matches the pre-refactor behavior;
- focused runtime checks pass and static searches show no accidental back-reference.

## Recommended Scope

Implement Phases 1, 2, and 4 first. They directly address the bidirectional coupling and demonstrate the Player/Enemy benefit with limited surface area. Implement Phases 3, 5, and 6 only as the migrated signal boundary proves stable.

This keeps the refactor straightforward: one communication mechanism, existing inheritance for divergent behavior, and no additional context or strategy framework unless a concrete requirement appears later.
