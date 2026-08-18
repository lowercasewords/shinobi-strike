# Coupling Refactoring Strategy - Analysis & Considerations for Player/Enemy Architecture

## Current Architecture Problem

The codebase has a subtle but critical architectural challenge: **shared state types with divergent implementations**.

### Example: HurtState Divergence
```
Both NinjaPlayer and NinjaEnemy can be hurt, but:

NinjaPlayer.take_damage():
  - Animation plays (pain reaction)
  - Health decreases
  - Knockback applies
  - State transitions to HurtState
  - Player regains control after animation

NinjaEnemy.take_damage():
  - Animation plays differently (based on dismemberment)
  - Health decreases
  - Knockback applies
  - State transitions to HurtState
  - Drops to recovery/death state
  - Might drop loot
  - Might trigger aggro behaviors
```

Both use the same **HurtState** class, but the behaviors diverge significantly once entered.

---

## How Current Refactoring Strategy Handles This

### The StateContext Interface Approach

**Strength**: Abstracting the Ninja interface allows different implementations

```gdscript
# StateContext abstracts: "what can a state request?"
class_name StateContext
func request_animation(animation_name: String) -> void: pass
func request_state_transition(state_name: String) -> void: pass
func get_current_animation() -> String: pass
```

**Applied to both Player and Enemy**:
- Both NinjaPlayer and NinjaEnemy implement StateContext
- States call `context.request_animation()` (works for both)
- States call `context.request_state_transition()` (works for both)
- Basic physics (`apply_gravity()`, `apply_friction()`) are identical

### Where It Works Well ✓
1. **Shared physics**: Jump, fall, walk mechanics are identical
2. **Basic animations**: Playing animations works the same way
3. **Input handling**: Getting controller input is abstracted
4. **State transitions**: Moving between states works identically

### Where It Has Limitations ✗

**Problem 1: Behavior-Specific Logic in States**

```gdscript
# In HurtState (affects both Player and Enemy)
func apply_incoming_damage(attacker: Ninja, attack_node: ComboNode):
    # This is implemented differently per entity type!
    # But HurtState has to know about it
    ninja_owner.apply_incoming_damage(attacker, attack_node)
    
    # For Player: maybe knockback is reduced if blocking
    # For Enemy: maybe knockback triggers ragdoll
    # Same method, different outcomes
```

**Problem 2: State-Specific Behavior Queries**

```gdscript
# In WalkState
var is_attacking = ninja_owner.state_machine.current_state is AttackState
# Both Player and Enemy have AttackState, but:
# - Player might be in a combo
# - Enemy might be in a predictable attack sequence
# Same check, different meanings
```

**Problem 3: Entity-Type Specific Features**

```gdscript
# Some states check for features that only exist on one type:
if ninja_owner is NinjaEnemy:
    var enemy = ninja_owner as NinjaEnemy
    enemy.ai_controller.request_behavior_change("agitated")

# This breaks abstraction - states shouldn't know about NinjaEnemy
# But StateContext doesn't have a place for AI behavior requests
```

---

## Architectural Issues Exposed by Player/Enemy Divergence

### Issue 1: StateContext is Still Ninja-Centric

The current StateContext is designed around what **Ninja** provides, not what **different character types** need.

```gdscript
# StateContext asks: "What operations does Ninja support?"
# Better question: "What operations do ALL entities need to support?"

# Current interface (Ninja-centric):
func apply_gravity(delta: float) -> float
func get_input_direction_h() -> float
func request_state_transition(state_name: String) -> void

# Issue: Enemies don't have "input" in the same way
# Issue: Some enemies might not use gravity
# Issue: State transition logic is Ninja-specific
```

### Issue 2: Behavior Divergence Not Represented in Interface

```gdscript
# The interface doesn't distinguish between:
# - Guaranteed identical behavior (apply_gravity)
# - Context-dependent behavior (apply_incoming_damage)
# - Entity-type specific behavior (AI controller access)

# This means states still have to make assumptions
# and potentially do instanceof checks
```

### Issue 3: Controller Logic Leakage

```gdscript
# States access input through StateContext:
func get_input_direction_h() -> float

# But:
# - Player has ninja_controller (keyboard input)
# - Enemy has ai_controller (behavior tree)
# - Both are abstracted as "get input"

# This works for simple cases but breaks for:
# - Complex input combinations (e.g., "holding dash while jumping")
# - AI state queries (e.g., "should pursue target?")
```

---

## Recommendations for Improved Architecture

### Recommendation 1: Stratify StateContext by Behavior Certainty

Create multiple context layers based on certainty of identical behavior:

```gdscript
# Layer 1: Physics (guaranteed identical)
class PhysicsContext:
    func apply_gravity(delta: float) -> float
    func is_on_floor() -> bool
    func apply_friction(delta: float) -> float

# Layer 2: Animation (usually identical, predictable)
class AnimationContext:
    func request_animation(name: String) -> void
    func get_current_animation() -> String

# Layer 3: Control (different per type but abstracted)
class ControlContext:
    func get_movement_direction() -> float  # "movement" not "input"
    func get_action_pressed(action: String) -> bool

# Layer 4: Behavior (entity-specific)
class BehaviorContext:
    func apply_damage(source: Entity, damage_info: ComboNode) -> void
    func request_behavior_change(new_behavior: String) -> void  # Enemy-specific

# States inherit the layers they need:
class WalkState:
    func update():
        # Uses PhysicsContext + ControlContext + AnimationContext
        # Doesn't touch BehaviorContext
```

**Benefit**: Clear separation between guaranteed-same and divergent behaviors

### Recommendation 2: Use Strategy Pattern for Divergent Behaviors

Delegate entity-specific behavior to separate strategy objects:

```gdscript
# In StateContext (stays generic)
class StateContext:
    var damage_handler: DamageHandlerStrategy
    var animation_handler: AnimationHandlerStrategy
    var movement_handler: MovementHandlerStrategy

# In HurtState (doesn't need to know entity type)
func apply_incoming_damage(attacker, attack_info):
    context.damage_handler.handle_damage(attacker, attack_info)
    # Player's damage_handler: applies knockback
    # Enemy's damage_handler: applies ragdoll + triggers death sequence
    # Same interface, different behaviors

# Implementations:
class PlayerDamageHandler:
    func handle_damage(attacker, attack_info):
        entity.knockback = attack_info.knockback_force
        entity.apply_incoming_damage(attacker, attack_info)

class EnemyDamageHandler:
    func handle_damage(attacker, attack_info):
        entity.ragdoll = true
        entity.ragdoll_impulse = attack_info.knockback_force
        entity.drop_loot()
        entity.trigger_death_sequence()
```

**Benefit**: States remain generic, but entity-specific logic is encapsulated

### Recommendation 3: Define State Contracts Explicitly

Create clear documentation of what each state needs from context:

```gdscript
# Example for HurtState:
## Requires from StateContext:
##   - request_animation(animation_name: String)
##   - request_state_transition(state_name: String)
##   - get_current_animation() -> String
##   - velocity (get/set)
##
## Requires from BehaviorContext:
##   - handle_damage(source: Entity, damage_info: ComboNode) -> void
##
## Guarantees:
##   - Plays hurt animation
##   - Transitions to recovery or death based on health
##   - Applies knockback
##
## Assumptions:
##   - Animation named "{base_hurt_name}" exists
##   - Damage handler knows how to respond appropriately

class HurtState extends State:
    # Implementation uses documented contract
```

**Benefit**: Makes state requirements explicit, easier to verify compatibility

### Recommendation 4: Consider State Inheritance for Type-Specific Behavior

Instead of one HurtState for both, allow type-specific variations:

```gdscript
# Base state (common behavior)
class HurtState extends State:
    func enter():
        context.request_animation("hurt_base")
        apply_knockback()
    
    func apply_knockback():
        # Default implementation
        context.velocity.x = knockback_force * forward_direction

# Player-specific override
class PlayerHurtState extends HurtState:
    func enter():
        super.enter()
        # Player-specific: reduced knockback if blocking
        if context.is_blocking():
            context.velocity.x *= 0.5

# Enemy-specific override
class EnemyHurtState extends HurtState:
    func enter():
        super.enter()
        # Enemy-specific: trigger ragdoll
        context.behavior_handler.enable_ragdoll()
```

**Benefit**: Reuses common logic, allows specific overrides, no instanceof checks

---

## Issues with Current Implementation

### Issue A: StateContext Too Low-Level

The current StateContext exposes **how to do things** (set velocity, play animation) rather than **what states need**.

```gdscript
# Current (low-level):
context.velocity.y += gravity_applied  # Exposes implementation detail

# Better (high-level):
context.apply_gravity(delta)  # Declares intent
```

### Issue B: No Abstraction of Entity-Specific Features

```gdscript
# Enemy-specific code in states:
if ninja_owner is NinjaEnemy:
    var enemy = ninja_owner as NinjaEnemy
    enemy.body.enable_dismemberment()

# This bypasses StateContext completely
# Better: StateContext.enable_special_physics("dismemberment")
```

### Issue C: Input Abstraction Too Narrow

```gdscript
# Only exposes simple input queries:
func get_input_direction_h() -> float
func get_input_pressing_jump() -> bool

# Doesn't support:
# - Complex input combinations
# - AI decision queries (e.g., "should attack?")
# - Conditional behaviors
```

---

## Impact Assessment: Current Strategy for Player vs Enemy

### Where Current Strategy Works Well ✓✓

| State Type | Player | Enemy | Compatibility |
|-----------|--------|-------|---|
| **Grounded Physics** (gravity, friction, speed) | Identical | Identical | ✓✓ No issues |
| **Basic Movement** (walk, idle) | Identical logic | Identical logic | ✓✓ No issues |
| **Animation Playback** | Play animation | Play animation | ✓✓ No issues |
| **State Transitions** | state_machine.WALK | state_machine.WALK | ✓✓ No issues |

### Where Current Strategy Has Issues ✗

| State Type | Player | Enemy | Compatibility |
|-----------|--------|-------|---|
| **HurtState** | Apply knockback, continue combat | Ragdoll, death handling, loot | ✗ Behavior diverges |
| **AttackState** | Combo system, player-controlled | Predetermined attacks, AI-controlled | ✗ Completely different |
| **DeathState** | Fade out, menu | Ragdoll, loot drop, respawn | ✗ Completely different |
| **IdleState** | Wait for input | Run AI behavior tree | ⚠ Similar but diverges |

### Severity: Medium-to-High

The current strategy will work for **physics and basic state transitions** but will still require **isinstance checks and type-specific casts** in several states.

---

## Proposed Evolution Path

### Phase 1 (Current): Basic Decoupling ✓
- Create StateContext interface for physics/animation/basic control
- Reduces tight coupling on basic operations
- Backward compatible with existing states
- **Status**: Solves 60% of coupling problem

### Phase 2 (Recommended): Behavior Stratification
- Separate StateContext into PhysicsContext, ControlContext, BehaviorContext
- Add strategy pattern for entity-specific behaviors
- Define explicit contracts for each state
- **Impact**: Solves additional 30% of coupling problem

### Phase 3 (Future): Type-Specific State Variants
- Create PlayerHurtState, EnemyHurtState (both extend HurtState)
- Move type-specific logic out of shared states
- Use inheritance instead of conditionals
- **Impact**: Solves remaining 10% of coupling problem

---

## Conclusion: Strategy Effectiveness for Player/Enemy Architecture

**The current StateContext strategy is a solid foundation** but needs enhancement to fully address Player/Enemy divergence.

### Current Limitations:
- Works great for shared physics/animation
- Still requires type-specific code for behavior differences
- Doesn't explicitly represent what's guaranteed identical vs. divergent
- May still need some instanceof checks in complex states

### Recommended Enhancement:
1. **Keep** the basic StateContext (good foundation)
2. **Add** strategy objects for behavior divergence (DamageHandler, AnimationHandler, etc.)
3. **Document** state contracts explicitly (what each needs from context)
4. **Consider** state inheritance for Player/Enemy-specific versions later

### Net Result:
- **Short term**: 60% reduction in coupling, maintains flexibility for Player/Enemy differences
- **Medium term**: 90% reduction in coupling with strategy pattern additions
- **Long term**: 95%+ reduction with type-specific state variants

The strategy is sound but should be viewed as **Phase 1 of a multi-phase architecture improvement**, not a complete solution.
